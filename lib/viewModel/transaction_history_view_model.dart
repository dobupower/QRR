import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_history_model.dart';
import '../services/preferences_manager.dart';

class TransactionHistoryViewModel extends StateNotifier<AsyncValue<List<TransactionHistory>>> {
  TransactionHistoryViewModel() : super(const AsyncValue.loading()) {
    _fetchTransactionHistory();
  }

  // Firestore에서 거래 내역을 가져오는 함수
  Future<void> _fetchTransactionHistory() async {
    try {
      // 현재 사용자의 이메일을 가져와서 해당 이메일의 uid를 찾기
      final currentUserEmail = await PreferencesManager.instance.getEmail();
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // 사용자를 찾지 못한 경우 오류 처리
        state = AsyncValue.error('사용자를 찾을 수 없습니다.', StackTrace.current);
        return;
      }

      final currentUid = userSnapshot.docs.first.id;

      // 현재 사용자의 uid가 userId나 relatedUserId와 일치하는 거래 내역 가져오기
      final querySnapshot1 = await FirebaseFirestore.instance
          .collection('Transactions')
          .where('userId', isEqualTo: currentUid)
          .orderBy('timestamp', descending: true)
          .get();

      final querySnapshot2 = await FirebaseFirestore.instance
          .collection('Transactions')
          .where('relatedUserId', isEqualTo: currentUid)
          .orderBy('timestamp', descending: true)
          .get();

      // 두 쿼리 결과를 결합하고 중복 제거
      final combinedDocs = [
        ...querySnapshot1.docs,
        ...querySnapshot2.docs,
      ];

      final uniqueDocs = combinedDocs.toSet().toList()
        ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // 각 거래의 상대방 이름 가져오기
      final transactions = await Future.wait(uniqueDocs.map((doc) async {
        final data = doc.data();
        final userId = data['userId'] as String;
        final relatedUserId = data['relatedUserId'] as String;

        // 상대방 이름 설정
        String name = '';
        if (userId == currentUid) {
          // 내가 상대에게 포인트를 보낸 경우
          final relatedUserSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(relatedUserId)
              .get();
          name = relatedUserSnapshot.data()?['name'] ?? '알 수 없는 사용자';
        } else if (relatedUserId == currentUid) {
          // 상대가 나에게 포인트를 보낸 경우
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          name = userSnapshot.data()?['name'] ?? '알 수 없는 사용자';
        }

        return TransactionHistory(
          name: name,
          transactionType: data['type'] ?? '',
          points: data['amount'] ?? 0,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList());

      // 상태 업데이트
      state = AsyncValue.data(transactions);
    } catch (e) {
      // 오류 발생 시 오류 상태로 업데이트
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider 생성
final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryViewModel, AsyncValue<List<TransactionHistory>>>(
  (ref) => TransactionHistoryViewModel(),
);
