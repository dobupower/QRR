import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/qr_code_model.dart';

class QRViewModel extends StateNotifier<QrCode?> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanned = false; // QR 코드가 이미 스캔되었는지 여부를 추적하는 플래그

  QRViewModel() : super(null);

  // QR 스캔이 완료되면 상태를 업데이트
  void onQRViewCreated(QRViewController qrController, BuildContext context) {
    controller = qrController;
    qrController.scannedDataStream.listen((scanData) async {
      if (isScanned) return; // 이미 스캔된 경우 추가 스캔을 막음

      try {
        isScanned = true; // 스캔 상태로 설정

        // 스캔된 데이터 처리 (JSON 형식의 문자열을 파싱)
        final scanText = scanData.code!;
        print('스캔된 데이터: $scanText');

        // 스캔된 데이터가 JSON 형식이라고 가정하고 파싱 시도
        Map<String, dynamic> scannedData = jsonDecode(scanText);

        String encryptedData = scannedData['encryptedData'];
        String iv = scannedData['iv'];

        // 서버로 복호화 요청 보내기
        String decryptedData = await _callDecryptApi(encryptedData, iv);
        print('복호화된 데이터: $decryptedData');

        // 복호화된 데이터를 JSON으로 파싱
        Map<String, dynamic> decryptedJson = jsonDecode(decryptedData);

        // QrCode 객체로 변환하여 상태 업데이트
        final qrCode = QrCode(
          token: decryptedJson['token'],
          createdAt: decryptedJson['createdAt'],
          expiryDate: decryptedJson['expiryDate'],
          isUsed: false,  // 기본값 false로 설정
          userId: decryptedJson['email'],  // userId에 email 할당
        );

        state = qrCode; // QrCode 상태 업데이트

        // 성공 시 OwnerHomeScreen 내에서 PointManagementScreen으로 이동
        Navigator.pushNamed(context, '/pointManagement');
      } catch (e) {
        state = null; // 에러 발생 시 상태 초기화
        print('복호화 실패: $e');
      } finally {
        controller?.pauseCamera(); // 비동기 작업 완료 후 카메라 일시정지
      }
    });
  }

  // 카메라 재개 함수
  void resumeCamera() {
    isScanned = false; // 다시 스캔 가능하도록 상태 초기화
    controller?.resumeCamera();
  }

  // 서버로 복호화 API 요청을 보내는 함수
  Future<String> _callDecryptApi(String encryptedData, String iv) async {
    final url = Uri.parse('https://us-central1-qrr-project-9fb5a.cloudfunctions.net/decryptData');
    
    // JSON 객체로 암호화된 데이터 (iv와 encryptedData 포함) 전송
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encryptedData': encryptedData,  // QR 코드에서 읽은 암호화된 데이터
        'iv': iv, // IV도 함께 전송
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('서버 응답 데이터: $responseData');
      return responseData['decrypted'];  // 복호화된 데이터 반환
    } else {
      print('서버 오류 코드: ${response.statusCode}');
      print('서버 오류 메시지: ${response.body}');
      throw Exception('복호화에 실패했습니다.');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// QRViewModel을 제공하는 Provider
final qrViewModelProvider = StateNotifierProvider<QRViewModel, QrCode?>((ref) {
  return QRViewModel();
});
