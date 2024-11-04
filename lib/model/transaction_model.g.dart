// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      transactionId: json['transactionId'] as String,
      uid: json['uid'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      pubId: json['pubId'] as String,
      name: json['name'] as String,
      point: (json['point'] as num).toInt(),
      profilePicUrl: json['profilePicUrl'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'uid': instance.uid,
      'type': instance.type,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'pubId': instance.pubId,
      'name': instance.name,
      'point': instance.point,
      'profilePicUrl': instance.profilePicUrl,
      'email': instance.email,
    };
