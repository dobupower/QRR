// owner_signup_state_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'owner_model.dart';

part 'owner_signup_state_model.freezed.dart';
part 'owner_signup_state_model.g.dart'; // JSON 직렬화를 사용할 경우 추가

@freezed
class OwnerSignUpState with _$OwnerSignUpState {
  const factory OwnerSignUpState({
    @Default('') String storeName,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String zipCode,
    @Default('') String state,
    @Default('') String city,
    @Default('') String address,
    String? building,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? verificationErrorMessage,
    @Default(false) bool isPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    @Default(false) bool isLoading,
    String? verificationCode,
    Owner? owner,
    @Default(false) bool signUpSuccess,
    String? signUpError,
    @Default(false) bool verificationSuccess,
    @Default(false) bool resendCodeSuccess,
    String? resendCodeError,
  }) = _OwnerSignUpState;

  factory OwnerSignUpState.fromJson(Map<String, dynamic> json) =>
      _$OwnerSignUpStateFromJson(json);
}

extension OwnerSignUpStateExtension on OwnerSignUpState {
  bool get isFormValid =>
      storeName.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      zipCode.isNotEmpty &&
      state.isNotEmpty &&
      city.isNotEmpty &&
      address.isNotEmpty &&
      emailError == null &&
      passwordError == null &&
      confirmPasswordError == null;
}
