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
    final qrCodeViewModel = ref.read(qrCodeProvider.notifier);
    final userPointsViewModel = ref.read(userPointsProvider.notifier);

    // SharedPreferences에서 이메일(회원번호) 가져오기
    final userEmail = PreferencesManager.instance.getEmail();

    // 포인트 숫자에 천 단위 구분 기호 추가
    String formatPoints(int points) {
      final formatter = NumberFormat('#,###');
      return formatter.format(points);
    }

    return Scaffold(
      backgroundColor: Colors.white, // 배경을 하얀색으로 설정
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 40.0),
            child: Text(
              '会員証',
              style: TextStyle(
                color: Colors.black, // 텍스트 색상
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30), // 타이틀과 카드 사이에 여백 추가
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color(0xFFE3E8EF), // 상자 배경색 (227, 232, 239)
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ), // 상단 둥글게, 하단은 사각형
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
                          SizedBox(height: 60), // 추가 높이 조정
                          Image.asset(
                            'lib/img/point_icon.png', // 아이콘 이미지
                            width: 60,
                            height: 60,
                          ),
                          SizedBox(height: 30),
                          Text(
                            '会員番号',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A6FA5), // 부드러운 파란색
                            ),
                          ),
                          SizedBox(height: 5),
                          // PreferencesManager에서 가져온 이메일을 표시
                          Text(
                            userEmail ?? '0000-0000-0000-0000',
                            style: TextStyle(
                              fontSize: 16,
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
                                size: 30, // 아이콘 크기
                              ),
                              onPressed: () {
                                qrCodeViewModel.regenerateQrCode(); // QR 코드 재생성
                                userPointsViewModel.monitorUserPoints(); // 포인트 로드
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          // QR 코드 부분
                          qrCodeState.when(
                            loading: () => CircularProgressIndicator(),
                            data: (qrCode) => qrCode != null
                                ? Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // QR 코드 배경을 흰색으로 설정
                                      borderRadius: BorderRadius.circular(10), // 둥근 사각형
                                    ),
                                    child: QrImage(
                                      data: qrCode.token,
                                      version: QrVersions.auto,
                                      size: 130.0,
                                    ),
                                  )
                                : Text('QRコードがありません'),
                            error: (error, _) => Text('QRコードの取得に失敗しました'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  // 포인트 섹션
                  Text(
                    '利用可能ポイント',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A6FA5), // 설명 텍스트 색상
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 포인트를 오른쪽으로 정렬
                    children: [
                      Baseline(
                        baseline: 40, // aligning both text baselines
                        baselineType: TextBaseline.alphabetic,
                        child: userPointsState.when(
                          data: (points) => Text(
                            formatPoints(points), // 천 단위 구분 기호 추가
                            style: TextStyle(
                              fontSize: 40, // 포인트 크기
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // 포인트 색상
                            ),
                          ),
                          loading: () => Text(
                            '0',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          error: (error, _) => Text('取得失敗'),
                        ),
                      ),
                      SizedBox(width: 5), // 포인트와 'pt' 간격
                      Baseline(
                        baseline: 20, // aligning both text baselines
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          'pt',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey, // 'pt' 텍스트 색상
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(), // 남은 공간을 채워 버튼이 하단에 위치하게 함
                  ElevatedButton(
                    onPressed: () {
                      // 포인트를 보내는 기능
                    },
                    child: Text('ポイントを送る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E1E2C), // 버튼 배경색 (어두운 네이비)
                      foregroundColor: Colors.white, // 텍스트 색상
                      minimumSize: Size(double.infinity, 50), // 버튼 너비를 화면 전체로, 높이는 50
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // 패딩 조정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // 둥근 모서리
                      ),
                      textStyle: TextStyle(
                        fontSize: 14, // 텍스트 크기
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // 하단 여백 추가
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
