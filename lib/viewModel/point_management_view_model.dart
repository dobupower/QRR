import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart' as CustomTransaction; // 별칭을 지정
import 'qrcode_scan_view_model.dart'; // QR Code ViewModel에서 email 정보를 가져오기 위해

// Provider 설정
final transactionProvider = StateNotifierProvider<TransactionViewModel, CustomTransaction.Transaction?>((ref) {
  return TransactionViewModel();
});

class TransactionViewModel extends StateNotifier<CustomTransaction.Transaction?> {
  TransactionViewModel() : super(null);

  // 이메일 및 사용자 이름과 포인트 가져오기
  Future<void> fetchUserNameandEmail(WidgetRef ref) async {
    try {
      final email = ref.read(qrViewModelProvider)?.userId;

      if (email != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1) 
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userIdDoc = querySnapshot.docs.first;
          final data = userIdDoc.data();

          if (data != null && data.containsKey('name') && data.containsKey('points')) {
            final userName = data['name'] as String;
            final userPoint = data['points'] as int;
            // profilePicUrl이 없으면 null로 처리
            final profilePicUrl = data['profilePicUrl'] != null ? data['profilePicUrl'] as String : null;

            state = CustomTransaction.Transaction(
              transactionId: '',
              email: email,
              type: state?.type ?? 'チャージ',  // 기본 값
              amount: state?.amount ?? 0,
              timestamp: DateTime.now(),
              pubId: userName,  // 사용자 이름
              name: userName,
              point: userPoint,  // 포인트
              profilePicUrl: profilePicUrl ?? '', // 프로필 사진 URL
            );
          } else {
            print('사용자 정보를 찾을 수 없습니다.');
          }
        } else {
          print('해당 이메일을 가진 사용자가 없습니다.');
        }
      } else {
        print('이메일 정보가 없습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }



  // 거래 타입 업데이트 메서드 추가
  void updateTransactionType(String type) {
    if (state != null) {
      state = state!.copyWith(type: type); // 상태 복사 및 type 필드 업데이트
      print('선택된 거래 타입: ${state!.type}');
    }
  }

  // amount 값 업데이트
  void updateAmount(int newAmount) {
    if (state != null) {
      state = state!.copyWith(amount: newAmount); // 상태 복사 및 amount 필드 업데이트
      print('입력된 amount: ${state!.amount}');
    }
  }
}
