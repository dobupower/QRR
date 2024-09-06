import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 가져오기
import '../model/user_model.dart'; // User 모델 가져오기

// StoreSelectionScreen 클래스 (ConsumerWidget을 상속받아 Riverpod의 상태 관리 기능 사용)
class StoreSelectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigator로 전달된 User 객체를 가져옴
    final user = ModalRoute.of(context)?.settings.arguments as User?;

    // User가 null이거나 이메일이 유효하지 않으면 에러 화면을 표시
    if (user == null || user.email.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')), // 에러 페이지의 타이틀
        body: Center(child: Text('User data not found or invalid email.')), // 에러 메시지 표시
      );
    }

    // SignUpViewModel을 읽어서 상태 변경 기능을 가져옴
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    // 정상적인 User 데이터가 있을 때 화면을 구성
    return Scaffold(
      appBar: AppBar(
        title: Text('ご利用店舗選択'), // 'ご利用店舗選択' = 선택할 매장
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 여백
        child: Column(
          children: [
            // 검색 입력 필드
            TextField(
              decoration: InputDecoration(
                hintText: '検索', // '検索' = 검색
                prefixIcon: Icon(Icons.search), // 검색 아이콘
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 설정
                ),
              ),
            ),
            // 매장 목록을 표시하는 ListView
            Expanded(
              child: ListView(
                children: [
                  _buildStoreTile(context, signUpViewModel, 'm HOLD\'EM 目黒', user),
                  _buildStoreTile(context, signUpViewModel, '六本木BROADWAY', user),
                  _buildStoreTile(context, signUpViewModel, 'カジスタ東京', user),
                  _buildStoreTile(context, signUpViewModel, 'シブヤギルド', user),
                  _buildStoreTile(context, signUpViewModel, 'Extreme Bar BACK DOOR', user),
                  _buildStoreTile(context, signUpViewModel, 'JCS Hold’em', user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 매장 타일을 빌드하는 함수
  Widget _buildStoreTile(BuildContext context, SignUpViewModel signUpViewModel, String storeName, User user) {
    return ListTile(
      title: Text(storeName), // 매장 이름 표시
      onTap: () {
        // 사용자의 선택된 매장 정보를 업데이트
        signUpViewModel.updateUserStore(user, storeName);
        // 인증 화면으로 이동하면서 User 객체를 전달
        Navigator.pushNamed(context, '/email-auth', arguments: user);
      },
    );
  }
}