import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅을 위해 추가
import '../../../viewModel/owner_settings_tab_view_model.dart'; // Firestore 데이터 연동
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PointLimitScreen extends ConsumerWidget {
  PointLimitScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Firestore 데이터 연동 (현재 포인트 리미트 상태)
    final pointLimitState = ref.watch(ownerSettingProvider);
    final pointLimitNotifier = ref.read(ownerSettingProvider.notifier);

    // 기본값이 null일 경우 0으로 초기화
    final transactionAmount = pointLimitState ?? 0;

    // 숫자 포맷팅: 세 자리마다 쉼표
    final formattedTransactionAmount =
        NumberFormat("#,###").format(transactionAmount);

    return Scaffold(
      backgroundColor: Colors.white, // 배경 색상 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 텍스트
          const _TopTitle(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // 나머지 컴포넌트를 아래로 정렬
              children: [
                _PointDisplay(
                  formattedTransactionAmount: formattedTransactionAmount,
                  screenWidth: screenWidth,
                ),
                _NumberDial(
                  transactionAmount: transactionAmount,
                  pointLimitNotifier: pointLimitNotifier,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                _SubmitButton(
                  transactionAmount: transactionAmount,
                  pointLimitNotifier: pointLimitNotifier,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
      ), // 화면 높이의 5%만큼 상단 여백
      child: Text(
        AppLocalizations.of(context)?.ownerSettingsTaPointLimit ?? '',
        style: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06, // 텍스트 크기 화면 너비의 7%
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PointDisplay extends StatelessWidget {
  final String formattedTransactionAmount;
  final double screenWidth;

  const _PointDisplay({
    required this.formattedTransactionAmount,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: screenWidth * 0.05,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              formattedTransactionAmount,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 4), // 숫자와 pt 사이 간격
            Text(
              'pt',
              style: TextStyle(
                fontSize: screenWidth * 0.04, // 숫자보다 작게 설정
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberDial extends StatelessWidget {
  final int transactionAmount;
  final OwnerSettingsTabViewModel pointLimitNotifier;
  final double screenWidth;
  final double screenHeight;

  const _NumberDial({
    required this.transactionAmount,
    required this.pointLimitNotifier,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
      ), // 좌우 여백 설정
      child: Container(
        height: screenHeight * 0.4,
        child: GridView.builder(
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: screenWidth * 0.012, // 좌우 버튼 간격 축소
            mainAxisSpacing: screenHeight * 0.005,
            childAspectRatio: 2,
          ),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            String displayText;

            if (index == 9) {
              displayText = 'C'; // 초기화 버튼
            } else if (index == 11) {
              displayText = ''; // 백스페이스 버튼
            } else {
              displayText = index == 10 ? '0' : '${index + 1}'; // 숫자 버튼
            }

            return GestureDetector(
              onTap: () {
                if (displayText == 'C') {
                  pointLimitNotifier.setPointLimit(0); // Firestore 호출 없이 상태 변경
                } else if (index == 11) {
                  final currentAmount = transactionAmount.toString();
                  final newAmount = currentAmount.length > 1
                      ? currentAmount.substring(0, currentAmount.length - 1)
                      : '0';
                  pointLimitNotifier.setPointLimit(int.parse(newAmount));
                } else {
                  final currentAmount = transactionAmount.toString();
                  final newAmountStr = currentAmount == '0'
                      ? displayText
                      : currentAmount + displayText;
                  if (newAmountStr.length <= 9) {
                    pointLimitNotifier.setPointLimit(int.parse(newAmountStr));
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
                  child: index == 11
                      ? Icon(Icons.backspace,
                          size: screenWidth * 0.07) // 백스페이스 아이콘
                      : Text(
                          displayText,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final int transactionAmount;
  final OwnerSettingsTabViewModel pointLimitNotifier;
  final double screenWidth;
  final double screenHeight;

  const _SubmitButton({
    required this.transactionAmount,
    required this.pointLimitNotifier,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.02,
      ),
      child: ElevatedButton(
        onPressed: transactionAmount > 0
            ? () async {
                await pointLimitNotifier.updatePointLimit(transactionAmount);
                print('새로운 한도: $transactionAmount pt');
                Navigator.pop(context);
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015), // 버튼 높이 조절
          backgroundColor: transactionAmount > 0
              ? Color(0xFF1E1E2C)
              : Colors.grey.shade400, // 비활성화 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리
          ),
          fixedSize: Size(screenWidth * 0.8, 50), // 버튼 길이와 높이 설정
          elevation: 0, // 그림자 제거
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.meberInputScreenSubmit ?? '',
            style: TextStyle(
              fontSize: screenWidth * 0.045, // 텍스트 크기
              fontWeight: FontWeight.bold, // 텍스트 굵기
              color: Colors.white, // 텍스트 색상
            ),
          ),
        ),
      ),
    );
  }
}
