// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserTransactionImpl _$$UserTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$UserTransactionImpl(
      transactionId: json['transactionId'] as String,
      senderEmail: json['senderEmail'] as String,
      receiverEmail: json['receiverEmail'] as String,
      amount: (json['amount'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$UserTransactionImplToJson(
        _$UserTransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'senderEmail': instance.senderEmail,
      'receiverEmail': instance.receiverEmail,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
