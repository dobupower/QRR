import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_history_model.dart';
import '../services/preferences_manager.dart';

/// 거래 내역을 관리하는 StateNotifier 클래스
class TransactionHistoryNotifier extends StateNotifier<AsyncValue<List<TransactionHistory>>> {
  TransactionHistoryNotifier() : super(const AsyncValue.loading());

  static const int pageSize = 10; // 한 번에 가져올 데이터 개수
  DocumentSnapshot? lastDocument; // 페이지네이션에서 마지막으로 읽은 문서
  bool hasMoreData = true; // 추가 데이터 여부를 확인하는 플래그

  /// Firestore에서 거래 데이터를 조회하여 사용자 ID를 수집하는 메소드
  Future<Set<String>> _collectUserIds(QuerySnapshot querySnapshot) async {
    Set<String> userIdsToFetch = {}; // 중복을 방지하기 위해 Set 사용

    // 각 문서를 순회하며 사용자 ID를 수집
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?; // 문서 데이터를 Map 형태로 가져옴
      if (data == null) continue; // 데이터가 없으면 다음 문서로

      final userId = data['userId'] as String?; // 거래 주체의 사용자 ID
      final relatedUserId = data['relatedUserId'] as String?; // 거래 상대방의 사용자 ID

      if (userId != null) userIdsToFetch.add(userId); // 사용자 ID를 Set에 추가
      if (relatedUserId != null) userIdsToFetch.add(relatedUserId); // 상대방 ID를 Set에 추가
    }
    return userIdsToFetch; // 수집된 사용자 ID Set 반환
  }

  /// 수집된 사용자 ID로 Firestore에서 사용자 이름을 조회하는 메소드
  /// 사용자 ID를 키로, 사용자 이름을 값으로 하는 Map을 반환
  Future<Map<String, String>> _fetchUserNames(Set<String> userIds) async {
    Map<String, String> userNames = {}; // 사용자 ID와 이름을 저장할 Map

    if (userIds.isNotEmpty) {
      // 사용자 ID 목록이 비어있지 않을 때만 Firestore 쿼리 실행
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.toList()) // 문서 ID로 조회
          .get();

      // 각 문서에서 사용자 이름을 추출하여 Map에 저장
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final name = data?['name'] as String? ?? '알 수 없는 사용자';
        userNames[doc.id] = name; // 사용자 ID를 키로, 이름을 값으로 저장
      }
    }
    return userNames; // 사용자 ID와 이름의 Map 반환
  }

  /// 사용자 거래 내역을 가져오는 메소드
  Future<void> fetchUserTransactionHistory({bool isInitialLoad = false}) async {
    // 1. 추가 데이터가 없는 경우 메소드 종료
    if (!isInitialLoad && !hasMoreData) {
      return;
    }

    try {
      // 2. 초기 로드 시 상태 초기화
      if (isInitialLoad) {
        state = const AsyncValue.loading();
        lastDocument = null;
        hasMoreData = true;
      }

      // 3. 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // 4. 이메일로 Firestore에서 현재 사용자의 UID 가져오기
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get();

      // 5. 사용자가 존재하지 않는 경우 에러 처리
      if (userSnapshot.docs.isEmpty) {
        state = AsyncValue.error('사용자를 찾을 수 없습니다.', StackTrace.current);
        return;
      }

      // 6. 현재 사용자의 UID 추출
      final currentUid = userSnapshot.docs.first.id;

      // 7. 거래 데이터를 가져오기 위한 Firestore 쿼리 생성
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where(
            Filter.or(
              Filter('userId', isEqualTo: currentUid),
              Filter('relatedUserId', isEqualTo: currentUid),
            ),
          )
          .orderBy('timestamp', descending: true)
          .limit(pageSize);

      // 8. 페이지네이션을 위한 시작 지점 설정
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      // 9. Firestore에서 쿼리 실행하여 거래 데이터 가져오기
      final querySnapshot = await query.get();

      // 10. 가져온 거래 데이터가 없는 경우 처리
      if (querySnapshot.docs.isEmpty) {
        hasMoreData = false;
        if (isInitialLoad) {
          state = AsyncValue.data([]);
        }
        return;
      }

      // 11. 페이지네이션을 위해 마지막 문서 저장
      lastDocument = querySnapshot.docs.last;

      // 12. 거래 데이터에서 사용자 ID 수집
      final userIdsToFetch = await _collectUserIds(querySnapshot);

      // 13. 수집된 사용자 ID로 사용자 이름 가져오기
      final userNames = await _fetchUserNames(userIdsToFetch);

      // 14. 거래 데이터를 TransactionHistory 객체로 변환
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;

        final userId = data['userId'] as String? ?? '';
        final relatedUserId = data['relatedUserId'] as String? ?? '';
        final type = data['type'] as String? ?? '';
        final points = data['amount'] ?? 0;

        String name = '';
        String message = '';
        int adjustedPoints = -points;

        // 15. 거래 유형에 따라 메시지와 포인트 계산
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

        // 16. TransactionHistory 객체 생성
        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 17. 기존 상태와 새 데이터를 병합하여 중복 제거
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) =>
                  newTransaction.timestamp == transaction.timestamp &&
                  newTransaction.points == transaction.points)),
        ...newTransactions,
      ];

      // 18. 거래 내역을 시간순으로 정렬
      mergedTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 19. 상태를 갱신
      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      // 20. 에러 발생 시 상태를 에러로 전환
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 가맹점 소유자의 거래 내역을 가져오는 메소드
  Future<void> fetchOwnerTransactionHistory({bool isInitialLoad = false, DateTime? selectedDate}) async {
    // 1. 추가 데이터가 없는 경우 메소드 종료
    if (!isInitialLoad && !hasMoreData) {
      return;
    }

    try {
      // 2. 초기 로드 시 상태 초기화
      if (isInitialLoad) {
        state = const AsyncValue.loading();
        lastDocument = null;
        hasMoreData = true;
      }

      // 3. 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // 4. 거래 데이터를 가져오기 위한 Firestore 쿼리 생성
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where('relatedUserId', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .limit(pageSize);

      // 5. 페이지네이션을 위한 시작 지점 설정
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      // 6. 선택된 날짜로 거래 필터링
      if (selectedDate != null) {
        final startOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day));
        final endOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay);
      }

      // 7. Firestore에서 쿼리 실행하여 거래 데이터 가져오기
      final querySnapshot = await query.get();

      // 8. 가져온 거래 데이터가 없는 경우 처리
      if (querySnapshot.docs.isEmpty) {
        hasMoreData = false;
        if (isInitialLoad) {
          state = AsyncValue.data([]);
        }
        return;
      }

      // 9. 페이지네이션을 위해 마지막 문서 저장
      lastDocument = querySnapshot.docs.last;

      // 10. 거래 데이터에서 사용자 ID 수집
      final userIdsToFetch = await _collectUserIds(querySnapshot);

      // 11. 수집된 사용자 ID로 사용자 이름 가져오기
      final userNames = await _fetchUserNames(userIdsToFetch);

      // 12. 거래 데이터를 TransactionHistory 객체로 변환
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // 문서 데이터를 Map 형태로 가져옴
        if (data == null) return null; // 데이터가 없는 경우 건너뜀

        final userId = data['userId'] as String? ?? ''; // 거래 주체 ID
        final type = data['type'] as String? ?? ''; // 거래 유형
        final points = data['amount'] ?? 0; // 거래 포인트

        final name = userNames[userId] ?? '알 수 없는 사용자'; // 거래 주체의 이름
        int adjustedPoints = points; // 기본적으로 가산 포인트로 설정

        String message = ''; // 메시지

        // 13. 거래 유형에 따라 메시지와 포인트 계산
        if (type == 'チャージ') {
          message = '$name様のポイントをチャージしました';
          adjustedPoints = -points; // 포인트 충전 시 차감
        } else if (type == 'お支払い') {
          message = '$name様がお支払いしました。';
        } else if (type == 'チップ交換') {
          message = '$name様がチップを交換しました';
        } else {
          // 기타 거래 유형 처리
          message = '$name様との取引がありました';
        }

        // 14. TransactionHistory 객체 생성
        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 15. 기존 상태와 새 데이터를 병합하여 중복 제거
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) =>
                  newTransaction.timestamp == transaction.timestamp &&
                  newTransaction.points == transaction.points)),
        ...newTransactions,
      ];

      // 16. 거래 내역을 시간순으로 정렬
      mergedTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 17. 상태를 갱신
      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      // 18. 에러 발생 시 상태를 에러로 전환
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Riverpod Provider 생성
final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryNotifier, AsyncValue<List<TransactionHistory>>>(
  (ref) => TransactionHistoryNotifier(),
);
