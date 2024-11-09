import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 숫자 포맷을 위해 사용
import '../../../viewModel/point_management_view_model.dart';

class UserTransferScreen extends ConsumerStatefulWidget {
  @override
  _UserTransferScreenState createState() => _UserTransferScreenState();
}

class _UserTransferScreenState extends ConsumerState<UserTransferScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(transactionProvider.notifier).fetchUserData(ref);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final transaction = ref.watch(transactionProvider);
    final profilePicUrl = transaction?.profilePicUrl;
    final numberFormat = NumberFormat("#,###");

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Text(
              'ポイント入力',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundColor: Colors.grey,
                    backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: (profilePicUrl == null || profilePicUrl.isEmpty)
                        ? Icon(Icons.person, size: screenWidth * 0.15, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    transaction?.name ?? 'ユーザー名',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    transaction?.uid ?? '000-000-0000',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015), // 간격을 좁힘
            Align(
              alignment: Alignment.centerRight, // 오른쪽 정렬
              child: Text(
                '${numberFormat.format(transaction?.amount ?? 0)} pt',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015), // 간격을 좁힘
            Container(
              height: screenHeight * 0.35,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 2,
                mainAxisSpacing: screenHeight * 0.01,
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
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final isSuccess = await ref.read(transactionProvider.notifier).updateUserPoints(ref);
                  if (isSuccess) {
                    Navigator.pushNamed(context, '/pointManagementConfirm');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ポイントが不足しています。')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D2538),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.35,
                    vertical: screenHeight * 0.015,
                  ),
                ),
                child: Text(
                  '確認',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
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
