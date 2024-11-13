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
      state = state.copyWith(userState: const AsyncValue.data([]));
      return;
    }

    try {
      final users = <User>[];
      final currentUserEmail = await PreferencesManager.instance.getEmail();

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

      final uidSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: query)
          .get();

      if (uidSnapshot.docs.isNotEmpty) {
        users.addAll(uidSnapshot.docs.map((doc) {
          return User.fromJson(doc.data()..['uid'] = doc.id);
        }));
      }

      final uniqueUsers = {
        for (var user in users)
          if (user.email != currentUserEmail) user.uid: user
      }.values.toList();

      state = state.copyWith(userState: AsyncValue.data(uniqueUsers));
    } catch (e) {
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
        state = state.copyWith(userState: const AsyncValue.data([]));
      }
    } catch (e) {
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
      return false;
    }

    try {
      final senderDoc = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: senderEmail).get();
      if (senderDoc.docs.isEmpty) {
        return false;
      }

      final senderUid = senderDoc.docs.first.id;
      final senderDocRef = FirebaseFirestore.instance.collection('users').doc(senderUid);
      final receiverDocRef = FirebaseFirestore.instance.collection('users').doc(receiverUser.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderSnapshot = await transaction.get(senderDocRef);
        final senderPoints = senderSnapshot.data()?['points'] ?? 0;

        final receiverSnapshot = await transaction.get(receiverDocRef);
        final receiverPoints = receiverSnapshot.data()?['points'] ?? 0;

        if (transactionAmount > senderPoints) {
          throw Exception("포인트가 부족합니다.");
        }

        transaction.update(senderDocRef, {
          'points': senderPoints - transactionAmount,
        });

        transaction.update(receiverDocRef, {
          'points': receiverPoints + transactionAmount,
        });
      });

      final transactionRef = await FirebaseFirestore.instance.collection('Transactions').add({
        'relatedUserId': senderUid,
        'userId': receiverUser.uid,
        'amount': transactionAmount,
        'timestamp': DateTime.now(),
      });

      await transactionRef.update({'transactionId': transactionRef.id});

      return true;
    } catch (e) {
      return false;
    }
  }

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
