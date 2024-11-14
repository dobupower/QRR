// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionHistoryImpl _$$TransactionHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionHistoryImpl(
      name: json['name'] as String,
      transactionType: json['transactionType'] as String,
      points: (json['points'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$TransactionHistoryImplToJson(
        _$TransactionHistoryImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'transactionType': instance.transactionType,
      'points': instance.points,
      'timestamp': instance.timestamp.toIso8601String(),
    };
