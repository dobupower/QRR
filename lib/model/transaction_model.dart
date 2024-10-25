import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart'; // json serialization support

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String transactionId,
    required String email,              // 이메일
    required String type,               // 거래 타입 (ex. 'charge', 'deduct')
    required int amount,                 // 거래된 포인트
    required DateTime timestamp,  // 거래 시간
    required String pubId,
    required String name,
    required int point,
    required String profilePicUrl,
  }) = _Transaction;

  // JSON 직렬화 지원
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
