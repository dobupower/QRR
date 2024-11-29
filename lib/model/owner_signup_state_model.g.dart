// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_signup_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OwnerSignUpStateImpl _$$OwnerSignUpStateImplFromJson(
        Map<String, dynamic> json) =>
    _$OwnerSignUpStateImpl(
      storeName: json['storeName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      confirmPassword: json['confirmPassword'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      building: json['building'] as String?,
      emailError: json['emailError'] as String?,
      passwordError: json['passwordError'] as String?,
      confirmPasswordError: json['confirmPasswordError'] as String?,
      verificationErrorMessage: json['verificationErrorMessage'] as String?,
      isPasswordVisible: json['isPasswordVisible'] as bool? ?? false,
      isConfirmPasswordVisible:
          json['isConfirmPasswordVisible'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      verificationCode: json['verificationCode'] as String?,
      owner: json['owner'] == null
          ? null
          : Owner.fromJson(json['owner'] as Map<String, dynamic>),
      signUpSuccess: json['signUpSuccess'] as bool? ?? false,
      signUpError: json['signUpError'] as String?,
      verificationSuccess: json['verificationSuccess'] as bool? ?? false,
      resendCodeSuccess: json['resendCodeSuccess'] as bool? ?? false,
      resendCodeError: json['resendCodeError'] as String?,
    );

Map<String, dynamic> _$$OwnerSignUpStateImplToJson(
        _$OwnerSignUpStateImpl instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'zipCode': instance.zipCode,
      'state': instance.state,
      'city': instance.city,
      'address': instance.address,
      'building': instance.building,
      'emailError': instance.emailError,
      'passwordError': instance.passwordError,
      'confirmPasswordError': instance.confirmPasswordError,
      'verificationErrorMessage': instance.verificationErrorMessage,
      'isPasswordVisible': instance.isPasswordVisible,
      'isConfirmPasswordVisible': instance.isConfirmPasswordVisible,
      'isLoading': instance.isLoading,
      'verificationCode': instance.verificationCode,
      'owner': instance.owner,
      'signUpSuccess': instance.signUpSuccess,
      'signUpError': instance.signUpError,
      'verificationSuccess': instance.verificationSuccess,
      'resendCodeSuccess': instance.resendCodeSuccess,
      'resendCodeError': instance.resendCodeError,
    };
