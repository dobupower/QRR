import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// AuthService: 인증 관련 기능을 담당하는 클래스
class AuthService {
  
  // 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> isEmailAlreadyRegistered(String email) async {
    // Firestore에서 'users' 컬렉션에서 해당 이메일이 있는지 조회
    final existingUser = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    // 해당 이메일이 이미 존재하면 true 반환
    return existingUser.docs.isNotEmpty;
  }

  // 인증 이메일을 발송하는 함수
  Future<bool> sendVerificationEmail(String email, String code) async {
    // 실제 발신 이메일 계정 정보
    String username = 'jeonju-univ@hoboakabane.jp'; // 발신 이메일
    String password = 'trug mgxn qmxo zkdi'; // SMTP 서버 비밀번호 (실제 환경에선 보안에 주의)

    // Gmail SMTP 서버 설정
    final smtpServer = gmail(username, password);
    
    // 이메일 메시지 구성
    final message = Message()
      ..from = Address(username, 'QRR') // 발신자 이메일과 이름
      ..recipients.add(email) // 수신자 이메일
      ..subject = 'Your Verification Code' // 이메일 제목
      ..text = 'Your verification code is $code'; // 이메일 본문 (인증 코드 포함)

    try {
      // 이메일 전송 시도
      await send(message, smtpServer);
      return true; // 전송 성공 시 true 반환
    } catch (e) {
      // 전송 실패 시 오류 출력 및 false 반환
      print('이메일 전송 실패: $e');
      return false;
    }
  }

  // Firestore에 사용자 데이터를 저장하는 함수
  Future<void> saveUserToFirestore(Map<String, dynamic> userData) async {
    // 'users' 컬렉션에 새로운 사용자 데이터 추가
    await FirebaseFirestore.instance.collection('users').add(userData);
  }
  
  Future<void> saveownerToFirestore(Map<String, dynamic> userData) async {
    // 'owners' 컬렉션에 새로운 사용자 데이터 추가
    await FirebaseFirestore.instance.collection('owners').add(userData);
  }
}