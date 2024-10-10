import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';

class QRViewModel extends StateNotifier<String?> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewModel() : super(null);

  // QR 스캔이 완료되면 상태를 업데이트
  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    qrController.scannedDataStream.listen((scanData) {
      state = scanData.code; // 스캔한 데이터로 상태 업데이트
      controller?.pauseCamera(); // 카메라 일시정지
    });
  }

  void resumeCamera() {
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// QRViewModel을 제공하는 Provider
final qrViewModelProvider = StateNotifierProvider<QRViewModel, String?>((ref) {
  return QRViewModel();
});
