import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferences_manager.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 로그인 상태를 관리하는 클래스
class SignInState {
  final bool isLoading; // 로딩 상태
  final String? errorMessage; // 에러 메시지
  final String? type; // 로그인 종류 (예: 사용자, 소유자)

  SignInState({
    this.isLoading = false,
    this.errorMessage,
    this.type,
  });

  // 상태 복사 및 갱신을 위한 함수
  SignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? type,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
    );
  }
}

// 로그인 로직을 처리하는 뷰모델
class SignInViewModel extends StateNotifier<SignInState> {
  final AuthService _authService = AuthService();
  
  SignInViewModel() : super(SignInState());

  // 로그인 타입 설정 함수 (소유자 또는 사용자)
  void setType(String type) {
    state = state.copyWith(type: type);
  }

  // 이메일과 비밀번호로 로그인 처리 함수
  Future<void> handleLogin(BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true); // 로딩 상태 시작
    final localizations = AppLocalizations.of(context); // 로컬라이제이션

    try {
      // FirebaseAuth로 이메일, 비밀번호 로그인 시도
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 소유자 또는 사용자 구분
      final collectionName = state.type == 'owners' ? 'Owners' : 'Users';
      state = state.copyWith(type: collectionName);

      // Firestore에서 이메일로 사용자 찾기
      final userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();

      // 사용자 존재 여부 확인
      if (userDoc.docs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: localizations?.signInViewModelLoginTypeError ?? '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.signInViewModelLoginTypeError ?? '')),
        );
      } else {
        // 사용자 정보를 Preferences에 저장
        await PreferencesManager.instance.setEmail(email);
        await PreferencesManager.instance.setType(state.type!);

        // 화면 전환
        if (collectionName == "Owners") {
          Navigator.pushReplacementNamed(context, '/owner-home');
        } else {
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: localizations?.signInViewModelLoginFail ?? '',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.signInViewModelLoginFail ?? '')),
      );
    } finally {
      state = state.copyWith(isLoading: false); // 로딩 상태 종료
    }
  }

  // Google 로그인 처리 함수
  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    final localizations = AppLocalizations.of(context);
    final String region = dotenv.env['REGION'] ?? '';
    final String user_email = dotenv.env['USEREMAIL'] ?? '';
    final String owner_email = dotenv.env['OWNEREMAIL'] ?? '';
    final String authType = 'google';

    try {
      await FirebaseAuth.instance.signOut(); // 기존 세션 로그아웃

      // Google 로그인 요청
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false); // 로그인 취소 시 로딩 종료
        return;
      }

      // Google 인증
      final googleAuth = await googleUser.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final functions = FirebaseFunctions.instanceFor(region: region);

      final ownerResponse = await functions.httpsCallable(owner_email).call({'email': googleUser.email});
      final ownerData = ownerResponse.data;

      if (ownerData['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.signInViewModelLineOwner ?? '')),
        );
        return;
      }

      final userResponse = await functions.httpsCallable(user_email).call({'email': googleUser.email});
      final userData = userResponse.data;

      // 기존 사용자 확인 후 로그인 또는 등록
      if (userData['exists'] == true) {
        final authType = userData['userData']['authType'];

        if (authType == 'google') {
          final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
          final currentUser = userCredential.user;

          await _saveLoginInfo(currentUser!, 'Users');
          Navigator.pushReplacementNamed(context, '/user-home');
          return;
        } else if (authType == 'email') {
          final password = await _promptForPassword(context, googleUser.email);
          final emailCredential = EmailAuthProvider.credential(
            email: googleUser.email,
            password: password,
          );

          try {
            final emailUserCredential = await FirebaseAuth.instance.signInWithCredential(emailCredential);
            await emailUserCredential.user?.linkWithCredential(googleCredential);
            await _updateAuthTypeInFirestore(emailUserCredential.user!, 'google');

            await _saveLoginInfo(emailUserCredential.user!, 'Users');
            Navigator.pushReplacementNamed(context, '/user-home');
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations?.signInViewModelLoginFail ?? '')),
            );
          }
          return;
        }
      } else {
        final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
        final newUser = userCredential.user;

        if (newUser != null) {
          final uniqueUID = await _authService.generateUniqueUID(context);

          await _addUserToFirestore(newUser, uniqueUID, authType);

          await _saveLoginInfo(newUser, 'Users');
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.signInViewModelLoginFail ?? '')),
      );
    } finally {
      state = state.copyWith(isLoading: false); // 로딩 상태 종료
    }
  }

  // LINE 로그인 처리 함수
  Future<void> signInWithLine(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    final localizations = AppLocalizations.of(context);
    final String region = dotenv.env['REGION'] ?? '';
    final String userEmailFunction = dotenv.env['USEREMAIL'] ?? '';
    final String authType = 'line';
    final String owner_email = dotenv.env['OWNEREMAIL'] ?? '';
    final String line_pw = dotenv.env['LINE_PASSWD'] ?? '';

    try {
      await FirebaseAuth.instance.signOut(); // 기존 세션 로그아웃

      // LINE 로그인 요청
      final result = await LineSDK.instance.login(
        scopes: ["profile", "openid", "email"], // 요청할 권한
      );

      final userProfile = result.userProfile; // 사용자 프로필 정보
      final userEmail = result.accessToken.email; // 이메일 가져오기

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.signInViewModelLoginFail ?? '')),
        );
        return;
      }

      // Firebase Functions 초기화
      final functions = FirebaseFunctions.instanceFor(region: region);

      final ownerResponse = await functions.httpsCallable(owner_email).call({'email': userEmail});
      final ownerData = ownerResponse.data;

      if (ownerData['exists'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.signInViewModelLineOwner ?? '')),
        );
        return;
      }

      // Users 컬렉션에서 해당 이메일 검사
      final userResponse = await functions.httpsCallable(userEmailFunction).call({'email': userEmail});
      final userData = userResponse.data;

      if (userData['exists'] == true) {
        final authType = userData['userData']['authType'];

        if (authType == 'line') {
          // 이미 LINE 인증 방식으로 등록된 경우 로그인 처리
          final credential = EmailAuthProvider.credential(
            email: userEmail,
            password: line_pw, // 기존에 저장된 비밀번호로 로그인
          );

          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          await _saveLoginInfo(userCredential.user!, 'Users');
          Navigator.pushReplacementNamed(context, '/user-home');
          return;
        } else {
          state = state.copyWith(isLoading: false,);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.signInViewModelLineAnother ?? '')),
          );
          return;
        }
      } else {
        // 새로운 사용자로 등록
        final newCredential = EmailAuthProvider.credential(
          email: userEmail,
          password: line_pw, // 임시 비밀번호
        );

        final newUserCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmail,
          password: line_pw,
        );

        final newUser = newUserCredential.user;
        
        if (newUser != null) {
          await newUser.updateDisplayName(userProfile?.displayName ?? 'null');
          await newUser.updatePhotoURL(userProfile?.pictureUrl ?? '');

          // 사용자 정보 업데이트 후 Firebase Authentication 동기화
          await newUser.reload();
          final updatedUser = FirebaseAuth.instance.currentUser;

          // Firestore에 사용자 정보 추가
          final uniqueUID = await _authService.generateUniqueUID(context);
          await _addUserToFirestore(updatedUser!, uniqueUID, authType);

          await _saveLoginInfo(newUser, 'Users');
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.signInViewModelLoginFail ?? '')),
      );
    } finally {
      state = state.copyWith(isLoading: false); // 로딩 상태 종료
    }
  }

  // 로그인 정보를 Preferences에 저장
  Future<void> _saveLoginInfo(User user, String type) async {
    await PreferencesManager.instance.setEmail(user.email!);
    await PreferencesManager.instance.setType(type);
  }

  // Firestore에 사용자 추가
  Future<void> _addUserToFirestore(User user, String uid, String authType) async {
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'email': user.email,
      'name': user.displayName ?? 'null',
      'points': 0,
      'profilePicUrl': user.photoURL,
      'pubId': null,
      'authType': authType,
      'uid': uid,
    });
  }

  // Firestore에서 인증 방식 업데이트
  Future<void> _updateAuthTypeInFirestore(User user, String authType) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('Users').doc(docId).update({
        'authType': authType,
      });
    }
  }

  // 비밀번호 입력을 위한 다이얼로그 표시
  Future<String> _promptForPassword(BuildContext context, String userEmail) async {
    final localizations = AppLocalizations.of(context);
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations?.signInViewModelAllReady ?? '',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  (localizations?.signInViewModelAllReady ?? '') + '\n' + (localizations?.signInViewModelLogin ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    userEmail[0].toUpperCase(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 10),
                Text(userEmail, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(password);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(localizations?.signInViewModelSubmit?? '', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations?.signInViewModelAnotherLogin?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
    return password;
  }
}

final signinViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>(
  (ref) => SignInViewModel(),
);
