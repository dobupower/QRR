import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For number formatting
import '../../../viewModel/point_management_view_model.dart';

class PointManagementConfirmScreen extends ConsumerStatefulWidget {
  @override
  _PointManagementConfirmScreenState createState() => _PointManagementConfirmScreenState();
}

class _PointManagementConfirmScreenState extends ConsumerState<PointManagementConfirmScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 시 한 번만 fetchUserData 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).fetchUserData(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져오기 위한 MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // transactionProvider의 상태를 구독
    final transaction = ref.watch(transactionProvider);

    // 사용자 프로필 URL 가져오기
    final profilePicUrl = transaction?.profilePicUrl;

    // 천단위 콤마 포맷터
    final numberFormat = NumberFormat("#,###");

    // 거래 타입에 따라 색상과 텍스트 설정
    Color backgroundColor;
    String displayText;

    switch (transaction?.type) {
      case 'チャージ':
        backgroundColor = Color(0xFF4CAF50); // 초록색
        displayText = 'チャージ完了';
        break;
      case 'チップ交換':
        backgroundColor = Color(0xFF2196F3); // 파란색
        displayText = 'チップ交換';
        break;
      case 'お支払い':
        backgroundColor = Color(0xFFF44336); // 빨간색
        displayText = 'お支払い';
        break;
      default:
        backgroundColor = Colors.grey; // 기본색 (없을 경우)
        displayText = '타입 없음';
    }

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        backgroundColor: Colors.white, // 배경 색상 설정
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02), // padding을 화면 너비의 2%로 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 'ポイント管理'을 상단에 배치
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.05), // 화면 높이의 5%만큼 상단 여백
                child: Text(
                  'ポイント管理',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.07, // 텍스트 크기 화면 너비의 4.5%
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04), // 화면 높이의 1.5% 간격

              // 회색 둥근 사각형으로 프로필과 정보 감싸기
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, // 가로 패딩을 4/3로 줄인 값
                  vertical: screenHeight * 0.015,  // 세로 패딩도 4/3로 줄임
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.015), // 모서리 반경을 4/3로 줄임
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.06, // 프로필 사진 크기를 4/3로 줄임
                      backgroundColor: Colors.grey,
                      backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                          ? NetworkImage(profilePicUrl) // 프로필 사진이 있으면 네트워크 이미지 사용
                          : null,
                      child: (profilePicUrl == null || profilePicUrl.isEmpty)
                          ? Icon(Icons.person, size: screenWidth * 0.07, color: Colors.white) // 빈 값일 때 기본 아이콘 크기도 4/3로 줄임
                          : null,
                    ),
                    SizedBox(width: screenWidth * 0.04), // 간격을 4/3로 줄임
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Firestore에서 가져온 사용자 이름을 표시
                        Text(
                          transaction?.name ?? 'ユーザー名を取得中...',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045, // 텍스트 크기를 4/3로 줄임
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Firestore에서 가져온 이메일을 표시
                        Text(
                          transaction?.uid ?? '0000-0000-0000',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035, // 이메일 텍스트 크기
                          ),
                          maxLines: null, // 줄바꿈을 허용
                          softWrap: true, // 텍스트가 길 경우 자동 줄바꿈
                          textAlign: TextAlign.start, // 텍스트 정렬을 왼쪽으로 설정
                          overflow: TextOverflow.visible, // 텍스트가 화면 밖으로 나갈 때 보여지는 방식 설정
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // 표시된 amount 값을 업데이트하는 부분
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${numberFormat.format(transaction?.amount ?? 0)} pt',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
              // 거래 타입 표시
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor, // 조건에 따른 배경색 설정
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  child: Text(
                    displayText, // 조건에 따른 텍스트 설정
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              Spacer(),

              // 홈으로 가기 버튼
              Center(
                child: GestureDetector(
                  onTap: () {
                    ref.read(transactionProvider.notifier).clearTransactionState();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.2,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF1D2538), // 버튼 배경색 설정
                      borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    ),
                    child: Center(
                      child: Text(
                        'ホームへ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }
}
