import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/tab_view_model.dart';
import 'user_settings_tab.dart';
import 'qr_tab.dart';
import 'user_search_screen.dart'; // 유저 검색 화면
import 'user_transfer_screen.dart'; // 유저 포인트 거래 화면
import 'user_transfer_confirm_screen.dart'; // 유저 포인트 거래 확인 화면
import 'user_transaction_history_screen.dart';
import '../event_home.dart';
import 'user_account_screen.dart';
import '../verify_password_screen.dart'; // 비밀번호 확인 화면 추가
import 'update_pubid_screen.dart';
import '../privacy_policy_screen.dart';
import '../terms_of_service_screen.dart';

// UserHomeScreen 클래스는 ConsumerWidget을 사용하여 상태 관리
class UserHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // tabViewModelProvider를 구독하여 현재 선택된 탭의 인덱스를 가져옴
    final currentIndex = ref.watch(tabViewModelProvider);

    // 각 탭에 해당하는 화면을 저장하는 리스트
    final List<Widget> pages = [
      EventPageView(),
      UserTransactionHistoryScreen(),
      QrTabNavigator(), // QR 코드 스캔 및 포인트 관리 페이지
      UserAccountNavigator(), // UserAccountNavigator로 교체
      UserSettingsNavigator(),
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
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '取引履歴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'アカウント',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
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
class QrTabNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/userSearch': // 새 경로 추가
            return MaterialPageRoute(
              builder: (context) => UserSearchScreen(), // user_transfer_screen.dart에 있는 화면으로 연결
            );
          case '/userTransfer': // 새 경로 추가
            return MaterialPageRoute(
              builder: (context) => UserTransferScreen(), // user_transfer_screen.dart에 있는 화면으로 연결
            );
          case '/userTransferConfirm': // 새 경로 추가
            return MaterialPageRoute(
              builder: (context) => UserTransferConfirmScreen(), // user_transfer_screen.dart에 있는 화면으로 연결
            );
          default:
            return MaterialPageRoute(
              builder: (context) => QrTab(),
            );
        }
      },
    );
  }
}

// UserAccountScreen을 위한 Navigator
class UserAccountNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/verifyPassword': // VerifyPasswordScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => VerifyPasswordScreen(),
            );
          case '/updatePubid':
            return MaterialPageRoute(
              builder: (context) => UpdatePubIdScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => UserAccountScreen(), // 기본 UserAccountScreen
            );
        }
      },
    );
  }
}

// UserSettingsTab을 위한 Navigator
class UserSettingsNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/privacyPolicy': // PrivacyPolicyScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => PrivacyPolicyScreen(),
            );
          case '/termsOfservice': // PrivacyPolicyScreen으로 이동하는 경로 추가
            return MaterialPageRoute(
              builder: (context) => TermsOfServiceScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => UserSettingsTab(), // 기본 UserSettingsTab
            );
        }
      },
    );
  }
}
