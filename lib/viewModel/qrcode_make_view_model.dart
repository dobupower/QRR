import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import 'dart:convert';
import '../model/qr_code_model.dart';
import 'package:intl/intl.dart';

// 포인트 상태 관리
final userPointsProvider = StateNotifierProvider<UserPointsViewModel, AsyncValue<int>>((ref) {
  return UserPointsViewModel();
});

// StateNotifierProvider로 상태 관리
final qrCodeProvider = StateNotifierProvider<QrCodeViewModel, AsyncValue<QrCode?>>((ref) {
  return QrCodeViewModel();
});

class QrCodeViewModel extends StateNotifier<AsyncValue<QrCode?>> {
  QrCodeViewModel() : super(const AsyncValue.loading()) {
    loadUserEmailAndQrCode();  // 초기 QR 코드 로드
  }

  bool isGenerating = false; // QR 코드 중복 생성을 방지하는 플래그

  // 사용자 이메일 및 QR 코드 불러오기
  Future<void> loadUserEmailAndQrCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      _monitorLatestQrCode(email); // Firestore 상태 실시간 감시 시작
    } else {
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }

  // Firestore 실시간 감시 - 가장 최신의 QR 코드를 createdAt 기준으로 모니터링
  void _monitorLatestQrCode(String email) {
    FirebaseFirestore.instance
        .collection('qrcodes')
        .where('userId', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        var qrDoc = querySnapshot.docs.first;
        final qrCode = QrCode.fromJson(qrDoc.data());

        bool isUsed = qrCode.isUsed;
        DateTime expiryDate = DateTime.parse(qrCode.expiryDate);

        if (isUsed || DateTime.now().isAfter(expiryDate)) {
          // QR 코드가 사용되었거나 만료된 경우 새 QR 코드 생성 및 상태 업데이트
          await generateAndMonitorQrCode(email);
        } else {
          // 유효한 QR 코드가 있을 경우 상태 업데이트
          // Firestore에서 가져온 평문 데이터를 암호화하여 QR 코드 상태로 설정
          String encryptedQrCode = await _callEncryptApi({
            'token': qrCode.token,
            'createdAt': qrCode.createdAt,
            'expiryDate': qrCode.expiryDate,
            'email': qrCode.userId,
          });

          // 암호화된 QR 코드 데이터를 상태로 업데이트
          final encryptedQrCodeModel = QrCode(
            token: encryptedQrCode,
            createdAt: qrCode.createdAt,
            expiryDate: qrCode.expiryDate,
            isUsed: qrCode.isUsed,
            userId: qrCode.userId,
          );

          state = AsyncValue.data(encryptedQrCodeModel);
        }
      } else {
        // QR 코드가 없을 때 새로 생성
        await generateAndMonitorQrCode(email);
      }
    });
  }

  // QR 코드 재생성 메서드
  Future<void> regenerateQrCode() async {
    state = const AsyncValue.loading(); // 로딩 상태로 전환
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      await generateAndMonitorQrCode(email);  // QR 코드 재생성
    } else {
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }

  // QR 코드 생성 및 Firestore에 저장 (암호화하지 않은 데이터를 저장)
  Future<void> generateAndMonitorQrCode(String email) async {
    if (isGenerating) return; // 이미 QR 코드가 생성 중이면 중단
    isGenerating = true;

    try {
      // UUID 생성
      String newToken = await _generateUniqueUuid();
      String createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String expiryDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().add(Duration(hours: 1)));

      // Firestore에 저장할 평문 데이터 생성
      Map<String, dynamic> qrPayload = {
        'token': newToken,
        'createdAt': createdAt,
        'expiryDate': expiryDate,
        'email': email,
      };
      print('qrPayload: $qrPayload');

       // **Firestore에 평문 데이터를 저장** (암호화된 데이터는 저장하지 않음)
      await FirebaseFirestore.instance.collection('qrcodes').add({
        'token': newToken,
        'createdAt': createdAt,
        'expiryDate': expiryDate,
        'isUsed': false,
        'userId': email,
      });

      // **API를 호출하여 QR 코드로 사용할 암호화된 데이터를 생성**
      String encryptedData = await _callEncryptApi(qrPayload); 
      

      // **암호화된 데이터를 QR 코드로 표시하도록 상태 업데이트**
      final newQrCode = QrCode(
        token: encryptedData,  // 암호화된 데이터 사용
        createdAt: createdAt,  // 생성 시간
        expiryDate: expiryDate, // 만료 시간
        isUsed: false,
        userId: email,
      );
    } finally {
      isGenerating = false;  // QR 코드 생성 플래그 해제
    }
  }

  Future<String> _callEncryptApi(Map<String, dynamic> qrPayload) async {
    final url = Uri.parse('https://us-central1-qrr-project-9fb5a.cloudfunctions.net/encryptData');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'data': qrPayload}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final encryptedData = responseData['encryptedData'];
      final iv = responseData['iv'];

      print('encryptedData: $encryptedData');
      print('iv: $iv');

      // 필요에 따라 encryptedData와 iv를 함께 사용할 수 있도록 처리
      return jsonEncode({
        'encryptedData': encryptedData,
        'iv': iv,
      });
    } else {
      print('응답 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');
      throw Exception('암호화에 실패했습니다.');
    }
  }

  // QR 코드 고유 UUID 생성
  Future<String> _generateUniqueUuid() async {
    bool isUnique = false;
    String uuid = Uuid().v4();

    while (!isUnique) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('qrcodes')
          .where('token', isEqualTo: uuid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true;
      } else {
        uuid = Uuid().v4();
      }
    }
    return uuid;
  }
}

// 사용자 포인트 관리 ViewModel
class UserPointsViewModel extends StateNotifier<AsyncValue<int>> {
  UserPointsViewModel() : super(const AsyncValue.loading()) {
    monitorUserPoints(); // 초기 포인트 로드
  }

  // Firestore에서 사용자 포인트를 실시간으로 감시
  Future<void> monitorUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final points = userDoc.data()['points'] ?? 0;
          state = AsyncValue.data(points); // 포인트 상태 업데이트
        } else {
          state = AsyncValue.data(0); // 사용자가 없으면 0 포인트
        }
      });
    } else {
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }
}
