import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/photo_upload_view_model.dart';
import 'dart:io'; 
import '../../model/owner_model.dart';
import 'owner_email_auth_screen.dart'; // 이메일 인증 페이지로 이동

/// [PhotoUploadScreen]은 사용자가 이미지(가게 이미지 및 로고)를 업로드하고 메시지를 입력하는 화면입니다.
/// 업로드된 이미지는 Firebase Storage에 저장되고, Firestore에 저장됩니다.
class PhotoUploadScreen extends ConsumerWidget {
  final Owner owner; // Owner 객체를 전달받음

  PhotoUploadScreen({required this.owner}); // 생성자에서 owner를 전달받음

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoUploadViewModelProvider);
    final viewModel = ref.read(photoUploadViewModelProvider.notifier);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '店舗詳細情報',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildSectionTitle('店舗イメージ登録', screenWidth),
            _buildImageUploadRow(screenWidth, screenHeight, viewModel),
            SizedBox(height: screenHeight * 0.02),
            _buildSectionTitle('店舗ロゴ登録', screenWidth),
            _buildLogoUpload(screenWidth, screenHeight, viewModel),
            SizedBox(height: screenHeight * 0.02),
            _buildSectionTitle('店舗からのメッセージ', screenWidth),
            _buildMessageField(screenWidth, viewModel),
            SizedBox(height: screenHeight * 0.04),
            Center(
              child: ElevatedButton(
                onPressed: state.isLoading || !viewModel.isFormValid // 폼 유효성 검사
                    ? null // 유효하지 않으면 버튼 비활성화
                    : () async {
                        // XFile을 File로 변환
                        List<File?> convertedImages = state.storeImages
                            .map((xfile) =>
                                xfile != null ? File(xfile.path) : null)
                            .toList();
                        File? convertedLogo = state.storeLogo != null
                            ? File(state.storeLogo!.path)
                            : null;

                        // owner.email을 ownerId로 사용
                        await viewModel.submitDetails(owner.email);

                        // 데이터를 owner_email_auth.dart로 넘기기
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OwnerEmailAuthScreen(
                              owner: owner, // Owner 객체 전달
                              images: convertedImages, // 변환된 이미지 리스트 전달
                              logo: convertedLogo, // 변환된 로고 이미지 전달
                              message: state.message, // 메시지 전달
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.isFormValid
                      ? Color(0xFF1D2538)
                      : Colors.grey, // 폼이 유효할 때만 색상 활성화
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  '詳細情報登録',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.045,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildImageUploadRow(double screenWidth, double screenHeight, PhotoUploadViewModel viewModel) {
    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.16,
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final imageFile = viewModel.state.storeImages[index];  // 선택된 이미지를 가져옴

          return GestureDetector(
            onTap: () => viewModel.pickImage(index),
            child: Stack(
              children: [
                Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Center(
                    child: imageFile != null
                        ? Image.file(
                            File(imageFile.path),  // 선택한 이미지 파일을 표시
                            fit: BoxFit.cover,  // 이미지가 꽉 차도록 설정
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                          )
                        : index == 0 // 첫 번째 칸에만 카메라 아이콘 표시
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: screenWidth * 0.08, color: Colors.grey),
                                  Text("必須", style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035)),
                                ],
                              )
                            : null, // 나머지 칸에는 아무것도 표시하지 않음
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.005,
                  left: screenWidth * 0.01,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: screenHeight * 0.005),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLogoUpload(double screenWidth, double screenHeight, PhotoUploadViewModel viewModel) {
    final logoFile = viewModel.state.storeLogo; // 선택된 로고 이미지 파일

    return Center(
      child: GestureDetector(
        onTap: () async {
          await viewModel.pickImage(0, isLogo: true); // 사진 선택 기능 실행
        },
        child: Container(
          width: screenWidth * 0.5,
          height: screenWidth * 0.5,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[200], // 바깥쪽 밝은 회색 박스
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // 안쪽 흰색 상자
              borderRadius: BorderRadius.zero, // 정사각형이므로 모서리 둥글지 않음
            ),
            child: logoFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child: Image.file(
                      File(logoFile.path),  // 선택한 로고 이미지 파일 표시
                      fit: BoxFit.cover,
                      width: screenWidth * 0.5,
                      height: screenWidth * 0.5,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: screenWidth * 0.1, color: Colors.grey), // 카메라 아이콘
                        Text("必須", style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035)), // 필수 텍스트
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageField(double screenWidth, PhotoUploadViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border: Border.all(color: Colors.grey[300]!, width: screenWidth * 0.01),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
      child: TextField(
        onChanged: (value) {
          viewModel.updateMessage(value);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '店舗からのメッセージを入力してください',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.04),
        ),
        maxLines: 3,
      ),
    );
  }
}
