import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/photo_upload_view_model.dart';
import '../../viewModel/owner_sign_up_view_model.dart'; // ownerEmail을 가져오기 위해 import
import 'dart:io';
import 'owner_email_auth_screen.dart'; // 이메일 인증 페이지로 이동
import '../../model/photo_upload_state_model.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  @override
  void initState() {
    super.initState();
    // 빌드가 완료된 후에 상태 변경을 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signUpState = ref.read(ownerSignUpViewModelProvider);
      final viewModel = ref.read(photoUploadViewModelProvider.notifier);

      final ownerEmail = signUpState.owner?.email;

      if (ownerEmail != null && ref.read(photoUploadViewModelProvider).ownerEmail == null) {
        viewModel.setOwnerEmail(ownerEmail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoUploadViewModelProvider);
    final viewModel = ref.read(photoUploadViewModelProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
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
              _buildImageUploadRow(screenWidth, screenHeight, viewModel, state),
              SizedBox(height: screenHeight * 0.02),
              _buildSectionTitle('店舗ロゴ登録', screenWidth),
              _buildLogoUpload(screenWidth, screenHeight, viewModel, state),
              SizedBox(height: screenHeight * 0.02),
              _buildSectionTitle('店舗からのメッセージ', screenWidth),
              _buildMessageField(screenWidth, viewModel),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton(
                  onPressed: state.isLoading || !viewModel.isFormValid
                      ? null
                      : () async {
                          await viewModel.submitDetails();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OwnerEmailAuthScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: viewModel.isFormValid
                        ? Color(0xFF1D2538)
                        : Colors.grey,
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

  Widget _buildImageUploadRow(double screenWidth, double screenHeight,
      PhotoUploadViewModel viewModel, PhotoUploadState state) {
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
          final imageFile = state.storeImages[index];

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
                            File(imageFile.path),
                            fit: BoxFit.cover,
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                          )
                        : index == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: screenWidth * 0.08,
                                      color: Colors.grey),
                                  Text("必須",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: screenWidth * 0.035)),
                                ],
                              )
                            : null,
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.005,
                  left: screenWidth * 0.01,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.015,
                        vertical: screenHeight * 0.005),
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

  Widget _buildLogoUpload(double screenWidth, double screenHeight,
      PhotoUploadViewModel viewModel, PhotoUploadState state) {
    final logoFile = state.storeLogo;

    return Center(
      child: GestureDetector(
        onTap: () async {
          await viewModel.pickImage(0, isLogo: true);
        },
        child: Container(
          width: screenWidth * 0.5,
          height: screenWidth * 0.5,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
            ),
            child: logoFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child: Image.file(
                      File(logoFile.path),
                      fit: BoxFit.cover,
                      width: screenWidth * 0.5,
                      height: screenWidth * 0.5,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            size: screenWidth * 0.1, color: Colors.grey),
                        Text("必須",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.035)),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageField(
      double screenWidth, PhotoUploadViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        border:
            Border.all(color: Colors.grey[300]!, width: screenWidth * 0.01),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
      child: TextField(
        onChanged: (value) {
          viewModel.updateMessage(value);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '店舗からのメッセージを入力してください',
          hintStyle:
              TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.04),
        ),
        maxLines: 3,
      ),
    );
  }
}
