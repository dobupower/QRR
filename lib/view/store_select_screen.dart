import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 가져오기
import '../model/user_model.dart'; // User 모델 가져오기

class StoreSelectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 크기 정보 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
    final selectedStore = ref.watch(signUpViewModelProvider.select((state) => state.selectedStore)); // 선택한 매장 감시

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03), // 화면 상단 여백 추가

            // 'ご利用店舗選択' 텍스트를 Body에 넣음
            Text(
              'ご利用店舗選択', // 'ご利用店舗選択' = 선택할 매장
              style: TextStyle(
                fontSize: screenWidth * 0.07,
              ),
              textAlign: TextAlign.center, // 중앙 정렬
            ),

            SizedBox(height: screenHeight * 0.02), // 텍스트 아래 여백

            // 검색 입력 필드
            TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                hintText: '検索', // '検索' = 검색
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05), // 원형 모서리 설정
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 검색 필드 아래 빈 공간

            // 매장 목록을 표시하는 ListView
            Expanded(
              child: ListView(
                children: [
                  _buildStoreTile(context, signUpViewModel, 'm HOLD\'EM 目黒', user, screenWidth, selectedStore),
                  _buildStoreTile(context, signUpViewModel, '六本木BROADWAY', user, screenWidth, selectedStore),
                  _buildStoreTile(context, signUpViewModel, 'カジスタ東京', user, screenWidth, selectedStore),
                  _buildStoreTile(context, signUpViewModel, 'シブヤギルド', user, screenWidth, selectedStore),
                  _buildStoreTile(context, signUpViewModel, 'Extreme Bar BACK DOOR', user, screenWidth, selectedStore),
                  _buildStoreTile(context, signUpViewModel, 'JCS Hold’em', user, screenWidth, selectedStore),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 매장 타일을 빌드하는 함수
  Widget _buildStoreTile(BuildContext context, SignUpViewModel signUpViewModel, String storeName, User user, double screenWidth, String? selectedStore) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: screenWidth * 0.02), // 패딩 조정
      title: Text(
        storeName, 
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          color: Colors.black,
        ),
      ),
      onTap: () {
        // 선택한 매장 정보를 업데이트하고 UI를 즉시 반영
        signUpViewModel.updateSelectedStore(storeName);

        // 매장 선택 후 즉시 다음 화면으로 이동
        Navigator.pushNamed(context, '/email-auth', arguments: user);
      },
    );
  }
}
