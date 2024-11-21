import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/transaction_history_view_model.dart';

class UserTransactionHistoryScreen extends ConsumerStatefulWidget {
  @override
  _UserTransactionHistoryScreenState createState() =>
      _UserTransactionHistoryScreenState();
}

class _UserTransactionHistoryScreenState
    extends ConsumerState<UserTransactionHistoryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transactionHistoryProvider.notifier)
          .fetchUserTransactionHistory(isInitialLoad: true);
    });
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
      // 스크롤이 끝에 도달하면 추가 데이터 로드
      ref
          .read(transactionHistoryProvider.notifier)
          .fetchUserTransactionHistory();
    }
  }

  Future<void> _refreshData() async {
    // 데이터를 갱신
    await ref
        .read(transactionHistoryProvider.notifier)
        .fetchUserTransactionHistory(isInitialLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

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
              left: screenSize.width * 0.05,
              top: screenHeight * 0.03,
            ),
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

                // 거래 내역 리스트 또는 "거래 기록이 없습니다" 메시지
                Expanded(
                  child: transactionHistory.when(
                    data: (transactions) {
                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: transactions.isEmpty ? 1 : transactions.length,
                        itemBuilder: (context, index) {
                          if (transactions.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.3),
                              child: Center(
                                child: Text(
                                  '取引履歴がありません', // 거래 내역이 없을 때 표시
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }

                          final transaction = transactions[index];
                          final dateFormat = DateFormat('yyyy年M月d日 H時m分');
                          final formattedDate =
                              dateFormat.format(transaction.timestamp);
                          final isPositive = transaction.points > 0;

                          // points의 색상 설정
                          Color pointsColor =
                              isPositive ? Colors.green : Colors.red;
                          final pointsText =
                              '${isPositive ? '+' : ''}${transaction.points} pt';

                          return Column(
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
                                thickness: 1, // 두께 설정 가능
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                    error: (error, stackTrace) => ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Text('エラーが発生しました: $error'),
                        ),
                      ],
                    ),
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
