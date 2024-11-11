import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/user_point_uid_view_model.dart';
import '../../../model/user_model.dart';
import '../../../model/user_transaction_model.dart';

class UserTransferConfirmScreen extends ConsumerStatefulWidget {
  @override
  _UserTransferConfirmScreenState createState() => _UserTransferConfirmScreenState();
}

class _UserTransferConfirmScreenState extends ConsumerState<UserTransferConfirmScreen> {
  final numberFormat = NumberFormat("#,###");
  AsyncValue<UserTransaction>? transaction;
  AsyncValue<List<User>>? userState;

  @override
  void initState() {
    super.initState();
    // transaction과 userState를 한 번만 가져오도록 초기화
    transaction = ref.read(userPointsUidProvider).transactionState;
    userState = ref.read(userPointsUidProvider).userState;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final user = userState?.when(
      data: (users) => users.isNotEmpty ? users.first : null,
      loading: () => null,
      error: (error, _) => null,
    );

    // 사용자 프로필 URL 가져오기
    final profilePicUrl = user?.profilePicUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.05),
              child: Text(
                '完了',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // 사용자 정보 영역
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.07,
                    backgroundColor: Colors.grey,
                    backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: (profilePicUrl == null || profilePicUrl.isEmpty)
                        ? Icon(Icons.person, size: screenWidth * 0.07, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'ユーザー名',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.uid ?? '0000-0000-0000',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Divider(thickness: 1, color: Colors.grey.shade300),
            SizedBox(height: screenHeight * 0.03),

            // 포인트 표시 영역
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${numberFormat.format(transaction?.value?.amount ?? 0)}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    'pt',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // "受け取り完了" 버튼
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.12,
                  vertical: screenHeight * 0.012,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                ),
                child: Text(
                  '受け取り完了',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Spacer(),

            // "ホームへ" 버튼
            Center(
              child: GestureDetector(
                onTap: () {
                  ref.read(userPointsUidProvider.notifier).clearUserAndTransactionState();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF1D2538),
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
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
