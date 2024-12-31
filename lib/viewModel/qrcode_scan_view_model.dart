import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/qr_code_model.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// QR 코드 스캔 및 상태 관리를 담당하는 ViewModel
class QRViewModel extends StateNotifier<QrCode?> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isScanned = false; // QR 코드가 이미 스캔된 상태인지 여부를 추적하는 변수

  QRViewModel() : super(null);

  // QR 뷰가 생성되면 호출되며, QR 코드 스캔된 데이터를 처리
  void onQRViewCreated(QRViewController qrController, BuildContext context) {
    controller = qrController;
    // QR 코드 스캔된 데이터를 스트림으로 받아 처리
    qrController.scannedDataStream.listen((scanData) async {
      if (isScanned) return; // 이미 스캔 중이라면 처리하지 않음

      _setScanningState(true); // 스캔 상태를 true로 설정 (카메라 일시 정지)

      try {
        final scanText = scanData.code!;
        print('스캔된 데이터: $scanText');
        Map<String, dynamic> scannedData = jsonDecode(scanText);

        // 암호화된 데이터와 IV(초기화 벡터) 추출
        String encryptedData = scannedData['encryptedData'];
        String iv = scannedData['iv'];
        
        // 외부 API를 호출하여 데이터를 복호화
        String decryptedData = await _callDecryptApi(encryptedData, iv);
        print('복호화된 데이터: $decryptedData');

        // 복호화된 데이터를 JSON으로 변환
        Map<String, dynamic> decryptedJson = jsonDecode(decryptedData);

        // 복호화된 데이터로 QR 코드 객체 생성
        final qrCode = QrCode(
          token: decryptedJson['token'],
          createdAt: decryptedJson['createdAt'],
          expiryDate: decryptedJson['expiryDate'],
          isUsed: false,
          userId: decryptedJson['email'],
        );

        state = qrCode; // 상태를 QR 코드 객체로 업데이트

        // QR 코드 유효성 검사
        final isValid = await validateQrCode(context, qrCode);
        if (isValid) {
          Navigator.pushNamed(context, '/pointManagement'); // 유효한 QR 코드면 포인트 관리 화면으로 이동
        }
      } catch (e) {
        state = null; // 오류 발생 시 상태를 null로 초기화
        print('복호화 실패: $e');
      } finally {
        resumeCamera(); // 스캔 후 카메라 다시 시작
      }
    });
  }

  // 스캔 상태를 설정하고, 스캔 중이면 카메라를 일시 정지
  void _setScanningState(bool state) {
    isScanned = state;
    if (state) {
      controller?.pauseCamera(); // 카메라 일시 정지
    }
  }

  // 스캔 상태를 초기화하고 카메라를 다시 시작
  void resumeCamera() {
    isScanned = false;
    controller?.resumeCamera();
  }

  // QR 코드 유효성 검사 함수
  Future<bool> validateQrCode(BuildContext context, QrCode qrCode) async {
    final localizations = AppLocalizations.of(context);
    try {
      final token = qrCode.token;
      final currentDateTime = DateTime.now();
      print('Token: $token');

      // Firestore에서 QR 코드 토큰이 존재하는지 확인
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Qrcodes')
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackbar(context, localizations?.qrcodeScanViewModelQrCodeError1 ?? '', Colors.red);
        return false; // QR 코드 토큰이 없다면 유효하지 않음
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final isUsed = data['isUsed'] as bool;
      final expiryDateString = data['expiryDate'] as String;
      final expiryDate = _parseDateTime(expiryDateString);

      // QR 코드가 사용되지 않았고, 만료되지 않았다면 유효함
      if (!isUsed && expiryDate.isAfter(currentDateTime)) {
        return true; // 유효한 QR 코드
      } else {
        _showSnackbar(
          context,
          localizations?.qrcodeScanViewModelQrCodeError2 ?? '',
          Colors.red,
        );
        return false; // 유효하지 않은 QR 코드 (이미 사용되었거나 만료됨)
      }
    } catch (e) {
      print('QR 코드 유효성 검사 중 오류 발생: $e');
      _showSnackbar(
        context,
        localizations?.qrcodeScanViewModelQrCodeError3 ?? '',
        Colors.red,
      );
      return false; // 오류 발생 시 유효하지 않음
    }
  }

  // 날짜 문자열을 DateTime 객체로 변환
  DateTime _parseDateTime(String dateString) {
    final DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    return format.parse(dateString);
  }

  // Snackbar를 표시하여 사용자에게 메시지를 보여줌
  void _showSnackbar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // 서버로 복호화 요청을 보내는 함수
  Future<String> _callDecryptApi(String encryptedData, String iv) async {
    final url = Uri.parse(dotenv.env['DECRYPT_API_URL']!);
    
    // 암호화된 데이터와 IV를 JSON 형식으로 전송
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'encryptedData': encryptedData,
        'iv': iv,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('서버 응답: $responseData');
      return responseData['decrypted']; // 복호화된 데이터를 반환
    } else {
      print('서버 오류 코드: ${response.statusCode}');
      print('서버 오류 메시지: ${response.body}');
      throw Exception('Decrypt Fail'); // 복호화 실패 시 예외 발생
    }
  }

  @override
  void dispose() {
    controller?.dispose(); // QR 컨트롤러가 더 이상 필요 없을 때 해제
    super.dispose();
  }
}

// QRViewModel을 제공하는 Provider
final qrViewModelProvider = StateNotifierProvider<QRViewModel, QrCode?>((ref) {
  return QRViewModel();
});
