import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInState {
  final bool isLoading; // 로그인 진행 중 상태
  final String? errorMessage; // 에러 메시지
  final String? type; // 'owner' 또는 'customer' 저장

  SignInState({
    this.isLoading = false,
    this.errorMessage,
    this.type, // type 필드 추가
  });

  // copyWith 메서드에 type 필드 추가
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

// SignInViewModel 클래스 정의
class SignInViewModel extends StateNotifier<SignInState> {
  SignInViewModel() : super(SignInState());

  // 사용자가 선택한 타입 저장
  void setType(String type) {
    state = state.copyWith(type: type);
  }

  // 로그인 처리 함수
  Future<void> handleLogin(BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true); // 로딩 상태 시작

    try {

      // type에 따라 owners 또는 users 컬렉션 선택
      final collectionName = state.type == 'owner' ? 'owners' : 'users';

      // Firestore에서 해당 이메일이 존재하는지 확인
      final userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        // 해당 이메일이 없을 경우 에러 처리
        state = state.copyWith(
          isLoading: false,
          errorMessage: '해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.')),
        );
      } else {
        // FirebaseAuth로 로그인 시도
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        // 로그인 성공 시 SharedPreferences에 정보 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('type', state.type!); // 사용자 타입 저장

        // type에 따라 적절한 화면으로 이동
        if (collectionName == "owners") {
          Navigator.pushReplacementNamed(context, '/owner-home');
        } else {
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      // 로그인 실패 시 에러 메시지
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다: $e')),
      );
    } finally {
      state = state.copyWith(isLoading: false); // 로딩 상태 종료
    }
  }

  // Google 로그인 처리 및 Firestore에 사용자 정보 추가 또는 연동 처리
  Future<void> signInWithGoogle(BuildContext context, {required bool isOwner}) async {
    state = state.copyWith(isLoading: true); // 로딩 상태 시작

    try {
      await FirebaseAuth.instance.signOut();
      print('기존 사용자 로그아웃 완료');

      // Google 로그인 시작
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false); // 사용자가 취소한 경우 로딩 중지
        return;
      }

      final googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firestore에서 사용자 정보 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .get();

      final ownerDoc = await FirebaseFirestore.instance
          .collection('owners')
          .where('email', isEqualTo: googleUser.email)
          .get();

      // ownerDoc에 결과가 있을 경우, 로그인 중단 및 경고 메시지 표시
      if (ownerDoc.docs.isNotEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: '해당 이메일은 구글 로그인을 지원하지 않습니다.');
        return;
      }

      if (userDoc.docs.isNotEmpty) {
        // Firestore에 이미 사용자 정보가 있는 경우
        final authType = userDoc.docs.first['authType']; // Firestore의 authType 필드 사용
        print('Firestore authType: $authType');

        if (authType == 'google') {
          // Google로 로그인
          final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
          final currentUser = userCredential.user;

          // 로그인 성공 시 SharedPreferences에 사용자 정보 저장
          await _saveLoginInfo(currentUser!, 'user'); // 여기서 'user'는 타입에 따라 'owner' 또는 'user'

          // Firestore에서 email로 사용자 정보가 있는지 확인
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser.email)
              .get();

          if (querySnapshot.docs.isEmpty) {
            // Firestore에 사용자 정보가 없을 경우에만 추가
            await _addUserToFirestore(currentUser, isOwner); // Firestore에 사용자 정보 추가
            print('Firestore에 사용자 정보 추가 완료');
          } else {
            print('Firestore에 사용자 정보가 이미 존재합니다.');
          }

          // 로그인 성공 후 홈 화면으로 이동
          Navigator.pushReplacementNamed(context, '/user-home');
          return;
        } else if (authType == 'email') {
          // 이메일 인증 연동 처리
          final password = await _promptForPassword(context, googleUser.email);
          final emailCredential = EmailAuthProvider.credential(
            email: googleUser.email,
            password: password,
          );

          try {
            final emailUserCredential = await FirebaseAuth.instance.signInWithCredential(emailCredential);
            await emailUserCredential.user?.linkWithCredential(googleCredential);
            await _updateAuthTypeInFirestore(emailUserCredential.user!, 'google');

            // 로그인 성공 시 SharedPreferences에 사용자 정보 저장
            await _saveLoginInfo(emailUserCredential.user!, 'user');
            Navigator.pushReplacementNamed(context, '/user-home');
          } catch (e) {
            state = state.copyWith(isLoading: false, errorMessage: '로그인에 실패했습니다: $e');
          }
          return;
        }
      } else {
        // Firestore에 사용자가 없는 경우, Google로 새 사용자로 로그인
        final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
        final newUser = userCredential.user;

        if (newUser != null) {
          await _addUserToFirestore(newUser, isOwner); // Firestore에 사용자 정보 추가
          // 로그인 성공 시 SharedPreferences에 사용자 정보 저장
          await _saveLoginInfo(newUser, 'user');
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Google 로그인에 실패했습니다: $e');
    } finally {
      state = state.copyWith(isLoading: false); // 로딩 상태 종료
    }
  }

  // 사용자 로그인 정보를 SharedPreferences에 저장하는 함수
  Future<void> _saveLoginInfo(User user, String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email!); // 사용자 이메일 저장
    await prefs.setString('type', type); // 'owner' 또는 'user' 저장
  }

  // Firestore에 사용자 정보 추가
  Future<void> _addUserToFirestore(User user, bool isOwner) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': user.displayName ?? 'null',
      'points': 0,
      'profilePicUrl': user.photoURL,
      'pubId': null,
      'authType': 'google', // 새로운 사용자에 대한 Google 로그인 방식 추가
      'type': isOwner ? 'owner' : 'customer',
      'uid': user.uid,
    });
  }

  // Firestore에서 사용자의 authType을 업데이트
  Future<void> _updateAuthTypeInFirestore(User user, String authType) async {
    // 'users' 컬렉션에서 이메일로 문서 조회
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 이메일로 조회한 문서가 있는 경우 해당 문서의 authType 업데이트
      final docId = querySnapshot.docs.first.id; // 첫 번째 문서의 ID 가져오기
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'authType': authType,
      });
      print('Firestore authType 업데이트: $authType');
    } else {
      print('해당 이메일로 문서를 찾을 수 없습니다.');
    }
  }

  // 비밀번호 입력을 위한 다이얼로그
  Future<String> _promptForPassword(BuildContext context, String userEmail) async {
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
                // 상단 텍스트
                Text(
                  'アカウントが既に存在します',  // "Account exists"의 일본어 번역
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'すでにアカウントがあるようです。\nログインしてください。',  // "이미 계정이 존재합니다. 로그인 해주세요."의 일본어 번역
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                // 프로필 이미지 및 이메일 표시
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    userEmail[0].toUpperCase(), // 첫 글자로 아바타 생성
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // 비밀번호 입력 필드
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {
                        // 비밀번호 표시/가리기 로직 추가 가능
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                SizedBox(height: 20),

                // 하단 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(password);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '続行',  // "계속하기"의 일본어 번역
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                // 추가 링크들
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다른 계정으로 로그인
                  },
                  child: Text('別のアカウントでログイン'),  // "다른 계정으로 로그인"의 일본어 번역
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
// SignInViewModel Provider
final signinViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>(
  (ref) => SignInViewModel(),
);