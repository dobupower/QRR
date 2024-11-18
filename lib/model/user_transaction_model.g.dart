// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserTransactionImpl _$$UserTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$UserTransactionImpl(
      transactionId: json['transactionId'] as String,
      senderUid: json['senderUid'] as String,
      receiverUid: json['receiverUid'] as String,
      amount: (json['amount'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$UserTransactionImplToJson(
        _$UserTransactionImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'senderUid': instance.senderUid,
      'receiverUid': instance.receiverUid,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
    };
