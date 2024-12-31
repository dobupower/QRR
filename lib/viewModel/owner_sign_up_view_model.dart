import 'dart:math';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위한 패키지
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/owner_signup_state_model.dart';
import '../model/owner_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// OwnerSignUpViewModel은 OwnerSignUpState 상태를 관리하는 클래스
class OwnerSignUpViewModel extends StateNotifier<OwnerSignUpState> {
  final AuthService _authService; // AuthService 인스턴스
  final firebase_auth.FirebaseAuth _firebaseAuth; // FirebaseAuth 인스턴스
  final FirebaseFirestore _firestore; // FirebaseFirestore 인스턴스

  // 생성자 - AuthService 인스턴스를 의존성 주입받음
  OwnerSignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(OwnerSignUpState());

  // 상태 업데이트 메서드들

  // 매장 이름 업데이트
  void updateStoreName(String value) {
    state = state.copyWith(storeName: value);
  }

  // 이메일 업데이트 및 검증
  void updateEmail(String value, BuildContext context) {
    value = value.trim(); // 공백 제거
    state = state.copyWith(email: value);
    validateEmail(value, context);
  }

  // 비밀번호 업데이트 및 검증
  void updatePassword(String value, BuildContext context) {
    state = state.copyWith(password: value);
    validatePassword(value, context);
  }

  // 비밀번호 확인 업데이트 및 검증
  void updateConfirmPassword(String value, BuildContext context) {
    state = state.copyWith(confirmPassword: value);
    validateConfirmPassword(value, context);
  }

  // 우편번호 업데이트
  void updateZipCode(String value) {
    state = state.copyWith(zipCode: value);
  }

  // 주(state) 업데이트
  void updateState(String value) {
    state = state.copyWith(state: value);
  }

  // 도시(city) 업데이트
  void updateCity(String value) {
    state = state.copyWith(city: value);
  }

  // 주소(address) 업데이트
  void updateAddress(String value) {
    state = state.copyWith(address: value);
  }

  // 건물(building) 업데이트
  void updateBuilding(String value) {
    state = state.copyWith(building: value);
  }

  // 비밀번호 가시성 토글
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 비밀번호 확인 가시성 토글
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  // 검증 메서드들

  // 이메일 검증
  void validateEmail(String email, BuildContext context) {
    print('Validating email: "$email"');
    const emailRegex =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email)) {
      state = state.copyWith(emailError: AppLocalizations.of(context)?.ownerSignUpViewModelEmailError ?? '');
    } else {
      state = state.copyWith(emailError: null);
    }
  }

  // 비밀번호 검증
  void validatePassword(String password, BuildContext context) {
    if (password.length < 8) {
      state = state.copyWith(passwordError: AppLocalizations.of(context)?.ownerSignUpViewModelPasswordError1 ?? '');
    } else {
      state = state.copyWith(passwordError: null);
    }
    if (state.confirmPassword.isNotEmpty) {
      validateConfirmPassword(state.confirmPassword, context);
    }
  }

  // 비밀번호 확인 검증
  void validateConfirmPassword(String confirmPassword, BuildContext context) {
    if (confirmPassword != state.password) {
      state = state.copyWith(confirmPasswordError: AppLocalizations.of(context)?.ownerSignUpViewModelPasswordError2 ?? '');
    } else {
      state = state.copyWith(confirmPasswordError: null);
    }
  }

  // 인증 코드 생성
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  // 회원가입 요청 함수
  Future<void> signUp(BuildContext context) async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true);
      try {
        final email = state.email;

        // 이메일 중복 체크
        if (await _authService.OwnerisEmailAlreadyRegistered(email, context)) {
          state = state.copyWith(
              emailError: AppLocalizations.of(context)?.ownerSignUpViewModelEmailAllready ?? '', isLoading: false);
          return;
        }

        // Owner 객체 생성
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

        // 인증 코드 생성
        final verificationCode = _generateVerificationCode();
        state = state.copyWith(
          verificationCode: verificationCode,
          owner: owner, // Owner 객체를 상태에 저장
          signUpSuccess: true, // 회원가입 성공 이벤트 표시
        );

        // 인증 이메일 전송
        await _authService.sendVerificationEmail(owner.email, verificationCode, context);
      } catch (e) {
        print('회원가입 오류: $e');
        state = state.copyWith(
          isLoading: false,
          signUpError: AppLocalizations.of(context)?.ownerSignUpViewModelSignupError1 ?? '',
        );
      } finally {
        state = state.copyWith(isLoading: false);
      }
    } else {
      print('Form is not valid');
      state = state.copyWith(
        signUpError: AppLocalizations.of(context)?.ownerSignUpViewModelSignupError2 ?? '',
      );
    }
  }

  // 인증 코드 검증 함수
  Future<void> verifyCode(String inputCode, BuildContext context) async {
    final localizations = AppLocalizations.of(context);
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
          state = state.copyWith(emailError: localizations?.ownerSignUpViewModelEmailAllready ?? '');
        } else {
          debugPrint('Firebase Auth error: $e');
          state = state.copyWith(
            verificationErrorMessage: localizations?.ownerSignUpViewModelSignupError3 ?? '',
          );
        }
      } catch (e) {
        debugPrint('Error during authentication or Firestore saving: $e');
        state = state.copyWith(
          verificationErrorMessage: localizations?.ownerSignUpViewModelSignupError3 ?? '',
        );
      }
    } else {
      state = state.copyWith(verificationErrorMessage: localizations?.ownerSignUpViewModelCodeError ?? '');
      print('verificationErrorMessage');
    }
  }

  // 코드 재전송 함수
  Future<void> resendVerificationCode(BuildContext context) async {
    final newCode = _generateVerificationCode();
    state = state.copyWith(verificationCode: newCode);

    if (state.email.isNotEmpty) {
      try {
        await _authService.sendVerificationEmail(state.email, newCode, context);
        state = state.copyWith(resendCodeSuccess: true); // 코드 재전송 성공 이벤트
      } catch (e) {
        state = state.copyWith(
          resendCodeError: AppLocalizations.of(context)?.ownerSignUpViewModelCodeRetransmissionFail ?? '',
        );
      }
    }
  }

  // 이벤트 플래그 리셋 메서드들
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

  // Firestore에서 owner 정보 업데이트
  Future<void> updateOwnerInfo() async {
    try {
      // 현재 사용자 이메일 가져오기
      final email = await PreferencesManager.instance.getEmail();

      // email 필드로 Firestore에서 문서를 검색
      final querySnapshot = await _firestore
          .collection('Owners')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 문서 ID 가져오기
        final docId = querySnapshot.docs.first.id;

        // 업데이트할 데이터 준비 (null 값은 제외)
        final updatedData = {
          if (state.storeName != null && state.storeName!.isNotEmpty) 'storeName': state.storeName,
          if (state.zipCode != null && state.zipCode!.isNotEmpty) 'zipCode': state.zipCode,
          if (state.state != null && state.state!.isNotEmpty) 'state': state.state,
          if (state.city != null && state.city!.isNotEmpty) 'city': state.city,
          if (state.address != null && state.address!.isNotEmpty) 'address': state.address,
          if (state.building != null && state.building!.isNotEmpty) 'building': state.building,
        };

        if (updatedData.isNotEmpty) {
          // 문서 업데이트
          await _firestore.collection('Owners').doc(docId).update(updatedData);
        } else {
          state = state.copyWith(signUpError: '업데이트할 데이터가 없습니다。');
        }
      } else {
        state = state.copyWith(signUpError: '등록된 이메일을 찾을 수 없습니다。');
      }
    } catch (e) {
      state = state.copyWith(
        signUpError: '정보 업데이트 중 오류가 발생했습니다。',
      );
    }
  }
}

// AuthService를 provider로 제공
final authServiceProvider = Provider((ref) => AuthService());

// OwnerSignUpViewModel을 Provider로 제공
final ownerSignUpViewModelProvider =
    StateNotifierProvider<OwnerSignUpViewModel, OwnerSignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return OwnerSignUpViewModel(authService);
  },
);
