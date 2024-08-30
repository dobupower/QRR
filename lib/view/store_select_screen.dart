import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/sign_up_view_model.dart';
import '../model/user_model.dart';

class StoreSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달된 User 객체를 가져옵니다.
    final User? user = ModalRoute.of(context)?.settings.arguments as User?;

    // User 객체가 없거나 이메일이 비어 있는 경우 오류 화면을 표시합니다.
    if (user == null || user.email.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('User data not found or invalid email.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ご利用店舗選択'), // 앱 바의 제목을 'ご利用店舗選択'으로 설정합니다.
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼을 누르면 이전 화면으로 이동합니다.
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '検索', // 검색 필드의 힌트 텍스트를 '検索'으로 설정합니다.
                prefixIcon: Icon(Icons.search), // 검색 아이콘을 입력 필드의 앞에 배치합니다.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // 입력 필드의 테두리를 둥글게 설정합니다.
                ),
              ),
            ),
            Expanded(
              // 매장 목록을 표시하는 ListView를 포함한 Expanded 위젯입니다.
              child: ListView(
                children: [
                  // 매장 타일을 생성하는 메서드를 호출하여 각 매장을 ListTile로 표시합니다.
                  _buildStoreTile(context, 'm HOLD\'EM 目黒', user),
                  _buildStoreTile(context, '六本木BROADWAY', user),
                  _buildStoreTile(context, 'カジスタ東京', user),
                  _buildStoreTile(context, 'シブヤギルド', user),
                  _buildStoreTile(context, 'Extreme Bar BACK DOOR', user),
                  _buildStoreTile(context, 'JCS Hold’em', user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 매장 타일을 생성하는 메서드입니다.
  Widget _buildStoreTile(BuildContext context, String storeName, User user) {
    return ListTile(
      title: Text(storeName), // 매장 이름을 표시합니다.
      onTap: () {
        // 사용자가 매장을 선택하면 SignUpViewModel을 사용하여 사용자의 매장 정보를 업데이트합니다.
        Provider.of<SignUpViewModel>(context, listen: false).updateUserStore(user, storeName);

        // 이메일 인증 화면으로 이동하면서 사용자의 정보를 전달합니다.
        Navigator.pushNamed(
          context,
          '/email-auth',
          arguments: user,
        );
      },
    );
  }
}
