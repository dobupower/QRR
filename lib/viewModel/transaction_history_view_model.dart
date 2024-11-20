import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_history_model.dart';
import '../services/preferences_manager.dart';

class TransactionHistoryNotifier extends StateNotifier<AsyncValue<List<TransactionHistory>>> {
  TransactionHistoryNotifier() : super(const AsyncValue.loading());

  // 페이지네이션 변수
  static const int pageSize = 10; // 한 번에 가져올 데이터 개수
  DocumentSnapshot? lastDocument; // 마지막 문서
  bool hasMoreData = true; // 추가 데이터 여부 확인

  Future<void> fetchUserTransactionHistory({bool isInitialLoad = false}) async {
    if (!isInitialLoad && !hasMoreData) {
      // 더 가져올 데이터가 없으면 종료
      return;
    }

    try {
      if (isInitialLoad) {
        state = const AsyncValue.loading();
        lastDocument = null;
        hasMoreData = true;
      }

      // 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        state = AsyncValue.error('사용자를 찾을 수 없습니다.', StackTrace.current);
        return;
      }

      final currentUid = userSnapshot.docs.first.id;

      // Firestore 쿼리
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where(
            Filter.or(
              Filter('userId', isEqualTo: currentUid),
              Filter('relatedUserId', isEqualTo: currentUid),
            ),
          )
          .orderBy('timestamp', descending: true) // 시간순 정렬
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!); // 이전 마지막 문서 이후 데이터 가져오기
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        hasMoreData = false; // 추가 데이터 없음

        if (isInitialLoad) {
          // 초기 로드에서 데이터가 없을 때 상태를 빈 리스트로 업데이트
          state = AsyncValue.data([]);
        }

        return;
      }

      lastDocument = querySnapshot.docs.last; // 마지막 문서 저장

      // 사용자 ID 수집
      Set<String> userIdsToFetch = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        final userId = data['userId'] as String?;
        final relatedUserId = data['relatedUserId'] as String?;
        if (userId != null) userIdsToFetch.add(userId);
        if (relatedUserId != null) userIdsToFetch.add(relatedUserId);
      }

      // 사용자 정보 가져오기
      Map<String, String> userNames = {};
      if (userIdsToFetch.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIdsToFetch.toList())
            .get();

        for (var doc in usersSnapshot.docs) {
          final userName = (doc.data() as Map<String, dynamic>?)?['name'] as String?;
          userNames[doc.id] = userName ?? '알 수 없는 사용자';
        }
      }

      // 거래 데이터 처리
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;

        final userId = data['userId'] as String? ?? '';
        final relatedUserId = data['relatedUserId'] as String? ?? '';
        final type = data['type'] as String? ?? '';
        final int points = data['amount'] ?? 0;

        String name = '';
        String message = '';
        int adjustedPoints = -points;

        if (type == 'チップ交換') {
          message = 'ポイントでチップを交換しました';
        } else if (type == 'チャージ') {
          message = 'ポイントをチャージしました';
          adjustedPoints = points;
        } else if (type == 'お支払い') {
          message = 'ポイントをお支払いしました';
        } else if (type == '') {
          if (userId == currentUid) {
            name = userNames[relatedUserId] ?? '알 수 없는 사용자';
            message = 'ポイントを $nameさんに送りました';
          } else if (relatedUserId == currentUid) {
            name = userNames[userId] ?? '알 수 없는 사용자';
            message = '$nameさんからポイントを受け取りました';
            adjustedPoints = points;
          }
        }

        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 기존 데이터와 중복 제거 후 병합
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) => newTransaction == transaction)),
        ...newTransactions,
      ];

      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> fetchOwnerTransactionHistory({bool isInitialLoad = false, DateTime? selectedDate}) async {
    if (!isInitialLoad && !hasMoreData) return;

    try {
      if (isInitialLoad) {
        state = const AsyncValue.loading();
        lastDocument = null;
        hasMoreData = true;
      }

      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // 기본 Firestore 쿼리
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where('relatedUserId', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      // 선택된 날짜로 필터링
      if (selectedDate != null) {
        final startOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day));
        final endOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        hasMoreData = false;

        if (isInitialLoad) {
          state = AsyncValue.data([]);
        }

        return;
      }

      lastDocument = querySnapshot.docs.last;

      // 필요한 모든 userId 수집
      Set<String> userIdsToFetch = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final userId = data?['userId'] as String?;
        if (userId != null) userIdsToFetch.add(userId);
      }

      // 사용자 정보 가져오기
      Map<String, String> userNames = {};
      if (userIdsToFetch.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIdsToFetch.toList())
            .get();

        for (var doc in usersSnapshot.docs) {
          userNames[doc.id] = (doc.data() as Map<String, dynamic>?)?['name'] ?? '알 수 없는 사용자';
        }
      }

      // 거래 데이터 처리
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;

        final userId = data['userId'] as String;
        final type = data['type'] as String? ?? '';
        final points = data['amount'] ?? 0;
        final name = userNames[userId] ?? '알 수 없는 사용자';
        int adjustedPoints = points;

        // 메시지 설정
        String message = '';
        if (type == 'チャージ') {
          message = '$name様のポイントをチャージしました';
          adjustedPoints = -points;
        } else if (type == 'お支払い') {
          message = '$name様がお支払いしました。';
        } else if (type == 'チップ交換') {
          message = '$name様がチップを交換しました';
        }

        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 기존 데이터와 병합
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) => newTransaction.timestamp == transaction.timestamp)),
        ...newTransactions,
      ];

      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider 생성
final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryNotifier, AsyncValue<List<TransactionHistory>>>(
  (ref) => TransactionHistoryNotifier(),
);
