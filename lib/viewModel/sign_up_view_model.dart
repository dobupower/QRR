import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In 사용
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용
import 'dart:math';
import '../model/user_model.dart';
import '../services/auth_service.dart';

// 회원가입 화면 상태를 관리하는 SignUpState 클래스
class SignUpState {
  final TextEditingController nameController; // 사용자 이름 입력 필드 컨트롤러
  final TextEditingController emailController; // 이메일 입력 필드 컨트롤러
  final TextEditingController passwordController; // 비밀번호 입력 필드 컨트롤러
  final TextEditingController confirmPasswordController; // 비밀번호 확인 입력 필드 컨트롤러
  final TextEditingController codeController; // 인증 코드 입력 필드 컨트롤러

  final String? verificationCode; // 서버에서 생성된 인증 코드
  final String? emailError; // 이메일 유효성 검사 오류 메시지
  final String? passwordError; // 비밀번호 유효성 검사 오류 메시지
  final String? confirmPasswordError; // 비밀번호 확인 유효성 검사 오류 메시지
  final String? verificationErrorMessage; // 인증 코드 오류 메시지
  final bool isLoading; // 로딩 상태
  final String type; // 사용자 유형 ('customer' or 'owner')
  final User? user; // 사용자 정보
  final bool isPasswordVisible; // 비밀번호 가시성 상태
  final bool isConfirmPasswordVisible; // 비밀번호 확인 가시성 상태

  // 생성자
  SignUpState({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.codeController,
    this.verificationCode,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.verificationErrorMessage,
    this.isLoading = false,
    this.type = 'customer',
    this.user,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  // 폼의 유효성을 판단하는 getter
  bool get isFormValid {
    return emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  // SignUpState의 복사본을 생성하여 상태를 업데이트
  SignUpState copyWith({
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? codeController,
    String? verificationCode,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? verificationErrorMessage,
    bool? isLoading,
    String? type,
    User? user,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpState(
      nameController: nameController ?? this.nameController,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController: confirmPasswordController ?? this.confirmPasswordController,
      codeController: codeController ?? this.codeController,
      verificationCode: verificationCode ?? this.verificationCode,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      verificationErrorMessage: verificationErrorMessage ?? this.verificationErrorMessage,
      isLoading: isLoading ?? this.isLoading,
      type: type ?? this.type,
      user: user ?? this.user,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

// SignUpViewModel: 회원가입 및 로그인 로직을 처리하는 클래스
class SignUpViewModel extends StateNotifier<SignUpState> {
  final AuthService _authService; // 인증 서비스 의존성 주입
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // 생성자
  SignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn(),
        super(SignUpState(
          nameController: TextEditingController(),
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          codeController: TextEditingController(),
        ));

  // 이메일 유효성 검사
  void validateEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

    // 이메일 형식이 올바른지 확인
    if (!RegExp(emailRegex).hasMatch(email)) {
      state = state.copyWith(emailError: '正しいメールアドレスを入力してください。');
    } else {
      state = state.copyWith(emailError: null); // 유효한 경우 에러 메시지 제거
    }
  }

  // 비밀번호 유효성 검사 (8자 이상)
  void validatePassword(String password) {
    if (password.length < 8) {
      state = state.copyWith(passwordError: 'パスワードは8文字以上である必要があります。');
    } else {
      state = state.copyWith(passwordError: null); // 유효한 경우 에러 메시지 제거
    }

    // 비밀번호 확인도 다시 검사
    if (state.confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(state.confirmPasswordController.text);
    }
  }

  // 비밀번호 확인 유효성 검사 (비밀번호와 일치하는지 확인)
  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.passwordController.text) {
      state = state.copyWith(confirmPasswordError: 'パスワードが一致しません。');
    } else {
      state = state.copyWith(confirmPasswordError: null); // 유효한 경우 에러 메시지 제거
    }
  }

  // 비밀번호 가시성 토글
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 비밀번호 확인 가시성 토글
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  // 사용자 유형 설정 (고객 또는 소유자)
  void setType(bool isOwner) {
    state = state.copyWith(type: isOwner ? 'owner' : 'customer');
  }

  // 사용자 스토어 업데이트
  void updateUserStore(User user, String pubId) {
    user.pubId = pubId;
    state = state.copyWith(user: user);
  }

  // 회원가입 처리
  Future<void> signUp(BuildContext context) async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true); // 로딩 상태 업데이트

      try {
        final email = state.emailController.text;

        // 이메일 중복 확인
        if (await _authService.isEmailAlreadyRegistered(email)) {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
          return;
        }

        // 사용자 정보 생성 (authType에 'email' 값을 설정)
        final user = User(
          uid: '',
          name: state.nameController.text,
          email: state.emailController.text,
          points: 0,
          type: state.type,
          authType: 'email', // authType 필드에 'email' 값 설정
        );

        // 인증 코드 생성 및 저장
        final verificationCode = _generateVerificationCode();
        state = state.copyWith(verificationCode: verificationCode);

        // 인증 이메일 발송
        bool emailSent = await _authService.sendVerificationEmail(user.email, verificationCode);

        if (emailSent) {
          Navigator.pushNamed(context, '/store-selection', arguments: user);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('認証コードを送信しました。メールを確認してください。')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이메일 전송에 실패했습니다。')),
          );
        }
      } catch (e) {
        debugPrint('회원가입 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 중 오류가 발생했습니다。')),
        );
      } finally {
        state = state.copyWith(isLoading: false); // 로딩 상태 종료
      }
    } else {
      debugPrint('Form is not valid');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('입력된 정보를 확인해주세요。')),
      );
    }
  }

  // 인증 코드 생성 (4자리 랜덤 숫자)
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  // 인증 코드 확인
  Future<void> verifyCode(String inputCode, BuildContext context, User user) async {
    if (state.verificationCode == inputCode) {
      state = state.copyWith(verificationErrorMessage: null); // 오류 메시지 초기화

      try {
        final firebaseAuth = firebase_auth.FirebaseAuth.instance;

        // Firebase에서 계정 생성
        firebase_auth.UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: user.email,
          password: state.passwordController.text,
        );

        // Firestore에 사용자 정보 저장
        await _authService.saveUserToFirestore(
          user.copyWith(uid: userCredential.user!.uid).toMap(),
        );

        // 인증 완료 후 첫 화면으로 돌아감
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント登録が完了しました。')),
        );
      } catch (e) {
        debugPrint('Error during authentication or Firestore saving: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ユーザー登録中にエラーが発生しました。')),
        );
      }
    } else {
      state = state.copyWith(verificationErrorMessage: '認証コードが正しくありません。');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('認証に失敗しました。')),
      );
    }
  }

  // 인증 코드 재전송
  Future<void> resendVerificationCode() async {
    final newCode = _generateVerificationCode();
    state = state.copyWith(verificationCode: newCode);

    if (state.emailController.text.isNotEmpty) {
      try {
        await _authService.sendVerificationEmail(state.emailController.text, newCode);
      } catch (e) {
        debugPrint('인증 코드 재전송 실패: $e');
      }
    }
  }

  // Google 로그인 처리
  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 Google 로그인 취소
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 인증 및 로그인
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final email = firebaseUser.email;
        if (email == null) {
          throw Exception('Google 계정에 이메일이 없습니다.');
        }

        final querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();

        if (querySnapshot.docs.isEmpty) {
          // Firestore에 사용자 정보가 없으면 새로운 사용자로 등록
          final newUser = User(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Anonymous',
            email: firebaseUser.email!,
            points: 0,
            type: state.type,
            authType: 'google', // Google로 로그인한 사용자
            profilePicUrl: firebaseUser.photoURL,
          );

          await _authService.saveUserToFirestore(newUser.toMap());

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // 이미 존재하는 사용자일 경우 authType 확인
          final existingUser = querySnapshot.docs.first.data();
          final authType = existingUser['authType'];

          if (authType == 'google') {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('다른 방식으로 로그인해주세요。')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Google 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인에 실패했습니다。')),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// AuthService 의존성 주입
final authServiceProvider = Provider((ref) => AuthService());

// SignUpViewModel 제공
final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignUpViewModel(authService);
  },
);