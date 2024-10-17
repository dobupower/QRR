// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QrCodeImpl _$$QrCodeImplFromJson(Map<String, dynamic> json) => _$QrCodeImpl(
      token: json['token'] as String,
      createdAt: json['createdAt'] as String,
      expiryDate: json['expiryDate'] as String,
      isUsed: json['isUsed'] as bool,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$QrCodeImplToJson(_$QrCodeImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'createdAt': instance.createdAt,
      'expiryDate': instance.expiryDate,
      'isUsed': instance.isUsed,
      'userId': instance.userId,
    };
