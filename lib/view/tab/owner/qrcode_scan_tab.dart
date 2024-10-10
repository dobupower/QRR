import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../viewModel/qrcode_scan_view_model.dart';

class ScanTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrViewModel = ref.read(qrViewModelProvider.notifier); // QRViewModel
    final qrCode = ref.watch(qrViewModelProvider); // QR 코드 데이터 상태 구독

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrViewModel.qrKey,
              onQRViewCreated: qrViewModel.onQRViewCreated, // QR 스캔 이벤트 연결
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: qrCode != null
                  ? Text('QR 데이터: $qrCode')
                  : Text('QR 코드를 스캔하세요'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: qrViewModel.resumeCamera, // 카메라 다시 시작
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
