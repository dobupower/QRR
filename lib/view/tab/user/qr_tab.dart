import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅을 위해 추가
import '../../../viewModel/qrcode_make_view_model.dart';
import '../../../services/preferences_manager.dart'; // PreferencesManager import
import 'package:qr_flutter/qr_flutter.dart';

class QrTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrCodeState = ref.watch(qrCodeProvider); // QR 코드 상태
    final userPointsState = ref.watch(userPointsProvider); // 포인트 상태

    // 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;

    // SharedPreferences에서 이메일(회원번호) 가져오기
    final userEmail = PreferencesManager.instance.getEmail();

    // 포인트 숫자에 천 단위 구분 기호 추가
    String formatPoints(int points) {
      final formatter = NumberFormat('#,###');
      return formatter.format(points);
    }

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        backgroundColor: Colors.white, // 배경을 하얀색으로 설정
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            SizedBox(height: screenSize.height * 0.05), // 화면 높이의 5%만큼 간격
            Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.05, top: screenSize.height * 0.03),
              child: Text(
                '会員証',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상
                  fontSize: screenSize.width * 0.06, // 화면 너비의 6% 크기
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.03), // 타이틀과 카드 사이에 여백 추가
            Expanded(
              child: Container(
                padding: EdgeInsets.all(screenSize.width * 0.05), // 전체 패딩을 화면 너비의 5%로 설정
                decoration: BoxDecoration(
                  color: Color(0xFFE3E8EF), // 상자 배경색 (227, 232, 239)
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenSize.width * 0.1), // 화면 너비의 10%만큼 둥글게
                    topRight: Radius.circular(screenSize.width * 0.1), // 상단 둥글게
                  ),
                ),
                width: double.infinity, // 좌우로 가득 채우기
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // point_icon과 회원번호를 배치
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenSize.height * 0.06), // 추가 높이 조정
                            Image.asset(
                              'lib/img/point_icon.png', // 아이콘 이미지
                              width: screenSize.width * 0.15, // 화면 너비의 15% 크기
                              height: screenSize.width * 0.15, // 화면 너비의 15% 크기
                            ),
                            SizedBox(height: screenSize.height * 0.03),
                            Text(
                              '会員番号',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04, // 화면 너비의 4%
                                color: Color(0xFF4A6FA5), // 부드러운 파란색
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.005),
                            // PreferencesManager에서 가져온 이메일을 표시
                            Text(
                              userEmail != null && userEmail.length > 20 
                              ? userEmail.replaceAllMapped(RegExp(r".{20}"), (match) => "${match.group(0)}\n") // 20글자마다 줄바꿈 추가
                              : userEmail ?? '0000-0000-0000-0000',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.04, // 화면 너비의 4%
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black, // 회원 번호 색상
                              ),
                            ),
                          ],
                        ),
                        // 새로고침 버튼과 QR 코드를 오른쪽에 정렬
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white, // 흰색 배경
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: Color.fromARGB(255, 107, 107, 107), // 아이콘 색상
                                  size: screenSize.width * 0.08, // 아이콘 크기 화면 너비의 8%
                                ),
                                onPressed: () {
                                  ref.read(qrCodeProvider.notifier).regenerateQrCode();
                                  ref.read(userPointsProvider.notifier).monitorUserPoints();
                                },
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            // QR 코드 부분
                            qrCodeState.when(
                              loading: () => CircularProgressIndicator(),
                              data: (qrCode) => qrCode != null
                                  ? Container(
                                      padding: EdgeInsets.all(screenSize.width * 0.02),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // QR 코드 배경을 흰색으로 설정
                                        borderRadius: BorderRadius.circular(screenSize.width * 0.03), // 둥근 사각형
                                      ),
                                      child: QrImage(
                                        data: qrCode.token,
                                        version: QrVersions.auto,
                                        size: screenSize.width * 0.3, // QR 코드 크기 설정
                                      ),
                                    )
                                  : Text('QRコードがありません'),
                              error: (error, _) => Text('QRコードの取得に失敗しました'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    // 포인트 섹션
                    Text(
                      '利用可能ポイント',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        color: Color(0xFF4A6FA5), // 설명 텍스트 색상
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // 포인트를 오른쪽으로 정렬
                      children: [
                        Baseline(
                          baseline: screenSize.height * 0.06, // 높이에 맞춘 baseline
                          baselineType: TextBaseline.alphabetic,
                          child: userPointsState.when(
                            data: (points) => Text(
                              formatPoints(points), // 천 단위 구분 기호 추가
                              style: TextStyle(
                                fontSize: screenSize.width * 0.1, // 포인트 크기
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // 포인트 색상
                              ),
                            ),
                            loading: () => Text(
                              '0',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            error: (error, _) => Text('取得失敗'),
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.01), // 포인트와 'pt' 간격
                        Baseline(
                          baseline: screenSize.height * 0.03,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            'pt',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.04,
                              color: Colors.grey, // 'pt' 텍스트 색상
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // 남은 공간을 채워 버튼이 하단에 위치하게 함
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/userSearch');// 포인트를 보내는 기능
                      },
                      child: Text('ポイントを送る'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E1E2C), // 버튼 배경색 (어두운 네이비)
                        foregroundColor: Colors.white, // 텍스트 색상
                        minimumSize: Size(double.infinity, screenSize.height * 0.08), // 버튼 높이를 화면 높이의 8%로 설정
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenSize.width * 0.05), // 둥근 모서리
                        ),
                        textStyle: TextStyle(
                          fontSize: screenSize.width * 0.04, // 텍스트 크기
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02), // 하단 여백 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
