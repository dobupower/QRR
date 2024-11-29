// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoUploadImpl _$$PhotoUploadImplFromJson(Map<String, dynamic> json) =>
    _$PhotoUploadImpl(
      pubId: json['pubId'] as String? ?? '',
      ownerId: json['ownerId'] as String,
      logoUrl: json['logoUrl'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>)
          .map((e) => e as String?)
          .toList(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$$PhotoUploadImplToJson(_$PhotoUploadImpl instance) =>
    <String, dynamic>{
      'pubId': instance.pubId,
      'ownerId': instance.ownerId,
      'logoUrl': instance.logoUrl,
      'photoUrls': instance.photoUrls,
      'message': instance.message,
    };
