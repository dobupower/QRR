import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'signup_state_model.freezed.dart';
part 'signup_state_model.g.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @JsonKey(ignore: true) TextEditingController? nameController,
    @JsonKey(ignore: true) TextEditingController? emailController,
    @JsonKey(ignore: true) TextEditingController? passwordController,
    @JsonKey(ignore: true) TextEditingController? confirmPasswordController,
    @JsonKey(ignore: true) TextEditingController? codeController,
    String? verificationCode,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? verificationErrorMessage,
    @Default(false) bool isLoading,
    @Default('customer') String type,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    String? selectedStore,
    @Default([]) List<String> stores, // 스토어 목록 기본값 설정
    @Default([]) List<String> filteredStores, // 검색된 스토어 목록 기본값 설정
  }) = _SignUpState;

  factory SignUpState.fromJson(Map<String, dynamic> json) => _$SignUpStateFromJson(json);
}

// 확장 함수로 isFormValid 정의
extension SignUpStateExtension on SignUpState {
  bool get isFormValid {
    return emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        nameController?.text.isNotEmpty == true &&
        emailController?.text.isNotEmpty == true &&
        passwordController?.text.isNotEmpty == true &&
        confirmPasswordController?.text.isNotEmpty == true;
  }
}
