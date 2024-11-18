import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/user_point_uid_view_model.dart';
import '../../../model/user_model.dart';

class UserTransferScreen extends ConsumerStatefulWidget {
  @override
  _UserTransferScreenState createState() => _UserTransferScreenState();
}

class _UserTransferScreenState extends ConsumerState<UserTransferScreen> {
  final numberFormat = NumberFormat("#,###");

  AsyncValue<List<User>>? userState;

  @override
  void initState() {
    super.initState();
    userState = ref.read(userPointsUidProvider).userState;
  }

  @override
  Widget build(BuildContext context) {
    final transactionAmount = ref.watch(userPointsUidProvider).transactionState.whenData((transaction) => transaction.amount).value ?? 0;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: userState!.when(
          data: (users) {
            if (users.isEmpty) {
              return Center(child: Text('사용자를 찾을 수 없습니다.'));
            }
            final user = users.first;

            return Padding(
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
                          foregroundImage: user.profilePicUrl != null
                              ? NetworkImage(user.profilePicUrl!)
                              : null,
                          child: user.profilePicUrl == null
                              ? Icon(Icons.person, size: screenWidth * 0.15, color: Colors.white)
                              : null,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user.uid,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${numberFormat.format(transactionAmount)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'pt',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.35,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      mainAxisSpacing: screenHeight * 0.005,
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
                              final currentAmount = transactionAmount.toString();
                              if (currentAmount.isNotEmpty && currentAmount != '0') {
                                final newAmount = currentAmount.substring(0, currentAmount.length - 1);
                                ref.read(userPointsUidProvider.notifier).updateAmount(int.parse(newAmount.isEmpty ? '0' : newAmount));
                              }
                            },
                          );
                        } else {
                          displayText = index == 10 ? '0' : '${index + 1}';
                        }

                        return GestureDetector(
                          onTap: () {
                            if (displayText == 'C') {
                              ref.read(userPointsUidProvider.notifier).updateAmount(0);
                            } else {
                              final currentAmount = transactionAmount.toString();
                              if (currentAmount == '0') {
                                final newAmountStr = displayText;
                                ref.read(userPointsUidProvider.notifier).updateAmount(int.parse(newAmountStr));
                              } else if (currentAmount.length < 9) {
                                final newAmountStr = currentAmount + displayText;
                                ref.read(userPointsUidProvider.notifier).updateAmount(int.parse(newAmountStr));
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
                      onPressed: transactionAmount > 0
                          ? () async {
                              final success = await ref.read(userPointsUidProvider.notifier).performTransaction(user);

                              if (success) {
                                Navigator.pushNamed(context, '/userTransferConfirm');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('포인트가 부족합니다.')),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: transactionAmount > 0 ? Color(0xFF1D2538) : Colors.grey,
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
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('오류 발생: $error')),
        ),
      ),
    );
  }
}
