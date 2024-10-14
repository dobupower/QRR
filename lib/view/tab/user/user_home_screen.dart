import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/tab_view_model.dart';
import 'user_settings_tab.dart';
import 'qr_tab.dart';

// UserHomeScreen 클래스는 ConsumerWidget을 사용하여 상태 관리
class UserHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // tabViewModelProvider를 구독하여 현재 선택된 탭의 인덱스를 가져옴
    final currentIndex = ref.watch(tabViewModelProvider);

    // 각 탭에 해당하는 화면을 저장하는 리스트
    final List<Widget> pages = [
      HomeTab(),
      TransactionHistoryTab(),
      QrTab(),
      AccountTab(),
      UserSettingsTab(),
    ];

    return Scaffold(
      // 현재 선택된 페이지를 표시
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

// 각 탭에 해당하는 화면들
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
