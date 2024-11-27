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
        title: Text(
          'ご利用店舗選択',
          style: TextStyle(fontSize: screenWidth * 0.045), // 상대 크기 설정
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02), // 상대 크기 설정
            // 검색 필드
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
            SizedBox(height: screenHeight * 0.02),
            // 필터링된 매장 리스트
            Expanded(
              child: filteredStoreNames.isEmpty
                  ? Center(
                      child: Text(
                        '検索結果がありません。',
                        style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredStoreNames.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey[300],
                        thickness: screenHeight * 0.001, // 상대 크기 설정
                        height: screenHeight * 0.01, // 상대 크기 설정
                      ),
                      itemBuilder: (context, index) {
                        final storeName = filteredStoreNames[index];
                        return _buildStoreTile(
                          context,
                          viewModel,
                          storeName,
                          screenWidth,
                          screenHeight,
                          selectedStoreName,
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
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
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
        ),
        Divider(
          color: Colors.grey[300],
          thickness: screenHeight * 0.001, // 상대 크기 설정
          height: screenHeight * 0.01, // 상대 크기 설정
        ),
      ],
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
