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
    if (!isInitialLoad && !hasMoreData) {
      // 추가 데이터가 없으면 메소드를 종료
      return;
    }

    try {
      if (isInitialLoad) {
        // 초기 로드인 경우 상태를 로딩으로 설정하고 변수 초기화
        state = const AsyncValue.loading();
        lastDocument = null; // 페이지네이션 상태 초기화
        hasMoreData = true; // 추가 데이터 가능 상태로 설정
      }

      // PreferencesManager에서 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // Firestore에서 이메일을 기준으로 사용자의 UID를 조회
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1) // 이메일은 고유해야 하므로 1개만 조회
          .get();

      if (userSnapshot.docs.isEmpty) {
        // 사용자를 찾을 수 없는 경우 에러 상태로 전환
        state = AsyncValue.error('사용자를 찾을 수 없습니다.', StackTrace.current);
        return;
      }

      // 현재 사용자의 UID 추출
      final currentUid = userSnapshot.docs.first.id;

      // Firestore에서 거래 데이터를 조회하기 위한 쿼리 생성
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where(
            Filter.or(
              Filter('userId', isEqualTo: currentUid), // 거래 주체가 현재 사용자
              Filter('relatedUserId', isEqualTo: currentUid), // 거래 상대가 현재 사용자
            ),
          )
          .orderBy('timestamp', descending: true) // 최신순으로 정렬
          .limit(pageSize); // 한 번에 가져올 데이터 수 제한

      if (lastDocument != null) {
        // 페이지네이션: 이전 마지막 문서 이후 데이터부터 가져오기
        query = query.startAfterDocument(lastDocument!);
      }

      // Firestore에서 쿼리 실행
      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        // 가져온 데이터가 없는 경우
        hasMoreData = false; // 추가 데이터 없음 표시
        if (isInitialLoad) {
          // 초기 로드인 경우 빈 리스트 상태로 설정
          state = AsyncValue.data([]);
        }
        return;
      }

      // 페이지네이션을 위해 마지막 문서를 저장
      lastDocument = querySnapshot.docs.last;

      // 거래 데이터에서 사용자 ID를 수집
      final userIdsToFetch = await _collectUserIds(querySnapshot);

      // 사용자 이름을 가져오기 위한 Firestore 쿼리 실행
      final userNames = await _fetchUserNames(userIdsToFetch);

      // Firestore 문서를 TransactionHistory 객체로 변환
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // 문서 데이터를 Map 형태로 가져옴
        if (data == null) return null; // 데이터가 없는 경우 건너뜀

        final userId = data['userId'] as String? ?? ''; // 거래 주체 ID
        final relatedUserId = data['relatedUserId'] as String? ?? ''; // 거래 상대 ID
        final type = data['type'] as String? ?? ''; // 거래 유형
        final points = data['amount'] ?? 0; // 거래 포인트

        String name = ''; // 거래 상대방 이름
        String message = ''; // 메시지
        int adjustedPoints = -points; // 기본적으로 차감 포인트로 설정

        // 거래 유형에 따라 메시지와 포인트 설정
        if (type == 'チップ交換') {
          message = 'ポイントでチップを交換しました';
        } else if (type == 'チャージ') {
          message = 'ポイントをチャージしました';
          adjustedPoints = points; // 포인트 충전 시 가산
        } else if (type == 'お支払い') {
          message = 'ポイントをお支払いしました';
        } else if (type == '') {
          // 거래 유형이 정의되지 않은 경우
          if (userId == currentUid) {
            // 내가 포인트를 보낸 경우
            name = userNames[relatedUserId] ?? '알 수 없는 사용자';
            message = 'ポイントを $nameさんに送りました';
          } else if (relatedUserId == currentUid) {
            // 내가 포인트를 받은 경우
            name = userNames[userId] ?? '알 수 없는 사용자';
            message = '$nameさんからポイントを受け取りました';
            adjustedPoints = points; // 포인트 수령 시 가산
          }
        }

        // TransactionHistory 객체 생성
        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(), // 타임스탬프를 DateTime으로 변환
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 기존 데이터와 새 데이터를 병합하여 중복 제거
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) => newTransaction.timestamp == transaction.timestamp && newTransaction.points == transaction.points)),
        ...newTransactions,
      ];

      // 시간순으로 정렬
      mergedTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 상태를 갱신
      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      // 예외 발생 시 상태를 에러로 전환
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 가맹점 소유자의 거래 내역을 가져오는 메소드
  Future<void> fetchOwnerTransactionHistory({bool isInitialLoad = false, DateTime? selectedDate}) async {
    if (!isInitialLoad && !hasMoreData) {
      // 추가 데이터가 없으면 메소드를 종료
      return;
    }

    try {
      if (isInitialLoad) {
        // 초기 로드인 경우 상태를 로딩으로 설정하고 변수 초기화
        state = const AsyncValue.loading();
        lastDocument = null; // 페이지네이션 상태 초기화
        hasMoreData = true; // 추가 데이터 가능 상태로 설정
      }

      // 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // 거래 데이터를 조회하기 위한 기본 쿼리 생성
      Query query = FirebaseFirestore.instance
          .collection('Transactions')
          .where('relatedUserId', isEqualTo: currentUserEmail) // 가맹점 소유자 이메일로 필터링
          .orderBy('timestamp', descending: true) // 최신순으로 정렬
          .limit(pageSize); // 한 번에 가져올 데이터 수 제한

      if (lastDocument != null) {
        // 페이지네이션: 이전 마지막 문서 이후 데이터부터 가져오기
        query = query.startAfterDocument(lastDocument!);
      }

      // 특정 날짜로 필터링이 필요한 경우
      if (selectedDate != null) {
        final startOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day));
        final endOfDay = Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay);
      }

      // Firestore에서 쿼리 실행
      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        // 가져온 데이터가 없는 경우
        hasMoreData = false; // 추가 데이터 없음 표시
        if (isInitialLoad) {
          // 초기 로드인 경우 빈 리스트 상태로 설정
          state = AsyncValue.data([]);
        }
        return;
      }

      // 페이지네이션을 위해 마지막 문서를 저장
      lastDocument = querySnapshot.docs.last;

      // 거래 데이터에서 사용자 ID를 수집
      final userIdsToFetch = await _collectUserIds(querySnapshot);

      // 사용자 이름을 가져오기 위한 Firestore 쿼리 실행
      final userNames = await _fetchUserNames(userIdsToFetch);

      // Firestore 문서를 TransactionHistory 객체로 변환
      final newTransactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // 문서 데이터를 Map 형태로 가져옴
        if (data == null) return null; // 데이터가 없는 경우 건너뜀

        final userId = data['userId'] as String? ?? ''; // 거래 주체 ID
        final type = data['type'] as String? ?? ''; // 거래 유형
        final points = data['amount'] ?? 0; // 거래 포인트

        final name = userNames[userId] ?? '알 수 없는 사용자'; // 거래 주체의 이름
        int adjustedPoints = points; // 기본적으로 가산 포인트로 설정

        String message = ''; // 메시지

        // 거래 유형에 따라 메시지와 포인트 설정
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

        // TransactionHistory 객체 생성
        return TransactionHistory(
          name: name,
          transactionType: type,
          points: adjustedPoints,
          timestamp: (data['timestamp'] as Timestamp).toDate(), // 타임스탬프를 DateTime으로 변환
          message: message,
        );
      }).where((transaction) => transaction != null).cast<TransactionHistory>().toList();

      // 기존 데이터와 새 데이터를 병합하여 중복 제거
      final mergedTransactions = <TransactionHistory>[
        if (state.value != null)
          ...state.value!.where((transaction) =>
              !newTransactions.any((newTransaction) => newTransaction.timestamp == transaction.timestamp && newTransaction.points == transaction.points)),
        ...newTransactions,
      ];

      // 시간순으로 정렬
      mergedTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 상태를 갱신
      state = AsyncValue.data(mergedTransactions);
    } catch (e, stackTrace) {
      // 예외 발생 시 상태를 에러로 전환
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Riverpod Provider 생성
final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryNotifier, AsyncValue<List<TransactionHistory>>>(
  (ref) => TransactionHistoryNotifier(),
);
