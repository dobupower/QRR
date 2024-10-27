import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/tab_view_model.dart';
import 'qrcode_scan_tab.dart';
import 'owner_settings_tab.dart';
import 'point_management_screen.dart';  // 포인트 관리 스크린 임포트

class OwnerHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // tabViewModelProvider를 구독하여 현재 선택된 탭의 인덱스를 가져옴
    final currentIndex = ref.watch(tabViewModelProvider);

    // 각 탭에 해당하는 화면을 저장하는 리스트
    final List<Widget> pages = [
      HomeTab(),
      TransactionHistoryTab(),
      Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/pointManagement') {
            return MaterialPageRoute(
              builder: (context) => PointManagementScreen(),  // 스캔 성공 후 포인트 관리 화면으로 이동
            );
          }
          return MaterialPageRoute(
            builder: (context) => ScanTab(),  // 기본 ScanTab
          );
        },
      ), // QR 코드 스캔 탭을 Navigator로 관리
      AccountTab(),
      OwnerSettingsTab(),
    ];

    return Scaffold(
      body: pages[currentIndex],
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

// 각 탭에 해당하는 더미 화면들
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('ホーム'),
    );
  }
}

class TransactionHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('取引履歴'),
    );
  }
}

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('アカウント'),
    );
  }
}