import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {

  final String region = dotenv.env['REGION'] ?? '';
  final String user_email = dotenv.env['USEREMAIL'] ?? '';
  final String owner_email = dotenv.env['OWNEREMAIL'] ?? '';
  final String user_uid = dotenv.env['USERUID'] ?? '';
  // 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      // 지역을 지정하여 FirebaseFunctions 인스턴스 생성
      final functions = FirebaseFunctions.instanceFor(region: region);

      // Cloud Function 호출 준비
      final HttpsCallable callable = functions.httpsCallable(user_email);
      // Cloud Function 호출 및 응답 받기
      final response = await callable.call({'email': email});

      // 응답 데이터 처리
      final data = response.data;
      if (data != null && data['exists'] != null) {
        return data['exists'] as bool;
      } else {
        // 예상치 못한 응답 처리
        print('예상치 못한 응답 형식입니다: $data');
        return false;
      }
    } catch (e) {
      // 에러 처리
      print('이메일 중복 확인 중 오류 발생: $e');
      return false;
    }
  }

  // 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> OwnerisEmailAlreadyRegistered(String email) async {
    try {
      // 지역을 지정하여 FirebaseFunctions 인스턴스 생성
      final functions = FirebaseFunctions.instanceFor(region: region);

      // Cloud Function 호출 준비
      final HttpsCallable callable = functions.httpsCallable(owner_email);
      // Cloud Function 호출 및 응답 받기
      final response = await callable.call({'email': email});

      // 응답 데이터 처리
      final data = response.data;
      if (data != null && data['exists'] != null) {
        return data['exists'] as bool;
      } else {
        // 예상치 못한 응답 처리
        print('예상치 못한 응답 형식입니다: $data');
        return false;
      }
    } catch (e) {
      // 에러 처리
      print('이메일 중복 확인 중 오류 발생: $e');
      return false;
    }
  }

  // 인증 이메일 발송 함수
  Future<bool> sendVerificationEmail(String email, String code) async {
    String username = dotenv.env['EMAIL']!;
    String password = dotenv.env['PASSWORD']!;

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'QRR')
      ..recipients.add(email)
      ..subject = 'Your Verification Code'
      ..text = 'Your verification code is $code';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('이메일 전송 실패: $e');
      return false;
    }
  }

  // Firestore에 사용자 데이터 저장 함수
  Future<void> saveUserToFirestore(Map<String, dynamic> userData) async {
    final uid = userData['uid']; // 사용자 uid를 가져옵니다.
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // uid를 문서 ID로 사용합니다.
          .set(userData);
    } else {
      throw Exception('User data must contain a valid uid.');
    }
  }

  // Firestore에 소유자 데이터 저장 함수
  Future<void> saveownerToFirestore(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('owners').add(userData);
  }

  // 고유한 UID 생성 함수
  Future<String> generateUniqueUID() async {
    String uid;
    bool isDuplicate;

    do {
      uid = _generateUIDFormat();
      isDuplicate = await _checkUIDExists(uid);
    } while (isDuplicate);

    return uid;
  }

  // "0000-0000-0000" 형식의 UID 생성 함수
  String _generateUIDFormat() {
    final random = Random();
    String fourDigit() => (random.nextInt(9000) + 1000).toString();
    return '${fourDigit()}-${fourDigit()}-${fourDigit()}';
  }

  Future<bool> _checkUIDExists(String uid) async {
    try {
      // Cloud Function 호출을 위해 FirebaseFunctions 인스턴스 생성
      final functions = FirebaseFunctions.instanceFor(region: region);

      // Cloud Function 호출 준비
      final HttpsCallable callable = functions.httpsCallable(region);

      // Cloud Function 호출 및 응답 받기
      final response = await callable.call({'uid': uid});

      // 응답 데이터 처리
      final data = response.data;
      if (data != null && data['exists'] != null) {
        return data['exists'] as bool;
      } else {
        // 예상치 못한 응답 처리
        print('예상치 못한 응답 형식입니다: $data');
        return false;
      }
    } catch (e) {
      // 에러 처리
      print('UID 중복 확인 중 오류 발생: $e');
      return false;
    }
  }
}
