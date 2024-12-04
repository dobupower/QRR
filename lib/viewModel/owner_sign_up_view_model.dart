// owner_sign_up_view_model.dart
import 'dart:math';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위한 패키지
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/owner_signup_state_model.dart';
import '../model/owner_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerSignUpViewModel extends StateNotifier<OwnerSignUpState> {
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  OwnerSignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(OwnerSignUpState());

  // 상태 업데이트 메서드들
  void updateStoreName(String value) {
    state = state.copyWith(storeName: value);
  }

  void updateEmail(String value) {
    value = value.trim(); // 공백 제거
    state = state.copyWith(email: value);
    validateEmail(value);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
    validatePassword(value);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
    validateConfirmPassword(value);
  }

  void updateZipCode(String value) {
    state = state.copyWith(zipCode: value);
  }

  void updateState(String value) {
    state = state.copyWith(state: value);
  }

  void updateCity(String value) {
    state = state.copyWith(city: value);
  }

  void updateAddress(String value) {
    state = state.copyWith(address: value);
  }

  void updateBuilding(String value) {
    state = state.copyWith(building: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  // 검증 메서드들
  void validateEmail(String email) {
    print('Validating email: "$email"');
    const emailRegex =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
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
    if (state.confirmPassword.isNotEmpty) {
      validateConfirmPassword(state.confirmPassword);
    }
  }

  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.password) {
      state = state.copyWith(confirmPasswordError: 'パスワードが一致しません。');
    } else {
      state = state.copyWith(confirmPasswordError: null);
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  // 회원가입 요청 함수
  Future<void> signUp() async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true);
      try {
        final email = state.email;

        if (await _authService.OwnerisEmailAlreadyRegistered(email)) {
          state = state.copyWith(
              emailError: 'このメールアドレスは既に登録されています。', isLoading: false);
          return;
        }

        final owner = Owner(
          uid: '', // uid는 나중에 설정됩니다.
          storeName: state.storeName,
          email: state.email,
          zipCode: state.zipCode,
          prefecture: state.state,
          city: state.city,
          address: state.address,
          building:
              state.building?.isNotEmpty == true ? state.building : null,
          authType: 'email',
          pointLimit: 100000,
        );

        final verificationCode = _generateVerificationCode();
        state = state.copyWith(
          verificationCode: verificationCode,
          owner: owner, // Owner 객체를 상태에 저장
          signUpSuccess: true, // 회원가입 성공 이벤트 표시
        );

        await _authService.sendVerificationEmail(owner.email, verificationCode);
      } catch (e) {
        print('회원가입 오류: $e');
        state = state.copyWith(
          isLoading: false,
          signUpError: '회원가입 중 오류가 발생했습니다。',
        );
      } finally {
        state = state.copyWith(isLoading: false);
      }
    } else {
      print('Form is not valid');
      state = state.copyWith(
        signUpError: '입력된 정보를 확인해주세요。',
      );
    }
  }

  // 인증 코드 검증 함수
  Future<void> verifyCode(String inputCode) async {
    if (state.verificationCode == inputCode) {
      state = state.copyWith(verificationErrorMessage: null);
      try {
        // Firebase에서 계정 생성
        firebase_auth.UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );

        // owner 객체 생성
        final owner = state.owner!.copyWith(uid: userCredential.user!.uid);

        // Firestore에 사용자 정보 저장
        await _authService.saveownerToFirestore(owner.toJson());

        state = state.copyWith(
          verificationSuccess: true, // 인증 성공 이벤트 표시
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
        } else {
          debugPrint('Firebase Auth error: $e');
          state = state.copyWith(
            verificationErrorMessage: 'ユーザー登録中にエラーが発生しました。',
          );
        }
      } catch (e) {
        debugPrint('Error during authentication or Firestore saving: $e');
        state = state.copyWith(
          verificationErrorMessage: 'ユーザー登録中にエラーが発生しました。',
        );
      }
    } else {
      state = state.copyWith(verificationErrorMessage: '認証コードが正しくありません。');
    }
  }

  // 코드 재전송 함수
  Future<void> resendVerificationCode() async {
    final newCode = _generateVerificationCode();
    state = state.copyWith(verificationCode: newCode);

    if (state.email.isNotEmpty) {
      try {
        await _authService.sendVerificationEmail(state.email, newCode);
        state = state.copyWith(resendCodeSuccess: true); // 코드 재전송 성공 이벤트
      } catch (e) {
        debugPrint('인증 코드 재전송 실패: $e');
        state = state.copyWith(
          resendCodeError: '인증 코드 재전송 실패',
        );
      }
    }
  }

  // 이벤트 플래그 리셋 메서드
  void resetSignUpSuccess() {
    state = state.copyWith(signUpSuccess: false);
  }

  void resetSignUpError() {
    state = state.copyWith(signUpError: null);
  }

  void resetVerificationSuccess() {
    state = state.copyWith(verificationSuccess: false);
  }

  void resetVerificationError() {
    state = state.copyWith(verificationErrorMessage: null);
  }

  void resetResendCodeSuccess() {
    state = state.copyWith(resendCodeSuccess: false);
  }

  void resetResendCodeError() {
    state = state.copyWith(resendCodeError: null);
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final ownerSignUpViewModelProvider =
    StateNotifierProvider<OwnerSignUpViewModel, OwnerSignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return OwnerSignUpViewModel(authService);
  },
);
