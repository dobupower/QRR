import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For number formatting
import 'package:qrr_project/viewModel/qrcode_scan_view_model.dart';
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
    ref.read(transactionProvider.notifier).fetchUserData(ref);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final double reducedHeight = screenHeight * 0.05;

    final transaction = ref.watch(transactionProvider);
    final profilePicUrl = transaction?.profilePicUrl;
    final numberFormat = NumberFormat("#,###");
    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView( // 화면 스크롤 가능하도록 설정
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Text(
                    'ポイント管理',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: reducedHeight * 0.25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.05,
                        backgroundColor: Colors.grey,
                        backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                            ? NetworkImage(profilePicUrl)
                            : null,
                        child: (profilePicUrl == null || profilePicUrl.isEmpty)
                            ? Icon(Icons.person, size: screenWidth * 0.06, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction?.name ?? 'ユーザー名を取得中...',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction?.uid ?? '0000-0000-0000',
                            style: TextStyle(fontSize: screenWidth * 0.03),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: reducedHeight * 0.25,
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
                          fontSize: screenWidth * 0.04,
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: reducedHeight * 0.25,
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
                Container(
                  height: screenHeight * 0.35,
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    mainAxisSpacing: screenHeight * 0.002,
                    crossAxisSpacing: screenWidth * 0.01,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(12, (index) {
                      String displayText;
                      if (index == 9) {
                        displayText = 'C';
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
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final isSuccess = await ref.read(transactionProvider.notifier).updateUserPoints(ref);
                          if (isSuccess) {
                            Navigator.pushNamed(context, '/pointManagementConfirm');
                          } else {
                            // 포인트 부족 또는 오류 시 Snackbar 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ポイントが不足しています。')),
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Color(0xFF1D2538),
                            borderRadius: BorderRadius.circular(screenWidth * 0.07),
                          ),
                          child: Center(
                            child: Text(
                              '送る',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(transactionProvider.notifier).clearTransactionState();
                          Navigator.pop(context);
                          ref.read(qrViewModelProvider.notifier).resumeCamera();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenWidth * 0.07),
                            border: Border.all(color: Color(0xFF1D2538), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '受け取る',
                              style: TextStyle(
                                color: Color(0xFF1D2538),
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
