// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignUpStateImpl _$$SignUpStateImplFromJson(Map<String, dynamic> json) =>
    _$SignUpStateImpl(
      verificationCode: json['verificationCode'] as String?,
      emailError: json['emailError'] as String?,
      passwordError: json['passwordError'] as String?,
      confirmPasswordError: json['confirmPasswordError'] as String?,
      verificationErrorMessage: json['verificationErrorMessage'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      type: json['type'] as String? ?? 'customer',
      isPasswordVisible: json['isPasswordVisible'] as bool? ?? false,
      isConfirmPasswordVisible:
          json['isConfirmPasswordVisible'] as bool? ?? false,
      selectedStore: json['selectedStore'] as String?,
    );

Map<String, dynamic> _$$SignUpStateImplToJson(_$SignUpStateImpl instance) =>
    <String, dynamic>{
      'verificationCode': instance.verificationCode,
      'emailError': instance.emailError,
      'passwordError': instance.passwordError,
      'confirmPasswordError': instance.confirmPasswordError,
      'verificationErrorMessage': instance.verificationErrorMessage,
      'isLoading': instance.isLoading,
      'type': instance.type,
      'isPasswordVisible': instance.isPasswordVisible,
      'isConfirmPasswordVisible': instance.isConfirmPasswordVisible,
      'selectedStore': instance.selectedStore,
    };
