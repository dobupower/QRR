import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/user_update_pubid_view_model.dart';
import '../../../viewModel/user_account_view_model.dart';

class UpdatePubIdScreen extends ConsumerStatefulWidget {
  @override
  _UpdatePubIdScreenState createState() => _UpdatePubIdScreenState();
}

class _UpdatePubIdScreenState extends ConsumerState<UpdatePubIdScreen> {
  @override
  void initState() {
    super.initState();
    // Firestore에서 데이터를 가져옵니다.
    ref.read(updatePubIdViewModelProvider.notifier).fetchStoresFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(updatePubIdViewModelProvider.notifier);
    final filteredStoreNames = ref.watch(updatePubIdViewModelProvider.select((state) => state.filteredStores));
    final selectedStoreName = ref.watch(updatePubIdViewModelProvider.select((state) => state.selectedStore));

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
        title: SizedBox.shrink(),  // AppBar에서 title 제거
        backgroundColor: Colors.transparent,  // 배경을 투명으로 설정
        elevation: 0,  // 그림자 제거
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02), // padding을 화면 너비의 2%로 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 'ご利用店舗選択' 텍스트를 상단에 배치
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01), // 화면 높이의 1%로 상단 여백
              child: Text(
                'ご利用店舗選択', // AppBar에서 옮겨온 텍스트
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.07, // 텍스트 크기 화면 너비의 7%
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 추가적인 여백

            TextField(
              onChanged: (query) {
                final trimmedQuery = query.trim();
                print('입력된 검색어: $trimmedQuery');
                viewModel.filterStores(trimmedQuery);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                hintText: '検索',
                hintStyle: TextStyle(fontSize: screenWidth * 0.04), // 상대 크기 설정
                prefixIcon: Icon(Icons.search, size: screenWidth * 0.05, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: screenWidth * 0.002),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.002),
            // 필터링된 매장 리스트
            Expanded(
              child: filteredStoreNames.isEmpty
                  ? Center(
                      child: Text(
                        '検索結果がありません。',
                        style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredStoreNames.length,
                      itemBuilder: (context, index) {
                        final storeName = filteredStoreNames[index];
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 왼쪽/오른쪽 패딩 추가
                              child: _buildStoreTile(
                                context,
                                viewModel,
                                storeName,
                                screenWidth,
                                screenHeight,
                                selectedStoreName,
                              ),
                            ),
                            Divider(
                              color: Colors.grey[300],
                              thickness: screenHeight * 0.001, // 상대 크기 설정
                              height: screenHeight * 0.005, // 항목과 간격을 좁히기 위해 줄임
                              indent: screenWidth * 0.04, // 왼쪽 padding과 맞추기
                              endIndent: screenWidth * 0.04, // 오른쪽 padding과 맞추기
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 매장 타일 위젯
  Widget _buildStoreTile(
    BuildContext context,
    UpdatePubIdViewModel viewModel,
    String storeName,
    double screenWidth,
    double screenHeight,
    String? selectedStoreName,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.007),
      title: Text(
        storeName,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          color: storeName == selectedStoreName ? Colors.blue : Colors.black,
          fontWeight: storeName == selectedStoreName ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () async {
        final isSuccess = await viewModel.updateSelectedStoreAndPubId(storeName);
        if (isSuccess) {
          ref.read(userAccountProvider.notifier).updatePubId(storeName);
          Navigator.pop(context); // 성공 시 이전 화면으로 이동
        } else {
          _showSnackBar(context, '更新に失敗しました。'); // 실패 시 에러 메시지 표시
        }
      },
    );
  }

  // 스낵바 표시
  void _showSnackBar(BuildContext context, String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: screenWidth * 0.04), // 상대 크기 설정
        ),
      ),
    );
  }
}
