import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 추가
import 'dart:convert';
import '../model/qr_code_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      // 문서가 없는 경우 새 QR 코드를 생성하고 종료
      if (querySnapshot.docs.isEmpty) {
        try {
          await generateAndMonitorQrCode(email);
        } catch (e, stackTrace) {
          // 예외 로깅 및 상태 업데이트
          state = AsyncValue.error(e, stackTrace);
        }
        return;
      }

      // 문서가 있는 경우
      var qrDoc = querySnapshot.docs.first;
      final qrCode = QrCode.fromJson(qrDoc.data());

      bool isUsed = qrCode.isUsed;
      DateTime expiryDate = DateTime.parse(qrCode.expiryDate);

      // QR 코드 상태 확인 및 처리
      if (isUsed || DateTime.now().isAfter(expiryDate)) {
        try {
          await generateAndMonitorQrCode(email);
        } catch (e, stackTrace) {
          // 예외 로깅 및 상태 업데이트
          state = AsyncValue.error(e, stackTrace);
        }
      } else {
        try {
          // 유효한 QR 코드가 있을 경우 데이터를 암호화하여 상태 업데이트
          String encryptedQrCode = await _callEncryptApi({
            'token': qrCode.token,
            'createdAt': qrCode.createdAt,
            'expiryDate': qrCode.expiryDate,
            'email': qrCode.userId,
          });

          // 암호화된 QR 코드 상태로 설정
          final encryptedQrCodeModel = QrCode(
            token: encryptedQrCode,
            createdAt: qrCode.createdAt,
            expiryDate: qrCode.expiryDate,
            isUsed: qrCode.isUsed,
            userId: qrCode.userId,
          );

          state = AsyncValue.data(encryptedQrCodeModel);
        } catch (e, stackTrace) {
          // 암호화 API 호출 또는 상태 업데이트 중 예외 처리
          state = AsyncValue.error(e, stackTrace);
        }
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
    final url = Uri.parse(dotenv.env['ENCRYPT_API_URL']!);
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
