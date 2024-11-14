import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_history_model.freezed.dart';
part 'transaction_history_model.g.dart';

@freezed
class TransactionHistory with _$TransactionHistory {
  const factory TransactionHistory({
    required String name,             // 거래 상대방의 이름
    required String transactionType,   // 거래 유형 (예: '송금', '수신' 등)
    required int points,               // 거래된 포인트 양
    required DateTime timestamp,       // 거래 시간
  }) = _TransactionHistory;

  factory TransactionHistory.fromJson(Map<String, dynamic> json) => _$TransactionHistoryFromJson(json);
}
