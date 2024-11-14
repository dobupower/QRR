import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/owner_model.dart';
import '../services/auth_service.dart';
import 'dart:math';
import '../view/sign-up/photo_upload_screen.dart';
import 'photo_upload_view_model.dart';

/// [SignUpState]는 회원가입 화면의 상태를 관리하는 클래스입니다.
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
  final TextEditingController codeController; // 인증 코드 입력 필드 컨트롤러

  // 인증 코드와 에러 메시지, 로딩 상태 등을 위한 변수들
  final String? verificationCode;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isLoading;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? verificationErrorMessage;

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
    required this.codeController,
    this.verificationCode,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.verificationErrorMessage,
  });

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

  SignUpState copyWith({
    TextEditingController? codeController,
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
    String? verificationErrorMessage,
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
      codeController: codeController ?? this.codeController,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      verificationErrorMessage: verificationErrorMessage ?? this.verificationErrorMessage,
    );
  }
}

/// [OwnerSignUpViewModel]은 회원가입 로직을 관리하는 클래스입니다.
class OwnerSignUpViewModel extends StateNotifier<SignUpState> {
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  OwnerSignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        super(SignUpState(
          codeController: TextEditingController(),
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

  // 각 컨트롤러와 상태 관리를 위해 dispose 필요
  @override
  void dispose() {
    state.storeNameController.dispose();
    state.emailController.dispose();
    state.passwordController.dispose();
    state.confirmPasswordController.dispose();
    state.zipCodeController.dispose();
    state.stateController.dispose();
    state.cityController.dispose();
    state.addressController.dispose();
    state.buildingController.dispose();
    state.codeController.dispose();
    super.dispose();
  }

  void validateFields() {
    state = state.copyWith();
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
    if (state.confirmPasswordController.text.isNotEmpty) {
      validateConfirmPassword(state.confirmPasswordController.text);
    }
  }

  void validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != state.passwordController.text) {
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

  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  /// 회원가입 요청 함수
  Future<void> signUp(BuildContext context) async {
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true);
      try {
        final email = state.emailController.text;

        if (await _authService.OwnerisEmailAlreadyRegistered(email)) {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
          return;
        }

        final owner = Owner(
          uid: '',
          storeName: state.storeNameController.text,
          email: state.emailController.text,
          zipCode: state.zipCodeController.text,
          prefecture: state.stateController.text,
          city: state.cityController.text,
          address: state.addressController.text,
          building: state.buildingController.text.isNotEmpty ? state.buildingController.text : null,
          authType: 'email',
        );

        final verificationCode = _generateVerificationCode();
        state = state.copyWith(verificationCode: verificationCode);

        bool emailSent = await _authService.sendVerificationEmail(owner.email, verificationCode);

        if (emailSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoUploadScreen(owner: owner),
            ),
          );
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
      debugPrint('Form is not valid');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('입력된 정보를 확인해주세요。')),
      );
    }
  }

  /// 인증 코드 검증 함수
  Future<void> verifyCode(String inputCode, BuildContext context, Owner owner, WidgetRef ref) async {
    if (state.verificationCode == inputCode) {
      state = state.copyWith(verificationErrorMessage: null); // 오류 메시지 초기화

      try {
        final firebaseAuth = firebase_auth.FirebaseAuth.instance;

        // Firebase에서 계정 생성
        firebase_auth.UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: owner.email,
          password: state.passwordController.text,
        );

        // Firestore에 사용자 정보 저장
        await _authService.saveownerToFirestore(
          owner.copyWith(uid: userCredential.user!.uid).toMap(),
        );
        
        final photoUploadViewModel = ref.read(photoUploadViewModelProvider.notifier);
        await photoUploadViewModel.submitDetails(owner.uid);

        // 인증 완료 후 첫 화면으로 돌아감
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント登録が完了しました。')),
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          state = state.copyWith(emailError: 'このメールアドレスは既に登録されています。');
        } else {
          debugPrint('Firebase Auth error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ユーザー登録中にエラーが発生しました。')),
          );
        }
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

    if (state.emailController.text.isNotEmpty) {
      try {
        await _authService.sendVerificationEmail(state.emailController.text, newCode);
      } catch (e) {
        debugPrint('인증 코드 재전송 실패: $e');
      }
    }
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final ownersignUpViewModelProvider = StateNotifierProvider<OwnerSignUpViewModel, SignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return OwnerSignUpViewModel(authService);
  },
);
