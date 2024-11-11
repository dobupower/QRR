import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/user_transaction_model.dart';
import '../services/preferences_manager.dart';

class UserPointsUidViewModel extends StateNotifier<UserPointsUidState> {
  UserPointsUidViewModel() : super(UserPointsUidState());

  // Firestore에서 name 또는 uid로 사용자 검색
  Future<void> searchUserByNameOrUid(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(userState: const AsyncValue.data([])); // 검색어가 비어있으면 빈 리스트로 초기화
      return;
    }

    try {
      final users = <User>[];

      // 현재 사용자의 이메일 가져오기
      final currentUserEmail = await PreferencesManager.instance.getEmail();

      // 이름으로 검색
      final nameSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      if (nameSnapshot.docs.isNotEmpty) {
        users.addAll(nameSnapshot.docs.map((doc) {
          return User.fromJson(doc.data()..['uid'] = doc.id);
        }));
      }

      // UID로 검색
      final uidSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: query)
          .get();

      if (uidSnapshot.docs.isNotEmpty) {
        users.addAll(uidSnapshot.docs.map((doc) {
          return User.fromJson(doc.data()..['uid'] = doc.id);
        }));
      }

      // 중복 사용자 제거 및 자신을 제외한 유저 리스트 생성
      final uniqueUsers = {
        for (var user in users)
          if (user.email != currentUserEmail) user.uid: user
      }.values.toList();

      // 사용자 상태 업데이트
      state = state.copyWith(userState: AsyncValue.data(uniqueUsers));
    } catch (e) {
      print('Error searching user by name or UID: $e');
      state = state.copyWith(userState: AsyncValue.error('사용자 검색 중 오류가 발생했습니다.', StackTrace.current));
    }
  }

  // Firestore에서 특정 UID로 사용자 정보를 가져와 업데이트하는 함수
  Future<void> updateUserByUid(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          final updatedUser = User(
            uid: uid,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            points: userData['points'] ?? 0,
            authType: userData['authType'] ?? '',
            profilePicUrl: userData['profilePicUrl'],
            pubId: userData['pubId'],
          );

          state = state.copyWith(userState: AsyncValue.data([updatedUser]));
        }
      } else {
        print("User not found in Firestore.");
        state = state.copyWith(userState: const AsyncValue.data([]));
      }
    } catch (e) {
      print('Error updating user data by UID: $e');
      state = state.copyWith(userState: AsyncValue.error('사용자 정보 업데이트 중 오류가 발생했습니다.', StackTrace.current));
    }
  }

  // UserTransaction의 amount를 업데이트하는 함수
  void updateAmount(int newAmount) {
    state = state.copyWith(transactionState: state.transactionState.whenData((transaction) {
      return transaction.copyWith(amount: newAmount);
    }));
  }

  // 거래를 수행하고 Firestore에 저장하는 함수
  Future<bool> performTransaction(User receiverUser) async {
    final senderEmail = await PreferencesManager.instance.getEmail();
    final transactionAmount = state.transactionState.value?.amount ?? 0;

    if (senderEmail == null) {
      print("Sender email not found.");
      return false; // 실패 시 false 반환
    }

    try {
      // Firestore에서 sender의 uid를 가져와 검증
      final senderDoc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: senderEmail).get();
      if (senderDoc.docs.isEmpty) {
        print("Sender not found.");
        return false; // 실패 시 false 반환
      }

      final senderData = senderDoc.docs.first.data();
      final senderUid = senderDoc.docs.first.id; // sender의 uid
      final senderPoints = senderData['points'] ?? 0;

      if (transactionAmount > senderPoints) {
        print("포인트가 부족합니다.");
        return false; // 실패 시 false 반환
      }

      // sender와 receiver의 포인트 업데이트
      final senderDocRef = FirebaseFirestore.instance.collection('users').doc(senderUid);
      final receiverDocRef = FirebaseFirestore.instance.collection('users').doc(receiverUser.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(senderDocRef, {'points': senderPoints - transactionAmount});
        transaction.update(receiverDocRef, {'points': receiverUser.points + transactionAmount});
      });

      // Transactions 컬렉션에 거래 정보 추가
      final transactionRef = await FirebaseFirestore.instance.collection('Transactions').add({
        'uid': senderUid,                 // senderUid를 저장
        'receiverUid': receiverUser.uid,        // receiverUid를 저장
        'amount': transactionAmount,
        'timestamp': DateTime.now(),
      });

      // 트랜잭션 문서 ID를 transactionId 필드에 업데이트
      await transactionRef.update({'transactionId': transactionRef.id});

      print("거래가 성공적으로 완료되었습니다.");
      return true; // 성공 시 true 반환
    } catch (e) {
      print("거래 중 오류 발생: $e");
      return false; // 오류 발생 시 false 반환
    }
  }

  // userState와 transactionState를 초기화하는 함수
  void clearUserAndTransactionState() {
    state = UserPointsUidState(
      userState: const AsyncValue.data([]),
      transactionState: AsyncValue.data(UserTransaction(
        transactionId: '',
        senderUid: '',
        receiverUid: '',
        amount: 0,
        timestamp: DateTime.now(),
      )),
    );
  }
}

// 상태를 분리하여 관리하기 위한 State 클래스 정의
class UserPointsUidState {
  final AsyncValue<List<User>> userState;
  final AsyncValue<UserTransaction> transactionState;

  UserPointsUidState({
    this.userState = const AsyncValue.data([]),
    AsyncValue<UserTransaction>? transactionState,
  }) : transactionState = transactionState ?? AsyncValue.data(UserTransaction(
          transactionId: '',
          senderUid: '',
          receiverUid: '',
          amount: 0,
          timestamp: DateTime.now(),
        ));

  UserPointsUidState copyWith({
    AsyncValue<List<User>>? userState,
    AsyncValue<UserTransaction>? transactionState,
  }) {
    return UserPointsUidState(
      userState: userState ?? this.userState,
      transactionState: transactionState ?? this.transactionState,
    );
  }
}

// ViewModel Provider
final userPointsUidProvider = StateNotifierProvider<UserPointsUidViewModel, UserPointsUidState>((ref) {
  return UserPointsUidViewModel();
});
