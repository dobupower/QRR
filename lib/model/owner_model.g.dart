// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OwnerImpl _$$OwnerImplFromJson(Map<String, dynamic> json) => _$OwnerImpl(
      uid: json['uid'] as String,
      storeName: json['storeName'] as String,
      email: json['email'] as String,
      zipCode: json['zipCode'] as String,
      prefecture: json['prefecture'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      building: json['building'] as String?,
      authType: json['authType'] as String? ?? 'email',
      type: json['type'] as String? ?? 'owner',
      pointLimit: (json['pointLimit'] as num?)?.toInt() ?? 100000,
    );

Map<String, dynamic> _$$OwnerImplToJson(_$OwnerImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'storeName': instance.storeName,
      'email': instance.email,
      'zipCode': instance.zipCode,
      'prefecture': instance.prefecture,
      'city': instance.city,
      'address': instance.address,
      'building': instance.building,
      'authType': instance.authType,
      'type': instance.type,
      'pointLimit': instance.pointLimit,
    };
