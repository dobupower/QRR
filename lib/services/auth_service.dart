import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  
  // 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> isEmailAlreadyRegistered(String email) async {
    final existingUser = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    return existingUser.docs.isNotEmpty;
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

  // Firestore에서 UID 중복 검사 함수
  Future<bool> _checkUIDExists(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
