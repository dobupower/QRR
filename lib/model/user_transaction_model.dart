import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_transaction_model.freezed.dart';
part 'user_transaction_model.g.dart';

@freezed
class UserTransaction with _$UserTransaction {
  const factory UserTransaction({
    required String transactionId,       // 트랜잭션 고유 ID
    required String senderEmail,         // 보내는 사람 이메일
    required String receiverEmail,       // 받는 사람 이메일
    required int amount,              // 거래 금액
    required DateTime timestamp,         // 거래 발생 시각
  }) = _UserTransaction;

  // Firestore 데이터와 변환할 때 사용할 JSON 직렬화 메서드
  factory UserTransaction.fromJson(Map<String, dynamic> json) => _$UserTransactionFromJson(json);
}
extension UserTransactionExtensions on UserTransaction {
  // Firestore에 저장할 때 변환할 Map 형식
  Map<String, dynamic> toFirestore() {
    return {
      'transactionId': transactionId,
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}