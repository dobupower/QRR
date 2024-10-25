import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
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
          // QR코드가 사용되었거나 만료된 경우 새 QR코드 생성 및 상태 업데이트
          await _generateAndMonitorQrCode(email);
        } else {
          // 유효한 QR코드가 있을 경우 상태 업데이트
          state = AsyncValue.data(qrCode); 
        }
      } else {
        // QR코드가 없을 때 새로 생성
        await _generateAndMonitorQrCode(email);
      }
    });
  }

  // QR 코드 재생성 메서드
  Future<void> regenerateQrCode() async {
    state = const AsyncValue.loading(); // 로딩 상태로 전환
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      await _generateAndMonitorQrCode(email);  // QR 코드 재생성
    } else {
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }

  // QR 코드 생성 및 Firestore에 저장
  Future<void> _generateAndMonitorQrCode(String email) async {
    if (isGenerating) return; // 이미 QR 코드가 생성 중이면 중단
    isGenerating = true;

    try {
      String newToken = await _generateUniqueUuid();
      String createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      String expiryDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().add(Duration(hours: 1)));

      Map<String, dynamic> qrPayload = {
        'token': newToken,
        'createdAt': createdAt,
        'expiryDate': expiryDate,
        'email': email,
      };

      String encryptedData = await _encryptData(jsonEncode(qrPayload));

      // Firestore에 새로운 QR코드 추가
      await FirebaseFirestore.instance.collection('qrcodes').add({
        'token': newToken,
        'createdAt': createdAt,
        'expiryDate': expiryDate,
        'isUsed': false,
        'userId': email,
      });

      // QR 코드 모델 업데이트
      final newQrCode = QrCode(
        token: newToken,
        createdAt: createdAt,
        expiryDate: expiryDate,
        isUsed: false,
        userId: email,
      );

      // 상태 업데이트
      state = AsyncValue.data(newQrCode);
    } finally {
      isGenerating = false;  // QR 코드 생성 플래그 해제
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

  // 데이터 암호화 메서드
  Future<String> _encryptData(String data) async {
    final key = await _getEncryptionKey();
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  // AES 암호화 키 가져오기
  Future<encrypt.Key> _getEncryptionKey() async {
    String? storedKey = await _secureStorage.read(key: 'aes_key');
    if (storedKey == null) {
      final newKey = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(key: 'aes_key', value: newKey.base64);
      return newKey;
    } else {
      return encrypt.Key.fromBase64(storedKey);
    }
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
