import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaction_model.dart' as CustomTransaction;
import 'qrcode_scan_view_model.dart';
import '../services/preferences_manager.dart';

// Transaction 상태를 관리하는 Provider 정의
final transactionProvider = StateNotifierProvider<TransactionViewModel, CustomTransaction.Transaction?>((ref) {
  return TransactionViewModel();
});

// 사용자 트랜잭션 관련 로직을 관리하는 ViewModel 클래스
class TransactionViewModel extends StateNotifier<CustomTransaction.Transaction?> {
  TransactionViewModel() : super(null);

  // email과 uid 조건을 모두 처리하여 사용자 데이터를 가져오는 메서드
  Future<void> fetchUserData(WidgetRef ref) async {
    try {
      // QR 코드 스캔된 사용자 이메일 가져오기
      String? email = ref.read(qrViewModelProvider)?.userId;
      // 현재 Transaction 상태의 uid 가져오기
      String? uid = state?.uid;

      // email 또는 uid가 존재하는 경우에만 사용자 데이터 조회 수행
      if (email != null || uid != null) {
        await _fetchAndUpdateUserData(email: email, uid: uid);
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  // email 또는 uid로 사용자 정보 조회하여 상태 업데이트
  Future<void> _fetchAndUpdateUserData({String? email, String? uid}) async {
    // Firestore에서 'users' 컬렉션 참조
    final query = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot;

    // email 또는 uid 조건으로 Firestore 쿼리 실행
    if (email != null) {
      querySnapshot = await query.where('email', isEqualTo: email).limit(1).get();
    } else if (uid != null) {
      querySnapshot = await query.where('uid', isEqualTo: uid).limit(1).get();
    } else {
      print('유효한 검색 조건이 없습니다.');
      return;
    }

    // 쿼리 결과가 비어 있지 않으면 사용자 정보 업데이트
    if (querySnapshot.docs.isNotEmpty) {
      final userIdDoc = querySnapshot.docs.first;
      final data = userIdDoc.data() as Map<String, dynamic>;

      // 사용자의 'name'과 'points' 정보가 있는 경우 Transaction 상태 업데이트
      if (data.containsKey('name') && data.containsKey('points')) {
        _updateTransactionState(data);
      } else {
        print('사용자 정보를 찾을 수 없습니다.');
      }
    }
  }

  // Transaction 상태를 업데이트하는 메서드
  void _updateTransactionState(Map<String, dynamic> data) {
    state = CustomTransaction.Transaction(
      transactionId: '',
      uid: data['uid'] ?? '', // 사용자의 uid
      type: state?.type ?? 'チャージ', // 트랜잭션 타입 (기본값: 'チャージ')
      amount: state?.amount ?? 0, // 트랜잭션 금액 (기본값: 0)
      timestamp: DateTime.now(), // 트랜잭션 생성 시간
      pubId: data['name'] ?? '', // 사용자 이름
      name: data['name'] ?? '', // 사용자 이름
      point: data['points'] ?? 0, // 사용자의 현재 포인트
      profilePicUrl: data['profilePicUrl'] ?? '', // 사용자 프로필 사진 URL
      email: data['email'] ?? '', // 사용자 이메일
    );
  }

  // 사용자 포인트를 업데이트하는 메서드 (충전 또는 차감)
  Future<bool> updateUserPoints(WidgetRef ref) async {
    try {
      // 현재 Transaction의 이메일과 관련 사용자 이메일을 가져옴
      final email = state?.email;
      final relatedUserEmail = await PreferencesManager.instance.getEmail();
      
      // 이메일이 없으면 false 반환
      if (email == null || relatedUserEmail == null) {
        return false;
      }

      // Firestore에서 사용자의 현재 포인트 정보 조회
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // 사용자 문서가 없으면 false 반환
      if (userSnapshot.docs.isEmpty) return false;

      final userDoc = userSnapshot.docs.first;
      int currentPoint = userDoc['points'] as int; // 현재 포인트 가져오기

      // 트랜잭션 타입에 따라 포인트 조정 (충전 또는 차감)
      final adjustment = (state?.type == 'チャージ') ? state?.amount ?? 0 : -(state?.amount ?? 0);

      // 포인트가 0 미만이 되지 않도록 검사
      if (state?.type != 'チャージ' && currentPoint + adjustment < 0) {
        return false;
      }

      // 새로운 포인트 값 계산 후 Firestore 업데이트
      int newPoint = (currentPoint + adjustment).clamp(0, double.infinity).toInt();
      await FirebaseFirestore.instance.collection('users').doc(userDoc.id).update({'points': newPoint});

      // 트랜잭션 기록을 Firestore에 추가
      final transactionRef = await FirebaseFirestore.instance.collection('Transactions').add({
        'userId': state!.uid, // 트랜잭션 사용자 ID
        'relatedUserId': relatedUserEmail, // 관련 사용자 ID
        'type': state?.type ?? 'チャージ', // 트랜잭션 타입
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

      return true; // 포인트 업데이트 성공 시 true 반환
    } catch (e) {
      print('포인트 업데이트 중 오류 발생: $e');
      return false; // 오류 발생 시 false 반환
    }
  }

  // QR 코드의 사용 상태를 업데이트하는 메서드
  Future<void> _updateQrCodeIsUsed(String token) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('qrcodes')
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
  void updateUid(String newUid) {
    // 상태가 null이면 새로운 Transaction 객체를 생성하여 uid 설정
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
      // 기존 상태가 있으면 uid만 업데이트
      state = state!.copyWith(uid: newUid);
    }
    print('입력된 uid: ${state!.uid}');
  }

  // 사용자 uid가 유효한지 확인하는 메서드
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

  // 트랜잭션 상태를 초기화하는 메서드
  void clearTransactionState() {
    state = null;
    print('Transaction 상태가 초기화되었습니다.');
  }
}
