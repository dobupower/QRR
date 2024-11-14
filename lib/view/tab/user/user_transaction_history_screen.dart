import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/transaction_history_view_model.dart';

class UserTransactionHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionHistory = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 제목
            Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Text(
                '取引履歴',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // 거래 내역 리스트
            Expanded(
              child: transactionHistory.when(
                data: (transactions) => ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final dateFormat = DateFormat('yyyy年M月d日H時m分');
                    final formattedDate = dateFormat.format(transaction.timestamp);
                    final isPositive = transaction.points > 0;
                    final pointsText = '${isPositive ? '+' : ''}${transaction.points} pt';
                    final pointsColor = isPositive ? Colors.green : Colors.red;

                    return ListTile(
                      title: Text(
                        transaction.name, // 거래 상대방 이름 표시
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.transactionType, // 거래 유형 표시
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            formattedDate, // 거래 날짜 및 시간 표시
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Text(
                        pointsText,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: pointsColor),
                      ),
                    );
                  },
                ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text('エラーが発生しました: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
