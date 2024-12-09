import 'package:flutter/material.dart';
import '../../../services/preferences_manager.dart';

class UserSettingsTab extends StatefulWidget {
  @override
  _UserSettingsTabState createState() => _UserSettingsTabState();
}

class _UserSettingsTabState extends State<UserSettingsTab> {
  late bool _notificationStatus;

  @override
  void initState() {
    super.initState();
    _notificationStatus = PreferencesManager.instance.getNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsBody(
        notificationStatus: _notificationStatus,
        onNotificationToggle: (value) async {
          await PreferencesManager.instance.setNotificationStatus(value);
          setState(() {
            _notificationStatus = value;
          });
        },
      ),
    );
  }
}

// Body를 별도의 위젯으로 분리
class SettingsBody extends StatelessWidget {
  final bool notificationStatus;
  final ValueChanged<bool> onNotificationToggle;

  SettingsBody({
    required this.notificationStatus,
    required this.onNotificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    const dividerColor = Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.05),
          // 상단 제목
          Text(
            '設定', // 설정 화면의 제목
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // 제목과 내용 간격
          // 알림 토글
          NotificationToggle(
            notificationStatus: notificationStatus,
            onToggle: onNotificationToggle,
          ),
          Divider(
            color: dividerColor[300],
            thickness: 1,
            height: screenHeight * 0.03,
          ),
          // 설정 항목 1: 개인정보 처리방침
          SettingsListTile(
            title: 'プライバシーポリシー', // 개인정보 처리방침
            onTap: () => Navigator.pushNamed(context, '/privacyPolicy'),
          ),
          Divider(
            color: dividerColor[300],
            thickness: 1,
            height: screenHeight * 0.03,
          ),
          // 설정 항목 2: 이용약관
          SettingsListTile(
            title: '利用規約', // 이용약관
            onTap: () => Navigator.pushNamed(context, '/termsOfservice'),
          ),
          Divider(
            color: dividerColor[300],
            thickness: 1,
          ),
        ],
      ),
    );
  }
}

// 알림 토글 스위치를 별도의 위젯으로 분리
class NotificationToggle extends StatelessWidget {
  final bool notificationStatus;
  final ValueChanged<bool> onToggle;

  NotificationToggle({
    required this.notificationStatus,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '通知', // 알림 토글 텍스트
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: Switch(
        value: notificationStatus,
        onChanged: onToggle,
      ),
    );
  }
}

// 설정 항목을 위한 공통 ListTile 위젯
class SettingsListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  SettingsListTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: Theme.of(context).iconTheme.size,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
