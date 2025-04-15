import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../viewModel/qrcode_scan_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrViewModel = ref.watch(qrViewModelProvider.notifier); // watch로 상태 구독

    // 화면 크기 값을 변수에 저장
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // QR View Camera Preview
            MobileScanner(
              controller: qrViewModel.controller,
              onDetect: (capture) => qrViewModel.onDetect(capture, context),
            ),

            // Top Left Text Overlay
            Positioned(
              top: screenHeight * 0.05, // 화면 높이의 5%만큼 위에 배치
              left: screenWidth * 0.05, // 화면 너비의 5%만큼 왼쪽에 배치
              child: Text(
                localizations?.qrcodeScanTabScan ?? '',
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // 화면 너비의 6% 크기
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text color for contrast
                ),
              ),
            ),

            // Top Right Close Button Overlay
            Positioned(
              top: screenHeight * 0.05, // 화면 높이의 5%만큼 위에 배치
              right: screenWidth * 0.05, // 화면 너비의 5%만큼 오른쪽에 배치
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: screenWidth * 0.08), // 화면 너비의 8% 크기
                onPressed: () {
                  qrViewModel.resumeCamera();
                },
              ),
            ),

            // Bottom Button to Enter Member Number
            Positioned(
              bottom: screenHeight * 0.08, // 화면 높이의 8%만큼 아래에 배치
              left: screenWidth * 0.25, // 화면의 25%만큼 왼쪽 여백
              right: screenWidth * 0.25, // 화면의 25%만큼 오른쪽 여백
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), // 투명도 설정
                  borderRadius: BorderRadius.circular(screenWidth * 0.08), // 화면 너비의 8%로 둥근 모서리
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/memberInput');
                  },
                  icon: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.05), // 아이콘을 왼쪽에 붙이기 위한 패딩
                    child: Icon(Icons.edit_square, color: Colors.black, size: screenWidth * 0.05), // 아이콘 크기 화면 너비의 6% 설정
                  ),
                  label: Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.05), // 텍스트와 아이콘 사이 간격 조절
                    child: Text(
                      localizations?.meberInputScreenUserNumber1 ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // 텍스트에 더 두꺼운 느낌을 줌
                        fontSize: screenWidth * 0.04, // 텍스트 크기 화면 너비의 4.5%로 설정
                      ),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft, // 아이콘과 텍스트를 왼쪽 정렬
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 위아래 패딩 (화면 높이의 2%)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
