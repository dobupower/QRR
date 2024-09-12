import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// HomeScreen 클래스는 StatefulWidget을 상속받아 상태 관리를 가능하게 함
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// _HomeScreenState 클래스는 상태를 관리하는 곳으로, 현재 선택된 탭을 관리함
class _HomeScreenState extends State<HomeScreen> {
  // 현재 선택된 탭 인덱스 (0: 첫 번째 탭)
  int _currentIndex = 0;

  // 각 탭에 해당하는 화면을 저장하는 리스트
  final List<Widget> _pages = [
    HomeTab(), // 홈 탭에 해당하는 화면
    TransactionHistoryTab(), // 거래 내역 탭에 해당하는 화면
    ScanTab(), // 스캔 탭에 해당하는 화면 (QR코드 스캔 등)
    AccountTab(), // 계정 정보 탭에 해당하는 화면
    SettingsTab(), // 설정 탭에 해당하는 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱의 상단바 설정
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 자동 생성 방지
        title: Text(
          '炭火やきとり とりとん', // 앱 제목을 표시 (예: "숯불 야키토리 토리톤")
          style: TextStyle(fontWeight: FontWeight.bold), // 텍스트를 굵게 표시
        ),
        centerTitle: true, // 제목을 가운데 정렬
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
        elevation: 0, // 그림자 제거
      ),
      // 현재 선택된 페이지를 표시
      body: _pages[_currentIndex], // 선택된 탭에 해당하는 페이지를 보여줌
      // 하단에 탭 네비게이션을 구현
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // 현재 선택된 탭의 인덱스
        onTap: (index) {
          // 탭을 선택할 때 호출됨
          setState(() {
            _currentIndex = index; // 선택된 탭의 인덱스를 업데이트
          });
        },
        items: [
          // 각 탭에 해당하는 아이콘과 라벨 설정
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // 홈 아이콘
            label: 'ホーム', // 라벨: "홈"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // 히스토리 아이콘
            label: '取引履歴', // 라벨: "거래 내역"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), // QR 코드 스캔 아이콘
            label: '', // 라벨이 없는 중간 아이콘
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), // 계정 아이콘
            label: 'アカウント', // 라벨: "계정"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // 설정 아이콘
            label: '設定', // 라벨: "설정"
          ),
        ],
        type: BottomNavigationBarType.fixed, // 아이템 수에 맞춰 고정된 형태
        selectedItemColor: Colors.black, // 선택된 아이템의 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색상
        showUnselectedLabels: true, // 선택되지 않은 아이템의 라벨도 보여줌
      ),
    );
  }
}

// 각 탭에 해당하는 더미 화면들 (화면을 쉽게 변경할 수 있도록 클래스를 분리)
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('ホーム'), // "홈" 탭의 내용 (중앙에 "홈" 텍스트)
    );
  }
}

class TransactionHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('取引履歴'), // "거래 내역" 탭의 내용
    );
  }
}

class ScanTab extends StatefulWidget {
  @override
  _ScanTabState createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('QR 코드를 스캔하세요'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print('QR 데이터: ${scanData.code}');
      controller.pauseCamera(); // 카메라 멈춤
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('アカウント'), // "계정" 탭의 내용
    );
  }
}

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('設定'), // "설정" 탭의 내용
    );
  }
}
