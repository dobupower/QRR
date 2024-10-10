import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/preferences_manager.dart'; // PreferencesManager 클래스 import

class OwnerSettingsTab extends StatelessWidget {
  const OwnerSettingsTab({Key? key}) : super(key: key);

  // 로그아웃 및 SharedPreferences 초기화 함수
  Future<void> _logout(BuildContext context) async {
    try {
      // FirebaseAuth 로그아웃
      await FirebaseAuth.instance.signOut();

      // PreferencesManager를 사용하여 SharedPreferences 초기화
      await PreferencesManager.instance.logout();

      // 로그아웃 후 첫 화면으로 이동 (FirstScreen 또는 LoginScreen 등으로)
      Navigator.pushReplacementNamed(context, '/First');
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('設定'), // "설정" 텍스트
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _logout(context), // 로그아웃 버튼 클릭 시 로그아웃 처리
            child: Text('ログアウト'), // "로그아웃" 텍스트 (일본어로 표시)
          ),
        ],
      ),
    );
  }
}
