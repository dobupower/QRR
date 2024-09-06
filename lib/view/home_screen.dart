import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // For tracking the currently selected tab

  // Pages for each tab in the bottom navigation bar
  final List<Widget> _pages = [
    HomeTab(),
    TransactionHistoryTab(),
    ScanTab(),
    AccountTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '炭火やきとり とりとん',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title in the AppBar
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove shadow
      ),
      body: _pages[_currentIndex], // Display the selected tab's page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // The selected index of the bar
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
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
        type: BottomNavigationBarType.fixed, // Fixed bar with labels for each item
        selectedItemColor: Colors.black, // Color when selected
        unselectedItemColor: Colors.grey, // Color when not selected
        showUnselectedLabels: true, // Show labels for unselected items
      ),
    );
  }
}

// Dummy widgets for each tab content
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

class ScanTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
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

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('設定'),
    );
  }
}
