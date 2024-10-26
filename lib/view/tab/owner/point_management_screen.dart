import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For number formatting
import '../../../viewModel/point_management_view_model.dart';

class PointManagementScreen extends ConsumerStatefulWidget {
  @override
  _PointManagementScreenState createState() => _PointManagementScreenState();
}

class _PointManagementScreenState extends ConsumerState<PointManagementScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 상태에서 fetchUserNameandEmail 호출 사용자의 이름과 정보 가져오기
    ref.read(transactionProvider.notifier).fetchUserNameandEmail(ref);
  }
  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져오기 위한 MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 유저 정보 및 유저 포인트, 거래타입 선택 화면 크기를 동일하게 맞추기 위한 변수
    final double reducedHeight = screenHeight * 0.05;

    // transactionProvider의 상태를 구독
    final transaction = ref.watch(transactionProvider);

    // 사용자 프로필 URL 가져오기
    final profilePicUrl = transaction?.profilePicUrl;

    // 천단위 콤마 포맷터
    final numberFormat = NumberFormat("#,###");

    return Scaffold(
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
            SizedBox(height: screenHeight * 0.015), // 화면 높이의 1.5% 간격

            // 회색 둥근 사각형으로 프로필과 정보 감싸기
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, 
                vertical: reducedHeight * 0.25, // 항목의 25% 높이로 내부 패딩 설정
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.02), // 화면 너비의 2% 반경
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.05, // 화면 너비의 5%로 프로필 사진 크기
                    backgroundColor: Colors.grey,
                    backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? NetworkImage(profilePicUrl) // 프로필 사진이 있으면 네트워크 이미지 사용
                        : null, // null이거나 빈 값이면 기본 아바타로 표시
                    child: (profilePicUrl == null || profilePicUrl.isEmpty)
                        ? Icon(Icons.person, size: screenWidth * 0.06, color: Colors.white) // 빈 값일 때 기본 아이콘
                        : null, // 프로필 사진이 있으면 아이콘은 표시하지 않음
                  ),
                  SizedBox(width: screenWidth * 0.03), // 화면 너비의 3% 간격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Firestore에서 가져온 사용자 이름을 표시
                      Text(
                        transaction?.name ?? 'ユーザー名を取得中...',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // 텍스트 크기 화면 너비의 3%
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Firestore에서 가져온 이메일을 표시
                      Text(
                        transaction?.email ?? '0000-0000-0000',
                        style: TextStyle(fontSize: screenWidth * 0.03),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Available points inside rounded rectangle
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, 
                vertical: reducedHeight * 0.25, // 동일하게 줄여서 내부 패딩 적용
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ご利用可能なポイント',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // 텍스트 크기 화면 너비의 4%
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${numberFormat.format(transaction?.point ?? 0)} pt',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Custom Radio buttons for transaction type
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025, 
                vertical: reducedHeight * 0.25, // 동일하게 줄여서 내부 패딩 적용
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ActionButton(
                      text: 'チャージ',
                      isSelected: transaction?.type == 'チャージ',
                      onPressed: () {
                        ref.read(transactionProvider.notifier).updateTransactionType('チャージ');
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: ActionButton(
                      text: 'チップ交換',
                      isSelected: transaction?.type == 'チップ交換',
                      onPressed: () {
                        ref.read(transactionProvider.notifier).updateTransactionType('チップ交換');
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: ActionButton(
                      text: 'お支払い',
                      isSelected: transaction?.type == 'お支払い',
                      onPressed: () {
                        ref.read(transactionProvider.notifier).updateTransactionType('お支払い');
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ),

            SizedBox(height: screenHeight * 0.003),

            // 표시된 amount 값을 업데이트하는 부분
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${numberFormat.format(transaction?.amount ?? 0)} pt',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Number pad for entering the amount (스크롤을 없애고 고정된 높이 적용)
            Container(
              height: screenHeight * 0.35, // 고정된 높이 설정
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 2, // childAspectRatio 값을 조정하여 키의 크기 조절 (기본값보다 더 넓게)
                mainAxisSpacing: screenHeight * 0.002, // 숫자키 간의 세로 간격
                crossAxisSpacing: screenWidth * 0.01, // 숫자키 간의 가로 간격
                physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                children: List.generate(12, (index) {
                  String displayText;
                  if (index == 9) {
                    displayText = 'C';  // Clear 버튼
                  } else if (index == 11) {
                    return IconButton(
                      icon: Icon(Icons.backspace, size: screenWidth * 0.07),
                      onPressed: () {
                        String currentAmount = (transaction?.amount ?? 0).toString();
                        if (currentAmount.isNotEmpty && currentAmount != '0') {
                          String newAmount = currentAmount.substring(0, currentAmount.length - 1);
                          ref.read(transactionProvider.notifier).updateAmount(int.parse(newAmount.isEmpty ? '0' : newAmount));
                        }
                      },
                    );
                  } else {
                    displayText = index == 10 ? '0' : '${index + 1}';
                  }

                  return GestureDetector(
                    onTap: () {
                      if (displayText == 'C') {
                        ref.read(transactionProvider.notifier).updateAmount(0);
                      } else {
                        String currentAmount = (transaction?.amount ?? 0).toString();
                        if (currentAmount == '0') {
                          currentAmount = '';
                        }
                        if (currentAmount.length < 9) {
                          String newAmountStr = currentAmount + displayText;
                          ref.read(transactionProvider.notifier).updateAmount(int.parse(newAmountStr));
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(screenWidth * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Center(
                        child: Text(
                          displayText,
                          style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Send/Receive buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/pointManagementConfirm');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D2538), // 배경색 (짙은 네이비)
                        borderRadius: BorderRadius.circular(screenWidth * 0.07), // 둥근 모서리
                      ),
                      child: Center(
                        child: Text(
                          '送る',
                          style: TextStyle(
                            color: Colors.white, // 흰색 텍스트
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.05), // 두 버튼 간의 간격
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // '受け取る' 버튼을 눌렀을 때 이전 화면으로 돌아가기
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white, // 흰색 배경
                        borderRadius: BorderRadius.circular(screenWidth * 0.07), // 둥근 모서리
                        border: Border.all(color: Color(0xFF1D2538), width: 2), // 테두리
                      ),
                      child: Center(
                        child: Text(
                          '受け取る',
                          style: TextStyle(
                            color: Color(0xFF1D2538), // 텍스트 색상 (짙은 네이비)
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const ActionButton({
    required this.text,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.025),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D2538) : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ),
    );
  }
}