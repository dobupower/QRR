import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewModel/owner_settings_tab_view_model.dart';
import '../../../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerSettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointLimit = ref.watch(ownerSettingProvider);

    if (pointLimit == null) {
      // 로딩 상태 표시
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SettingsBody(
        pointLimit: pointLimit,
        onPointLimitChange: (newLimit) {
          ref.read(ownerSettingProvider.notifier).updatePointLimit(newLimit);
        },
      ),
    );
  }
}

class SettingsBody extends StatefulWidget {
  final int pointLimit;
  final ValueChanged<int> onPointLimitChange;

  SettingsBody({
    required this.pointLimit,
    required this.onPointLimitChange,
  });

  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  late bool _notificationStatus;

  @override
  void initState() {
    super.initState();
    _notificationStatus = PreferencesManager.instance.getNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목
          SizedBox(height: screenHeight * 0.08),
          Text(
            localizations?.ownerHomeScreenSetting ?? '', // 설정 화면의 제목
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.03),

          // 설정 항목
          Expanded(
            child: ListView(
              children: [
                // 포인트 리미트 설정
                SettingsSection(
                  title: localizations?.ownerSettingsTaPointLimit ?? '',
                  trailingWidget: Text(
                    '${NumberFormat("#,###").format(widget.pointLimit)} pt',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () => Navigator.pushNamed(context, '/pointLimit'),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: screenHeight * 0.02,
                ),

                // 알림 토글
                SettingsSection(
                  title: localizations?.ownerSettingsTabNotification ?? '',
                  trailingWidget: Switch(
                    value: _notificationStatus,
                    onChanged: (value) async {
                      await PreferencesManager.instance.setNotificationStatus(value);
                      setState(() {
                        _notificationStatus = value;
                      });
                      print('Notification status updated to $value');
                    },
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: screenHeight * 0.02,
                ),

                // 개인정보 처리방침
                SettingsSection(
                  title: localizations?.ownerSettingsTabPrivacyPolicy ?? '',
                  onTap: () => Navigator.pushNamed(context, '/privacyPolicy'),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: screenHeight * 0.02,
                ),

                // 이용약관
                SettingsSection(
                  title: localizations?.ownerSettingsTabTermsOfservice ?? '',
                  onTap: () => Navigator.pushNamed(context, '/termsOfservice'),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: screenHeight * 0.02,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  SettingsSection({
    required this.title,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Align the row to take minimal space
        children: [
          if (trailingWidget != null) trailingWidget!,
          SizedBox(width: screenWidth * 0.01), // Add some spacing
          Icon(
            Icons.arrow_forward_ios, // `>` icon
            size: screenWidth * 0.045,
            color: Colors.grey,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
