import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart' as CustomTransaction;
import 'qrcode_scan_view_model.dart';
import '../services/preferences_manager.dart';

final transactionProvider = StateNotifierProvider<TransactionViewModel, CustomTransaction.Transaction?>((ref) {
  return TransactionViewModel();
});

class TransactionViewModel extends StateNotifier<CustomTransaction.Transaction?> {
  TransactionViewModel() : super(null);

  // email과 uid 조건을 모두 처리하는 메서드
  Future<void> fetchUserData(WidgetRef ref) async {
    try {
      String? email = ref.read(qrViewModelProvider)?.userId;
      String? uid = state?.uid;

      if (email != null || uid != null) {
        await _fetchAndUpdateUserData(email: email, uid: uid);
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // email 또는 uid로 사용자 정보 조회하여 업데이트
  Future<void> _fetchAndUpdateUserData({String? email, String? uid}) async {
    final query = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot;

    if (email != null) {
      querySnapshot = await query.where('email', isEqualTo: email).limit(1).get();
    } else if (uid != null) {
      querySnapshot = await query.where('uid', isEqualTo: uid).limit(1).get();
    } else {
      print('유효한 검색 조건이 없습니다.');
      return;
    }

    if (querySnapshot.docs.isNotEmpty) {
      final userIdDoc = querySnapshot.docs.first;
      final data = userIdDoc.data() as Map<String, dynamic>;

      if (data.containsKey('name') && data.containsKey('points')) {
        _updateTransactionState(data);
      } else {
        print('사용자 정보를 찾을 수 없습니다.');
      }
    }
  }

  void _updateTransactionState(Map<String, dynamic> data) {
    state = CustomTransaction.Transaction(
      transactionId: '',
      uid: data['uid'] ?? '',
      type: state?.type ?? 'チャージ',
      amount: state?.amount ?? 0,
      timestamp: DateTime.now(),
      pubId: data['name'] ?? '',
      name: data['name'] ?? '',
      point: data['points'] ?? 0,
      profilePicUrl: data['profilePicUrl'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Future<bool> updateUserPoints(WidgetRef ref) async {
  try {
    final email = state?.email;
    final relatedUserEmail = await PreferencesManager.instance.getEmail();
    if (email == null || relatedUserEmail == null) {
      return false;
    }

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) return false;

    final userDoc = userSnapshot.docs.first;
    int currentPoint = userDoc['points'] as int;
    final adjustment = (state?.type == 'チャージ') ? state?.amount ?? 0 : -(state?.amount ?? 0);

    if (state?.type != 'チャージ' && currentPoint + adjustment < 0) {
      return false;
    }

    int newPoint = (currentPoint + adjustment).clamp(0, double.infinity).toInt();
    await FirebaseFirestore.instance.collection('users').doc(userDoc.id).update({'points': newPoint});

    final transactionRef = await FirebaseFirestore.instance.collection('Transactions').add({
      'userId': state!.uid,
      'relatedUserId': relatedUserEmail,
      'type': state?.type ?? 'チャージ',
      'amount': state?.amount ?? 0,
      'timestamp': FieldValue.serverTimestamp(),
      'pubId': await _getPubId(relatedUserEmail),
    });

    await transactionRef.update({'transactionId': transactionRef.id});

    // QR 코드의 token이 존재하면 isUsed 업데이트
    String? token = ref.read(qrViewModelProvider)?.token;
    if (token != null) {
      await _updateQrCodeIsUsed(token);
    }

    // qrViewModelProvider 상태 초기화
    ref.read(qrViewModelProvider.notifier).resumeCamera();

    return true;
  } catch (e) {
    print('포인트 업데이트 중 오류 발생: $e');
    return false;
  }
}


  Future<void> _updateQrCodeIsUsed(String token) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('qrcodes')
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final qrCodeDoc = querySnapshot.docs.first;
      await qrCodeDoc.reference.update({'isUsed': true});
      print('QR Code 사용 완료 상태로 업데이트됨');
    } else {
      print('해당 토큰의 QR 코드를 찾을 수 없습니다.');
    }
  }

  Future<String?> _getPubId(String ownerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('PubInfos')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }

  void updateTransactionType(String type) {
    state = state?.copyWith(type: type);
    print('선택된 거래 타입: ${state?.type}');
  }

  void updateAmount(int newAmount) {
    state = state?.copyWith(amount: newAmount);
    print('입력된 amount: ${state?.amount}');
  }

  void updateUid(String newUid) {
    if (state == null) {
      state = CustomTransaction.Transaction(
        transactionId: '',
        uid: newUid,
        type: state?.type ?? 'チャージ',
        amount: 0,
        timestamp: DateTime.now(),
        pubId: '',
        name: '',
        point: 0,
        profilePicUrl: '',
        email: '',
      );
    } else {
      state = state!.copyWith(uid: newUid);
    }
    print('입력된 uid: ${state!.uid}');
  }

  Future<bool> verifyUserUid(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('오류 발생: $e');
      return false;
    }
  }

  void clearTransactionState() {
    state = null;
    print('Transaction 상태가 초기화되었습니다.');
  }
}
