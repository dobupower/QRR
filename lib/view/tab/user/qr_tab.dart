import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅을 위해 추가
import 'package:qr_flutter/qr_flutter.dart';
import '../../../viewModel/qrcode_make_view_model.dart';
import '../../../viewModel/user_point_state_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.05),
          const QrTabTitle(), // 타이틀 섹션
          SizedBox(height: screenSize.height * 0.03),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(screenSize.width * 0.05),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E8EF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenSize.width * 0.1),
                  topRight: Radius.circular(screenSize.width * 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const QrTabUserInfo(), // 사용자 정보 섹션
                  const Spacer(),
                  const QrTabActions(), // 동작 버튼 섹션
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrTabTitle extends StatelessWidget {
  const QrTabTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(left: screenSize.width * 0.05, top: screenSize.height * 0.03),
      child: Text(
        AppLocalizations.of(context)?.qrTabMember ?? '',
        style: TextStyle(
          color: Colors.black,
          fontSize: screenSize.width * 0.06,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class QrTabUserInfo extends ConsumerWidget {
  const QrTabUserInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrCodeState = ref.watch(qrCodeProvider);
    final userPointsState = ref.watch(userPointsProvider);
    final screenSize = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);

    // 포인트 숫자 포맷
    String formatPoints(int points) {
      return NumberFormat('#,###').format(points);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 회원 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.06),
                Image.asset(
                  'lib/img/point_icon.png',
                  width: screenSize.width * 0.15,
                  height: screenSize.width * 0.15,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.qrTabNumber ?? '',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: const Color(0xFF4A6FA5),
                  ),
                ),
                const SizedBox(height: 8),
                userPointsState.when(
                  data: (userPoints) => Text(
                    userPoints.uid,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  loading: () => Text(localizations?.qrTabLoading ?? ''),
                  error: (error, _) => Text(localizations?.ownerAccountScreenError ?? ''),
                ),
              ],
            ),
            // QR 코드 및 리프레시 버튼
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: const Color.fromARGB(255, 107, 107, 107),
                    size: screenSize.width * 0.08,
                  ),
                  onPressed: () {
                    ref.read(qrCodeProvider.notifier).regenerateQrCode();
                    ref.read(userPointsProvider.notifier).monitorUserPoints();
                  },
                ),
                qrCodeState.when(
                  data: (qrCode) => qrCode != null
                      ? Container(
                          padding: EdgeInsets.all(screenSize.width * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenSize.width * 0.03),
                          ),
                          child: QrImage(
                            data: qrCode.token,
                            version: QrVersions.auto,
                            size: screenSize.width * 0.3,
                            errorCorrectionLevel: QrErrorCorrectLevel.L,
                          ),
                        )
                      : Text(localizations?.qrTabFail1 ?? ''),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text(localizations?.qrTabFail2 ?? ''),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          localizations?.qrTabPoint ?? '',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            color: const Color(0xFF4A6FA5),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            userPointsState.when(
              data: (userPoints) => Text(
                formatPoints(userPoints.points),
                style: TextStyle(
                  fontSize: screenSize.width * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              loading: () => const Text('0'),
              error: (error, _) => Text(localizations?.qrTabFail3 ?? ''),
            ),
            Text(
              'pt',
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class QrTabActions extends StatelessWidget {
  const QrTabActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/userSearch');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, screenSize.height * 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenSize.width * 0.05),
        ),
      ),
      child: Text(
        'ポイントを送る',
        style: TextStyle(
          fontSize: screenSize.width * 0.04,
        ),
      ),
    );
  }
}
