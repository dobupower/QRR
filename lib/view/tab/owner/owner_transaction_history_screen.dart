import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/transaction_history_view_model.dart';

class OwnerTransactionHistoryScreen extends ConsumerStatefulWidget {
  @override
  _OwnerTransactionHistoryScreenState createState() =>
      _OwnerTransactionHistoryScreenState();
}

class _OwnerTransactionHistoryScreenState
    extends ConsumerState<OwnerTransactionHistoryScreen> {
  DateTime? selectedDate;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (selectedDate != null) {
        ref
            .read(transactionHistoryProvider.notifier)
            .fetchOwnerTransactionHistory();
      }
    }
  }

  Future<void> _refreshData() async {
    if (selectedDate != null) {
      await ref
          .read(transactionHistoryProvider.notifier)
          .fetchOwnerTransactionHistory(isInitialLoad: true);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      ref.read(transactionHistoryProvider.notifier).fetchOwnerTransactionHistory(
            isInitialLoad: true,
            selectedDate: selectedDate,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderRadius = screenWidth * 0.08; // 상대적 BorderRadius
    final buttonHeight = screenHeight * 0.06; // 고정된 버튼 높이
    final buttonWidth = screenWidth * 0.9; // 고정된 버튼 너비

    final transactionHistory = ref.watch(transactionHistoryProvider);

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05, top: screenHeight * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 제목
                SizedBox(height: screenHeight * 0.05),
                Text(
                  '取引履歴',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // 날짜 선택 필터
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.02),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.7,
                              ),
                              child: Text(
                                selectedDate != null
                                    ? DateFormat('yyyy年 MM月 dd日')
                                        .format(selectedDate!)
                                    : '日付選択',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.04,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (selectedDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = null;
                              });
                              ref
                                  .read(transactionHistoryProvider.notifier)
                                  .fetchOwnerTransactionHistory(isInitialLoad: true);
                            },
                            child: Icon(Icons.cancel_outlined,
                                color: Colors.grey, size: screenWidth * 0.05),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // 거래 내역 리스트 또는 "거래 기록이 없습니다" 메시지
                Expanded(
                  child: selectedDate == null
                      ? Center(
                          child: Text(
                            '日付を選択してください',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : transactionHistory.when(
                          data: (transactions) {
                            if (transactions.isEmpty) {
                              return Center(
                                child: Text(
                                  '取引履歴がありません',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                final dateFormat = DateFormat('yyyy年M月d日 H時m分');
                                final formattedDate = dateFormat.format(transaction.timestamp);
                                final isPositive = transaction.points > 0;

                                // points의 색상 설정
                                Color pointsColor = isPositive ? Colors.green : Colors.red;
                                final pointsText = '${isPositive ? '+' : ''}${transaction.points} pt';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        transaction.message,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Align(
                                        alignment: Alignment.centerRight,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              pointsText,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                fontWeight: FontWeight.bold,
                                                color: pointsColor,
                                              ),
                                            ),
                                            SizedBox(height: screenHeight * 0.005),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: screenWidth * 0.03,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: screenHeight * 0.02,
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          loading: () => Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) =>
                              Center(child: Text('エラーが発生しました: $error')),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
