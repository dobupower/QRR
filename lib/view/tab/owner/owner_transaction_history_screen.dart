import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/transaction_history_view_model.dart';
import '../../../model/transaction_history_model.dart'; // TransactionHistory 모델 임포트
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      // 선택된 날짜에 맞는 거래 내역을 다시 불러옴
      await ref.read(transactionHistoryProvider.notifier).fetchOwnerTransactionHistory(
        isInitialLoad: true, 
        selectedDate: selectedDate,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: screenSize.width * 0.05,
                top: screenSize.height * 0.03,
                right: screenSize.width * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.05),
                  const TransactionHistoryHeader(), // 헤더 섹션
                  SizedBox(height: screenSize.height * 0.02),
                  DateFilterSection(
                    selectedDate: selectedDate,
                    onSelectDate: () => _selectDate(context),
                    onClearDate: () {
                      setState(() {
                        selectedDate = null;
                      });
                      ref
                          .read(transactionHistoryProvider.notifier)
                          .fetchOwnerTransactionHistory(isInitialLoad: true);
                    },
                  ), // 날짜 선택 필터 섹션
                  SizedBox(height: screenSize.height * 0.02),
                  TransactionHistoryContent(
                    selectedDate: selectedDate,
                  ), // 거래 내역 콘텐츠 섹션
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 헤더 섹션 위젯 (변경 없음)
class TransactionHistoryHeader extends StatelessWidget {
  const TransactionHistoryHeader();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      AppLocalizations.of(context)?.ownerHomeScreenTransactionHistory ?? '',
      style: TextStyle(
        fontSize: screenWidth * 0.06,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

// 날짜 선택 필터 섹션 위젯 (변경 없음)
class DateFilterSection extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;

  const DateFilterSection({
    required this.selectedDate,
    required this.onSelectDate,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderRadius = screenWidth * 0.08;
    final buttonHeight = screenHeight * 0.06;
    final buttonWidth = screenWidth * 0.9;
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onSelectDate,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.015,
        ),
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
                        ? DateFormat(localizations?.ownerTransactionHistoryScreenDataFormat1 ?? '').format(selectedDate!)
                        : localizations?.ownerTransactionHistoryScreenSelectDate1 ?? '',
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
                onTap: onClearDate,
                child: Icon(Icons.cancel_outlined,
                    color: Colors.grey, size: screenWidth * 0.05),
              ),
          ],
        ),
      ),
    );
  }
}

// 거래 내역 콘텐츠 섹션 위젯 (수정됨)
class TransactionHistoryContent extends ConsumerWidget {
  final DateTime? selectedDate;

  const TransactionHistoryContent({
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final transactionHistory = ref.watch(transactionHistoryProvider);
    final localizations = AppLocalizations.of(context);

    if (selectedDate == null) {
      return SizedBox(
        height: screenSize.height * 0.6,
        child: Center(
          child: Text(
            localizations?.ownerTransactionHistoryScreenSelectDate2 ?? '',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return transactionHistory.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Text(
              localizations?.ownerTransactionHistoryScreenNoHistory ?? '',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.grey,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var transaction in transactions) ...[
              TransactionListItem(transaction: transaction),
              SizedBox(height: screenSize.height * 0.01),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text(localizations?.ownerAccountScreenError ?? '' +': $error')),
    );
  }
}

// 개별 거래 내역 항목을 보여주는 위젯 (변경 없음)
class TransactionListItem extends StatelessWidget {
  final TransactionHistory transaction;

  const TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final dateFormat = DateFormat(AppLocalizations.of(context)?.ownerTransactionHistoryScreenDataFormat2 ?? '');
    final formattedDate = dateFormat.format(transaction.timestamp);
    final isPositive = transaction.points > 0;

    // 포인트의 색상 설정
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
                SizedBox(height: screenSize.height * 0.005),
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
          height: screenSize.height * 0.02,
          color: Colors.grey.shade300,
          thickness: 1,
        ),
      ],
    );
  }
}
