import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/tab_view_model.dart';
import 'qrcode_scan_tab.dart';
import 'owner_settings_tab.dart';
import 'point_management_screen.dart';
import 'point_management_confirm_screen.dart';
import 'meber_input_screen.dart';
import 'owner_transaction_history_screen.dart';
import '../event_home.dart';
import 'point_limit_screen.dart';
import '../privacy_policy_screen.dart';
import '../terms_of_service_screen.dart';
import 'owner_account_screen.dart';
import '../verify_password_screen.dart';
import 'photo_update_screen.dart';
import 'owner_signup_update_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // tabViewModelProvider를 구독하여 현재 선택된 탭의 인덱스를 가져옴
    final currentIndex = ref.watch(tabViewModelProvider);
    final localizations = AppLocalizations.of(context);

    // 각 탭에 해당하는 화면을 저장하는 리스트
    final List<Widget> pages = [
      EventPageView(),
      OwnerTransactionHistoryScreen(),
      ScanTabNavigator(), // QR 코드 스캔 및 포인트 관리 페이지
      OwnerAccountTab(),
      OwnerSettings(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex, // 현재 선택된 탭의 인덱스 설정
        children: pages, // 탭별로 저장된 페이지
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // 현재 선택된 탭의 인덱스를 설정
        onTap: (index) {
          // 탭을 선택할 때 ViewModel을 통해 탭 인덱스 변경
          ref.read(tabViewModelProvider.notifier).setTabIndex(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations?.ownerHomeScreenHome ?? '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: localizations?.ownerHomeScreenTransactionHistory ?? '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: localizations?.ownerHomeScreenAccount ?? '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations?.ownerHomeScreenSetting ?? '',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

// QR 코드 스캔 및 포인트 관리 페이지를 위한 Navigator
class ScanTabNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/pointManagement':
            return MaterialPageRoute(
              builder: (context) => PointManagementScreen(),
            );
          case '/pointManagementConfirm':
            return MaterialPageRoute(
              builder: (context) => PointManagementConfirmScreen(),
            );
          case '/memberInput':
            return MaterialPageRoute(
              builder: (context) => MemberInputScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => ScanTab(),
            );
        }
      },
    );
  }
}

class OwnerSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/', // 초기 경로 설정
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/pointLimit':
            return MaterialPageRoute(
              builder: (context) => PointLimitScreen(),
            );
          case '/privacyPolicy': // PrivacyPolicyScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => PrivacyPolicyScreen(),
            );
          case '/termsOfservice': // TermsOfServiceScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => TermsOfServiceScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => OwnerSettingsTab(),
            );
        }
      },
    );
  }
}

// QR 코드 스캔 및 포인트 관리 페이지를 위한 Navigator
class OwnerAccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/SignupUpdate': // VerifyPasswordScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => OwnerSignUpUpdateScreen(),
            );
            
          case '/verifyPassword': // VerifyPasswordScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => VerifyPasswordScreen(),
            );
          case '/photoUpdate': // VerifyPasswordScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => PhotoUpdateScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => OwnerAccountScreen(),
            );
        }
      },
    );
  }
}
