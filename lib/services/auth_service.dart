import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final String region = dotenv.env['REGION'] ?? '';
  final String userEmailFunction = dotenv.env['USEREMAIL'] ?? '';
  final String ownerEmailFunction = dotenv.env['OWNEREMAIL'] ?? '';
  final String uidFunction = dotenv.env['USERUID'] ?? '';

  // 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> isEmailAlreadyRegistered(String email) async {
    return await _checkExistence(
      functionName: userEmailFunction,
      data: {'email': email},
      errorMessage: '이메일 중복 확인 중 오류 발생',
    );
  }

  // 소유자 이메일이 이미 등록되었는지 확인하는 함수
  Future<bool> OwnerisEmailAlreadyRegistered(String email) async {
    return await _checkExistence(
      functionName: ownerEmailFunction,
      data: {'email': email},
      errorMessage: '소유자 이메일 중복 확인 중 오류 발생',
    );
  }

  // UID가 이미 존재하는지 확인하는 함수
  Future<bool> isUIDAlreadyRegistered(String uid) async {
    return await _checkExistence(
      functionName: uidFunction,
      data: {'uid': uid},
      errorMessage: 'UID 중복 확인 중 오류 발생',
    );
  }

  // Cloud Function 호출 및 존재 여부 확인을 위한 공통 함수
  Future<bool> _checkExistence({
    required String functionName,
    required Map<String, dynamic> data,
    required String errorMessage,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: region);
      final callable = functions.httpsCallable(functionName);
      final response = await callable.call(data);

      final responseData = response.data;
      if (responseData != null && responseData['exists'] != null) {
        return responseData['exists'] as bool;
      } else {
        print('예상치 못한 응답 형식입니다: $responseData');
        return false;
      }
    } catch (e) {
      print('$errorMessage: $e');
      return false;
    }
  }

  // 인증 이메일 발송 함수
  Future<bool> sendVerificationEmail(String email, String code) async {
    final username = dotenv.env['EMAIL']!;
    final password = dotenv.env['PASSWORD']!;

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
    await _saveDataToFirestore(
      collectionName: 'users',
      data: userData,
      docIdField: 'uid',
    );
  }

  // Firestore에 소유자 데이터 저장 함수
  Future<void> saveownerToFirestore(Map<String, dynamic> ownerData) async {
    await _saveDataToFirestore(
      collectionName: 'owners',
      data: ownerData,
    );
  }

  // Firestore에 데이터 저장을 위한 공통 함수
  Future<void> _saveDataToFirestore({
    required String collectionName,
    required Map<String, dynamic> data,
    String? docIdField,
  }) async {
    final collection = FirebaseFirestore.instance.collection(collectionName);

    if (docIdField != null && data.containsKey(docIdField)) {
      final docId = data[docIdField];
      await collection.doc(docId).set(data);
    } else {
      await collection.add(data);
    }
  }

  // 고유한 UID 생성 함수
  Future<String> generateUniqueUID() async {
    String uid;
    bool isDuplicate;

    do {
      uid = _generateUIDFormat();
      isDuplicate = await isUIDAlreadyRegistered(uid);
    } while (isDuplicate);

    return uid;
  }

  // "0000-0000-0000" 형식의 UID 생성 함수
  String _generateUIDFormat() {
    final random = Random();
    String fourDigit() => (random.nextInt(9000) + 1000).toString();
    return '${fourDigit()}-${fourDigit()}-${fourDigit()}';
  }
}
