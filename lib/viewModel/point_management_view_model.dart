import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart' as CustomTransaction;
import 'qrcode_scan_view_model.dart';
import '../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Transaction 상태를 관리하는 Provider 정의
final transactionProvider = StateNotifierProvider<TransactionViewModel, CustomTransaction.Transaction?>((ref) {
  return TransactionViewModel();
});

// 사용자 트랜잭션 관련 로직을 관리하는 ViewModel 클래스
class TransactionViewModel extends StateNotifier<CustomTransaction.Transaction?> {
  TransactionViewModel() : super(null);

  // email과 uid 조건을 모두 처리하여 사용자 데이터를 가져오는 메서드
  Future<void> fetchUserData(WidgetRef ref, BuildContext context) async {
    try {
      String? email = ref.read(qrViewModelProvider)?.userId;
      String? uid = state?.uid;

      if (email != null || uid != null) {
        // Pass 'context' here to the next method
        await _fetchAndUpdateUserData(email: email, uid: uid, context: context); 
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // email 또는 uid로 사용자 정보 조회하여 상태 업데이트
  Future<void> _fetchAndUpdateUserData({String? email, String? uid, required BuildContext context}) async {
    final query = FirebaseFirestore.instance.collection('Users');
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
        _updateTransactionState(data, context); // Pass BuildContext here
      } else {
        print('사용자 정보를 찾을 수 없습니다.');
      }
    }
  }

  // Transaction 상태를 업데이트하는 메서드
  void _updateTransactionState(Map<String, dynamic> data, BuildContext context) {
    state = CustomTransaction.Transaction(
      transactionId: '',
      uid: data['uid'] ?? '',
      type: state?.type ?? AppLocalizations.of(context)?.pointManagementConfirmScreenCharge1 ?? '',
      amount: state?.amount ?? 0,
      timestamp: DateTime.now(),
      pubId: data['name'] ?? '',
      name: data['name'] ?? '',
      point: data['points'] ?? 0,
      profilePicUrl: data['profilePicUrl'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // 사용자 포인트를 업데이트하는 메서드 (충전 또는 차감)
  Future<String?> updateUserPoints(WidgetRef ref, BuildContext context) async {
    try {
      // 현재 Transaction의 이메일과 관련 사용자 이메일을 가져옴
      final email = state?.email;
      final relatedUserEmail = await PreferencesManager.instance.getEmail();
      final localizations = AppLocalizations.of(context);
      
      // 이메일이 없으면 오류 메시지 반환
      if (email == null || relatedUserEmail == null) {
        return '이메일 정보를 가져올 수 없습니다.';
      }

      // owners 컬렉션에서 relatedUserEmail과 일치하는 문서에서 pointLimit 가져오기
      final ownersSnapshot = await FirebaseFirestore.instance
          .collection('Owners')
          .where('email', isEqualTo: relatedUserEmail)
          .limit(1)
          .get();

      if (ownersSnapshot.docs.isEmpty) {
        print('owners 컬렉션에서 일치하는 문서를 찾을 수 없습니다.');
        return '포인트 한도를 가져올 수 없습니다.';
      }

      final ownerDoc = ownersSnapshot.docs.first;
      int pointLimit = ownerDoc['pointLimit'] as int; // pointLimit 가져오기

      // state.amount가 pointLimit을 초과하는지 확인
      if (state?.amount != null && state!.amount > pointLimit) {
        print('거래 금액이 포인트 한도를 초과했습니다. 최대 $pointLimit 포인트까지 가능합니다.');
        return '거래 금액이 포인트 한도를 초과했습니다. 최대 $pointLimit 포인트까지 가능합니다.';
      }

      // Firestore에서 사용자의 현재 포인트 정보 조회
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // 사용자 문서가 없으면 오류 메시지 반환
      if (userSnapshot.docs.isEmpty) {
        return '사용자 문서를 찾을 수 없습니다.';
      }

      final userDoc = userSnapshot.docs.first;
      int currentPoint = userDoc['points'] as int; // 현재 포인트 가져오기

      // 트랜잭션 타입에 따라 포인트 조정 (충전 또는 차감)
      final adjustment = (state?.type == localizations?.pointManagementConfirmScreenCharge1 ?? false) ? state?.amount ?? 0 : -(state?.amount ?? 0);

      // 포인트가 0 미만이 되지 않도록 검사
      if (state?.type != localizations?.pointManagementConfirmScreenCharge1 && currentPoint + adjustment < 0) {
        print('현재 포인트가 부족하여 거래를 진행할 수 없습니다.');
        return localizations?.pointManagementScreenError;
      }

      // 새로운 포인트 값 계산 후 Firestore 업데이트
      int newPoint = (currentPoint + adjustment).clamp(0, double.infinity).toInt();
      await FirebaseFirestore.instance.collection('Users').doc(userDoc.id).update({'points': newPoint});

      // 트랜잭션 타입 변환
      String transactionType = '';
      if (state?.type == localizations?.pointManagementConfirmScreenCharge1 ?? false) {
        transactionType = 'charge';
      } else if (state?.type == localizations?.pointManagementConfirmScreenChange ?? false) {
        transactionType = 'transfer';
      } else if (state?.type == localizations?.pointManagementConfirmScreenSpend ?? false) {
        transactionType = 'spend';
      }

      // 트랜잭션 기록을 Firestore에 추가
      final transactionRef = await FirebaseFirestore.instance.collection('Transactions').add({
        'userId': state!.uid, // 트랜잭션 사용자 ID
        'relatedUserId': relatedUserEmail, // 관련 사용자 ID
        'type': transactionType, // 변환된 트랜잭션 타입
        'amount': state?.amount ?? 0, // 트랜잭션 금액
        'timestamp': FieldValue.serverTimestamp(), // 트랜잭션 시간 (서버 시간)
        'pubId': await _getPubId(relatedUserEmail), // 관련 사용자 ID로 Pub ID 가져오기
      });

      // 트랜잭션 문서 ID를 transactionId 필드에 업데이트
      await transactionRef.update({'transactionId': transactionRef.id});

      // QR 코드의 token이 존재하면 사용 상태로 업데이트
      String? token = ref.read(qrViewModelProvider)?.token;
      if (token != null) {
        await _updateQrCodeIsUsed(token);
      }

      // qrViewModelProvider 상태 초기화하여 카메라 재개
      ref.read(qrViewModelProvider.notifier).resumeCamera();

      return null; // 포인트 업데이트 성공 시 null 반환
    } catch (e) {
      print('포인트 업데이트 중 오류 발생: $e');
      return '포인트 업데이트 중 오류가 발생했습니다.';
    }
  }

  // QR 코드의 사용 상태를 업데이트하는 메서드
  Future<void> _updateQrCodeIsUsed(String token) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Qrcodes')
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    // 해당 QR 코드가 있으면 isUsed 필드를 true로 업데이트
    if (querySnapshot.docs.isNotEmpty) {
      final qrCodeDoc = querySnapshot.docs.first;
      await qrCodeDoc.reference.update({'isUsed': true});
      print('QR Code 사용 완료 상태로 업데이트됨');
    } else {
      print('해당 토큰의 QR 코드를 찾을 수 없습니다.');
    }
  }

  // 관련 사용자 ID로 Pub ID를 가져오는 메서드
  Future<String?> _getPubId(String ownerId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('PubInfos')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    // Pub ID가 있으면 반환, 없으면 null 반환
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }

  // 트랜잭션 타입을 업데이트하는 메서드
  void updateTransactionType(String type) {
    state = state?.copyWith(type: type);
    print('선택된 거래 타입: ${state?.type}');
  }

  // 트랜잭션 금액을 업데이트하는 메서드
  void updateAmount(int newAmount) {
    state = state?.copyWith(amount: newAmount);
    print('입력된 amount: ${state?.amount}');
  }

  // 트랜잭션에 사용자 uid를 설정하는 메서드
  void updateUid(String newUid,  BuildContext context) {
    // 상태가 null이면 새로운 Transaction 객체를 생성하여 uid 설정
    if (state == null) {
      state = CustomTransaction.Transaction(
        transactionId: '',
        uid: newUid,
        type: state?.type ?? AppLocalizations.of(context)?.pointManagementConfirmScreenCharge1 ?? '',
        amount: 0,
        timestamp: DateTime.now(),
        pubId: '',
        name: '',
        point: 0,
        profilePicUrl: '',
        email: '',
      );
    } else {
      // 기존 상태가 있으면 uid만 업데이트
      state = state!.copyWith(uid: newUid);
    }
    print('입력된 uid: ${state!.uid}');
  }

  // 사용자 uid가 유효한지 확인하는 메서드
  Future<bool> verifyUserUid(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('오류 발생: $e');
      return false;
    }
  }

  // 트랜잭션 상태를 초기화하는 메서드
  void clearTransactionState() {
    state = null;
    print('Transaction 상태가 초기화되었습니다.');
  }
}