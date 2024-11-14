import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/signup_state_model.dart';
import '../services/auth_service.dart';
import 'dart:math';

class SignUpViewModel extends StateNotifier<SignUpState> {
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  SignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn(),
        super(
          SignUpState(
            nameController: TextEditingController(),
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            confirmPasswordController: TextEditingController(),
            codeController: TextEditingController(),
          ),
        );

  @override
  void dispose() {
    // 컨트롤러 메모리 누수를 방지하기 위해 dispose 호출
    state.nameController?.dispose();
    state.emailController?.dispose();
    state.passwordController?.dispose();
    state.confirmPasswordController?.dispose();
    state.codeController?.dispose();
    super.dispose();
  }

  void validateEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email)) {
      state = state.copyWith(emailError: '正しいメールアドレスを入力してください。');
    } else {
      state = state.copyWith(emailError: null);
    }
  }

  void validatePassword(String password) {
    if (password.length < 8) {
      state = state.copyWith(passwordError: 'パスワードは8文字以上である必要があります。');
    } else {
      state = state.copyWith(passwordError: null);
    }
    if (state.confirmPasswordController?.text.isNotEmpty == true) {
      validateConfirmPassword(state.confirmPasswordController!.text);
    }
  }

  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.passwordController?.text) {
      state = state.copyWith(confirmPasswordError: 'パスワードが一致しません。');
    } else {
      state = state.copyWith(confirmPasswordError: null);
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void setType(bool isOwner) {
    state = state.copyWith(type: isOwner ? 'owner' : 'customer');
  }

  void updateSelectedStore(String storeName) {
    state = state.copyWith(selectedStore: storeName);
  }

  void updateUserStore(User user, String pubId) {
    User updatedUser = user.copyWith(pubId: pubId);
    _authService.saveUserToFirestore(updatedUser.toMap());
  }

  Future<void> signUp(BuildContext context) async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true);
      try {
        final email = state.emailController?.text ?? '';
        if (await _authService.isEmailAlreadyRegistered(email)) {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
          return;
        }
        String uid = await _authService.generateUniqueUID();
        final user = User(
          uid: uid,
          name: state.nameController?.text ?? '',
          email: email,
          points: 0,
          authType: 'email',
          pubId: '',
        );
        final verificationCode = _generateVerificationCode();
        state = state.copyWith(verificationCode: verificationCode);
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
        state = state.copyWith(isLoading: false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('입력된 정보를 확인해주세요。')),
      );
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  Future<void> verifyCode(String inputCode, BuildContext context, User user) async {
    if (state.verificationCode == inputCode) {
      state = state.copyWith(verificationErrorMessage: null);
      try {
        firebase_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: user.email,
          password: state.passwordController?.text ?? '',
        );
        final updatedUser = user.copyWith(
          uid: user.uid,
          pubId: state.selectedStore,
        );
        await _authService.saveUserToFirestore(updatedUser.toMap());
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

  Future<void> resendVerificationCode() async {
    final newCode = _generateVerificationCode();
    state = state.copyWith(verificationCode: newCode);
    if (state.emailController?.text.isNotEmpty == true) {
      try {
        await _authService.sendVerificationEmail(state.emailController!.text, newCode);
      } catch (e) {
        debugPrint('인증 코드 재전송 실패: $e');
      }
    }
  }
}

// AuthService 의존성 주입
final authServiceProvider = Provider((ref) => AuthService());

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignUpViewModel(authService);
  },
);
