import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/point_management_view_model.dart';
import '../../../viewModel/qrcode_scan_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PointManagementScreen extends ConsumerStatefulWidget {
  @override
  _PointManagementScreenState createState() => _PointManagementScreenState();
}

class _PointManagementScreenState extends ConsumerState<PointManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).fetchUserData(ref, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final transaction = ref.watch(transactionProvider);
    final localizations = AppLocalizations.of(context);

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                Text(
                  localizations?.pointManagementConfirmScreenTitle ?? '',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                UserProfileSection(transaction: transaction),
                SizedBox(height: screenSize.height * 0.015),
                PointsInfoSection(transaction: transaction),
                SizedBox(height: screenSize.height * 0.015),
                TransactionTypeSelector(),
                SizedBox(height: screenSize.height * 0.015),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${NumberFormat("#,###").format(transaction?.amount ?? 0)} pt',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                NumberPad(),
                SizedBox(height: screenSize.height * 0.02),
                TransactionActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserProfileSection extends StatelessWidget {
  final dynamic transaction;

  const UserProfileSection({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final profilePicUrl = transaction?.profilePicUrl;
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
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
            child: profilePicUrl == null
                ? Icon(Icons.person, color: Colors.white, size: screenWidth * 0.06)
                : null,
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction?.name ?? localizations?.pointManagementConfirmScreenNameLoading ?? '',
                style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
              ),
              Text(
                transaction?.uid ?? '0000-0000-0000',
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PointsInfoSection extends StatelessWidget {
  final dynamic transaction;

  const PointsInfoSection({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations?.pointManagementScreenPoint ?? '', style: TextStyle(fontSize: screenWidth * 0.04)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${NumberFormat("#,###").format(transaction?.point ?? 0)} pt',
              style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.03),
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
              text: localizations?.pointManagementConfirmScreenCharge1 ?? '',
              isSelected: transaction?.type == localizations?.pointManagementConfirmScreenCharge1 ?? false,
              onPressed: () {
                ref.read(transactionProvider.notifier).updateTransactionType(localizations?.pointManagementConfirmScreenCharge1 ?? '');
              },
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: ActionButton(
              text: localizations?.pointManagementConfirmScreenChange ?? '',
              isSelected: transaction?.type == localizations?.pointManagementConfirmScreenChange ?? false,
              onPressed: () {
                ref.read(transactionProvider.notifier).updateTransactionType(localizations?.pointManagementConfirmScreenChange ?? '');
              },
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: ActionButton(
              text: localizations?.pointManagementConfirmScreenSpend ?? '',
              isSelected: transaction?.type == localizations?.pointManagementConfirmScreenSpend ?? false,
              onPressed: () {
                ref.read(transactionProvider.notifier).updateTransactionType(localizations?.pointManagementConfirmScreenSpend ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NumberPad extends ConsumerWidget {
  const NumberPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2,
      mainAxisSpacing: screenHeight * 0.002,
      crossAxisSpacing: screenWidth * 0.01,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
    );
  }
}

class TransactionActions extends ConsumerWidget {
  const TransactionActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final errorMessage = await ref.read(transactionProvider.notifier).updateUserPoints(ref, context);
              if (errorMessage == null) {
                Navigator.pushNamed(context, '/pointManagementConfirm');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
              decoration: BoxDecoration(
                color: Color(0xFF1D2538),
                borderRadius: BorderRadius.circular(screenWidth * 0.07),
              ),
              child: Center(
                child: Text(
                  localizations?.pointManagementScreenSubmit ?? '',
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
                  localizations?.pointManagementConfirmScreenHome ?? '',
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