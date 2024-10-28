import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferences_manager.dart'; // PreferencesManager import

// 로그인 상태를 관리하는 SignInState 클래스
class SignInState {
  final bool isLoading; // 로그인 진행 중 여부를 나타내는 상태
  final String? errorMessage; // 에러 메시지 저장
  final String? type; // 'owner' 또는 'customer' 타입을 저장

  SignInState({
    this.isLoading = false, // 기본값 false로 설정
    this.errorMessage,
    this.type, // 타입을 초기화할 수 있음
  });
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

// 로그인 로직을 처리하는 ViewModel 클래스
class SignInViewModel extends StateNotifier<SignInState> {
  // 초기 상태를 설정하며 생성
  SignInViewModel() : super(SignInState());
  // 사용자가 선택한 타입 ('owner' 또는 'customer')을 저장
  void setType(String type) {
    state = state.copyWith(type: type);
  }

  // 이메일과 비밀번호로 로그인 처리
  Future<void> handleLogin(BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true); // 로딩 상태로 전환

    try {
      // Firestore에서 'owners' 또는 'users' 컬렉션을 선택
      final collectionName = state.type == 'owner' ? 'owners' : 'users';

      // 선택된 컬렉션에서 이메일이 존재하는지 Firestore에서 확인
      final userDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        // 이메일이 존재하지 않으면 에러 처리
        state = state.copyWith(
          isLoading: false,
          errorMessage: '해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.',
        );
        // 에러 메시지를 스낵바로 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('해당 이메일이 ${collectionName == "owners" ? "owners" : "users"} 컬렉션에 없습니다.')),
        );
      } else {
        // 이메일이 있으면 FirebaseAuth로 로그인 시도
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.trim(), // 이메일과 비밀번호의 공백 제거 후 로그인
          password: password.trim(),
        );

        // 로그인 성공 시 PreferencesManager에 로그인 정보 저장
        await PreferencesManager.instance.setEmail(email);
        await PreferencesManager.instance.setType(state.type!);

        // 로그인 타입에 따라 홈 화면으로 이동
        if (collectionName == "owners") {
          Navigator.pushReplacementNamed(context, '/owner-home');
        } else {
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      // 로그인 실패 시 에러 메시지 처리
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인에 실패했습니다: $e',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다: $e')),
      );
    } finally {
      // 로딩 상태 종료
      state = state.copyWith(isLoading: false);
    }
  }

  // Google 로그인 처리 및 Firestore에 사용자 정보 추가 또는 연동 처리
  Future<void> signInWithGoogle(BuildContext context, {required bool isOwner}) async {
    state = state.copyWith(isLoading: true); // 로딩 상태로 전환

    try {
      await FirebaseAuth.instance.signOut(); // 기존 사용자 로그아웃
      print('기존 사용자 로그아웃 완료');

      // Google 로그인 시작
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        state = state.copyWith(isLoading: false);
        return;
      }

      // Google 인증 정보를 가져옴
      final googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firestore에서 해당 이메일의 사용자 정보를 가져옴
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .get();

      final ownerDoc = await FirebaseFirestore.instance
          .collection('owners')
          .where('email', isEqualTo: googleUser.email)
          .get();

      // OwnerDoc에 이미 이메일이 있으면 구글 로그인을 중단
      if (ownerDoc.docs.isNotEmpty) {
        state = state.copyWith(isLoading: false, errorMessage: '해당 이메일은 구글 로그인을 지원하지 않습니다.');
        return;
      }

      if (userDoc.docs.isNotEmpty) {
        // Firestore에서 사용자 정보가 이미 있는 경우
        final authType = userDoc.docs.first['authType']; // 인증 방식 가져오기
        print('Firestore authType: $authType');

        if (authType == 'google') {
          // Google로 로그인
          final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
          final currentUser = userCredential.user;

          // 로그인 성공 시 PreferencesManager에 사용자 정보 저장
          await _saveLoginInfo(currentUser!, 'user');

          // 사용자 정보를 Firestore에 업데이트 또는 새로 저장
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser.email)
              .get();

          if (querySnapshot.docs.isEmpty) {
            await _addUserToFirestore(currentUser, isOwner);
            print('Firestore에 사용자 정보 추가 완료');
          } else {
            print('Firestore에 사용자 정보가 이미 존재합니다.');
          }

          // 로그인 성공 후 홈 화면으로 이동
          Navigator.pushReplacementNamed(context, '/user-home');
          return;
        } else if (authType == 'email') {
          // 기존 이메일 계정에 연동 처리
          final password = await _promptForPassword(context, googleUser.email);
          final emailCredential = EmailAuthProvider.credential(
            email: googleUser.email,
            password: password,
          );

          try {
            final emailUserCredential = await FirebaseAuth.instance.signInWithCredential(emailCredential);
            await emailUserCredential.user?.linkWithCredential(googleCredential);
            await _updateAuthTypeInFirestore(emailUserCredential.user!, 'google');

            // 로그인 성공 시 PreferencesManager에 사용자 정보 저장
            await _saveLoginInfo(emailUserCredential.user!, 'user');
            Navigator.pushReplacementNamed(context, '/user-home');
          } catch (e) {
            // 에러 처리
            state = state.copyWith(isLoading: false, errorMessage: '로그인에 실패했습니다: $e');
          }
          return;
        }
      } else {
        // Firestore에 해당 사용자가 없으면 새로운 사용자로 Google 로그인 처리
        final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
        final newUser = userCredential.user;

        if (newUser != null) {
          await _addUserToFirestore(newUser, isOwner); // Firestore에 사용자 정보 추가
          await _saveLoginInfo(newUser, 'user'); // 사용자 정보 저장
          Navigator.pushReplacementNamed(context, '/user-home');
        }
      }
    } catch (e) {
      // Google 로그인 실패 처리
      state = state.copyWith(isLoading: false, errorMessage: 'Google 로그인에 실패했습니다: $e');
    } finally {
      // 로딩 상태 종료
      state = state.copyWith(isLoading: false);
    }
  }

  // 사용자 로그인 정보를 PreferencesManager에 저장하는 함수
  Future<void> _saveLoginInfo(User user, String type) async {
    await PreferencesManager.instance.setEmail(user.email!);
    await PreferencesManager.instance.setType(type);
  }

  // Firestore에 사용자 정보를 추가하는 함수
  Future<void> _addUserToFirestore(User user, bool isOwner) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': user.displayName ?? 'null',
      'points': 0,
      'profilePicUrl': user.photoURL,
      'pubId': null,
      'authType': 'google',
      'type': isOwner ? 'owner' : 'customer',
      'uid': user.uid,
    });
  }

  // Firestore에서 사용자의 authType을 업데이트하는 함수
  Future<void> _updateAuthTypeInFirestore(User user, String authType) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
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

                // 하단 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(password);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('続行', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('別のアカウントでログイン'),
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

// SignInViewModel Provider 정의
final signinViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>(
  (ref) => SignInViewModel(),
);