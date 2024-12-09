import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/transaction_history_view_model.dart';
import '../../../model/transaction_history_model.dart'; // TransactionHistory 모델 임포트

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: EdgeInsets.only(
            left: screenSize.width * 0.05,
            top: screenSize.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 제목
              SizedBox(height: screenSize.height * 0.05),
              const TransactionHistoryHeader(), // 헤더 섹션
              SizedBox(height: screenSize.height * 0.02),
              Expanded(
                child: TransactionHistoryContent(
                  scrollController: _scrollController,
                ), // 거래 내역 콘텐츠 섹션
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 헤더 섹션 위젯
class TransactionHistoryHeader extends StatelessWidget {
  const TransactionHistoryHeader();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      '取引履歴',
      style: TextStyle(
        fontSize: screenWidth * 0.06,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

// 거래 내역 콘텐츠 섹션 위젯
class TransactionHistoryContent extends ConsumerWidget {
  final ScrollController scrollController;

  const TransactionHistoryContent({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionHistory = ref.watch(transactionHistoryProvider);

    return transactionHistory.when(
      data: (transactions) {
        return transactions.isEmpty
            ? EmptyTransactionMessage() // 거래 내역이 없으면 EmptyTransactionMessage
            : ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionListItem(transaction: transaction);
                },
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()), // 로딩 표시
      error: (error, stackTrace) => ErrorDisplay(error: error),
    );
  }
}

// 거래 내역이 없을 때 표시하는 위젯
class EmptyTransactionMessage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              '取引履歴がありません', // 거래 내역이 없습니다
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 데이터 로딩 중일 때 표시하는 위젯
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

// 에러가 발생했을 때 표시하는 위젯
class ErrorDisplay extends StatelessWidget {
  final Object error;

  const ErrorDisplay({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('エラーが発生しました: $error'),
    );
  }
}

// 개별 거래 내역 항목을 보여주는 위젯
class TransactionListItem extends StatelessWidget {
  final TransactionHistory transaction;

  const TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final dateFormat = DateFormat('yyyy年M月d日 H時m分');
    final formattedDate = dateFormat.format(transaction.timestamp);
    final isPositive = transaction.points > 0;

    // 포인트의 색상 설정
    Color pointsColor = isPositive ? Colors.green : Colors.red;
    final pointsText = '${isPositive ? '+' : ''}${transaction.points} pt';

    return Column(
      children: [
        ListTile(
          title: Text(
            transaction.message,
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
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
                    fontSize: screenSize.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: pointsColor,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenSize.width * 0.03,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: screenSize.height * 0.02,
          color: Colors.grey.shade300,
          thickness: 1, // 두께 설정 가능
        ),
      ],
    );
  }
}
