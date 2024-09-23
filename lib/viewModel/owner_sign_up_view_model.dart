import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/owner_model.dart';
import '../services/auth_service.dart';
import 'dart:math';

/// [SignUpState]는 회원가입 화면의 상태를 관리하는 클래스입니다.
/// 각 입력 필드의 상태, 에러 메시지, 비밀번호 표시 여부, 로딩 상태 등을 포함하고 있습니다.
class SignUpState {
  // 각 입력 필드의 컨트롤러
  final TextEditingController storeNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController zipCodeController;
  final TextEditingController stateController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController buildingController;

  // 인증 코드와 에러 메시지, 로딩 상태 등을 위한 변수들
  final String? verificationCode; // 서버에서 생성된 인증 코드
  final String? emailError;       // 이메일 오류 메시지
  final String? passwordError;    // 비밀번호 오류 메시지
  final String? confirmPasswordError; // 비밀번호 확인 오류 메시지
  final bool isLoading;           // 로딩 상태
  final bool isPasswordVisible;   // 비밀번호 가시성 상태
  final bool isConfirmPasswordVisible; // 비밀번호 확인 가시성 상태

  // 생성자: 초기 상태 값 설정
  SignUpState({
    required this.storeNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.zipCodeController,
    required this.stateController,
    required this.cityController,
    required this.addressController,
    required this.buildingController,
    this.verificationCode,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  /// 입력된 폼 데이터가 모두 유효한지 검사하는 getter 함수
  bool get isFormValid {
    return emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        storeNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        zipCodeController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        addressController.text.isNotEmpty;
  }

  /// 상태 값을 복사하고, 선택적으로 새로운 값을 제공하여 상태를 업데이트하는 copyWith 함수
  SignUpState copyWith({
    TextEditingController? storeNameController,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? zipCodeController,
    TextEditingController? stateController,
    TextEditingController? cityController,
    TextEditingController? addressController,
    TextEditingController? buildingController,
    String? verificationCode,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? isLoading,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignUpState(
      storeNameController: storeNameController ?? this.storeNameController,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController: confirmPasswordController ?? this.confirmPasswordController,
      zipCodeController: zipCodeController ?? this.zipCodeController,
      stateController: stateController ?? this.stateController,
      cityController: cityController ?? this.cityController,
      addressController: addressController ?? this.addressController,
      buildingController: buildingController ?? this.buildingController,
      verificationCode: verificationCode ?? this.verificationCode,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

/// [OwnerSignUpViewModel]은 회원가입 로직을 관리하는 클래스입니다.
/// 이메일, 비밀번호 검증 로직, 회원가입 요청 및 인증 코드 발송 등의 기능을 제공합니다.
class OwnerSignUpViewModel extends StateNotifier<SignUpState> {
  // 인증 관련 서비스, Firebase Auth, Firestore 인스턴스
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // 생성자: 상태와 서비스 초기화
  OwnerSignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(SignUpState(
          storeNameController: TextEditingController(),
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          confirmPasswordController: TextEditingController(),
          zipCodeController: TextEditingController(),
          stateController: TextEditingController(),
          cityController: TextEditingController(),
          addressController: TextEditingController(),
          buildingController: TextEditingController(),
        ));

  // 각 입력 필드의 유효성을 검사하는 함수
  void validateFields() {
    state = state.copyWith();
  }

  // 이메일 형식을 검증하는 함수
  void validateEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email)) {
      state = state.copyWith(emailError: '正しいメールアドレスを入力してください。');
    } else {
      state = state.copyWith(emailError: null);
    }
  }

  // 비밀번호 유효성을 검증하는 함수
  void validatePassword(String password) {
    if (password.length < 8) {
      state = state.copyWith(passwordError: 'パスワードは8文字以上である必要があります。');
    } else {
      state = state.copyWith(passwordError: null);
    }
    if (state.confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(state.confirmPasswordController.text);
    }
  }

  // 비밀번호 확인 필드 검증 함수
  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.passwordController.text) {
      state = state.copyWith(confirmPasswordError: 'パスワードが一致しません。');
    } else {
      state = state.copyWith(confirmPasswordError: null);
    }
  }

  // 비밀번호 표시 여부를 전환하는 함수
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 비밀번호 확인 필드 표시 여부를 전환하는 함수
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  // 인증 코드 생성 함수 (4자리 랜덤 숫자)
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  /// 회원가입 요청 함수
  /// 폼 검증이 완료되면, 인증 이메일을 발송하고 화면 전환을 처리합니다.
  Future<void> signUp(BuildContext context) async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true); // 로딩 상태 표시
      try {
        final email = state.emailController.text;

        // 이메일 중복 확인
        if (await _authService.isEmailAlreadyRegistered(email)) {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
          return;
        }

        // Owner 객체 생성
        final owner = Owner(
          uid: '',
          storeName: state.storeNameController.text,
          email: state.emailController.text,
          zipCode: state.zipCodeController.text,
          prefecture: state.stateController.text,
          city: state.cityController.text,
          address: state.addressController.text,
          building: state.buildingController.text.isNotEmpty ? state.buildingController.text : null,
          authType: 'email',  // 기본값으로 'email' 지정
          type: 'owner',      // 기본값으로 'owner' 지정
        );

        // 인증 코드 생성 및 상태 업데이트
        final verificationCode = _generateVerificationCode();
        state = state.copyWith(verificationCode: verificationCode);

        // 인증 이메일 발송
        bool emailSent = await _authService.sendVerificationEmail(owner.email, verificationCode);

        if (emailSent) {
          Navigator.pushNamed(context, '/PhotoUploadScreen', arguments: owner);  // 인증 성공 시 화면 전환
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
}

// AuthService 및 ViewModel 제공
final authServiceProvider = Provider((ref) => AuthService());

final ownersignUpViewModelProvider = StateNotifierProvider<OwnerSignUpViewModel, SignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return OwnerSignUpViewModel(authService);
  },
);
