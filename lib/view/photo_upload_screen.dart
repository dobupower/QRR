import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage 사용
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용

/// [PhotoUploadScreen]은 사용자가 이미지(가게 이미지 및 로고)를 업로드하고 메시지를 입력하는 화면입니다.
/// 업로드된 이미지는 Firebase Storage에 저장되고, Firestore에 저장됩니다.
class PhotoUploadScreen extends StatefulWidget {
  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  // 3개의 이미지 슬롯을 미리 생성 (가게 이미지를 3개까지 업로드 가능)
  List<XFile?> storeImages = List<XFile?>.filled(3, null); 
  XFile? storeLogo; // 업로드될 가게 로고 이미지
  final messageController = TextEditingController(); // 메시지 입력 필드의 컨트롤러

  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker 인스턴스

  // Firebase Storage 및 Firestore 인스턴스 초기화
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 갤러리에서 이미지를 선택하는 함수입니다.
  /// 선택된 이미지는 index에 따라 각각의 슬롯(가게 이미지 또는 로고)에 저장됩니다.
  Future<void> _pickImage(int index, {bool isLogo = false}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isLogo) {
        storeLogo = pickedFile; // 로고 이미지일 경우 storeLogo에 저장
      } else {
        storeImages[index] = pickedFile; // 가게 이미지일 경우 해당 슬롯에 저장
      }
    });
  }

  /// Firebase Storage에 이미지를 업로드하고 업로드된 이미지의 URL을 반환하는 함수입니다.
  /// 이미지가 없을 경우 null을 반환합니다.
  Future<String?> _uploadImage(XFile? imageFile, String folderName) async {
    if (imageFile == null) return null; // 이미지가 없을 경우
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // 파일 이름을 현재 시간으로 생성
      Reference storageRef = _storage.ref().child('$folderName/$fileName'); // Firebase Storage 경로 설정
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path)); // 이미지 업로드
      TaskSnapshot snapshot = await uploadTask; 
      return await snapshot.ref.getDownloadURL(); // 업로드된 파일의 URL 반환
    } catch (e) {
      print('Image upload failed: $e'); // 오류 발생 시
      return null;
    }
  }

  /// 업로드된 이미지들과 메시지를 Firestore에 저장하는 함수입니다.
  /// Firestore에 가게 이미지들, 로고, 메시지를 함께 저장합니다.
  Future<void> _submitDetails() async {
    List<String?> imageUrls = [];

    // 3개의 가게 이미지 각각을 업로드하고 URL을 저장
    for (int i = 0; i < storeImages.length; i++) {
      String? imageUrl = await _uploadImage(storeImages[i], 'storeImages');
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }

    // 가게 로고 업로드 후 URL 저장
    String? logoUrl = await _uploadImage(storeLogo, 'storeLogo');

    // Firestore에 데이터를 저장
    await _firestore.collection('stores').add({
      'images': imageUrls,
      'logo': logoUrl,
      'message': messageController.text,
    });

    // 업로드 완료 메시지 출력
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('업로드 완료')));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // 화면 높이
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey), // 뒤로가기 버튼
          onPressed: () => Navigator.pop(context), // 뒤로가기 기능
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // 스크롤 가능하도록 설정
        padding: EdgeInsets.all(screenWidth * 0.04), // 화면 양 옆 패딩 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
          children: [
            Center(
              child: Text(
                '店舗詳細情報', // 제목 텍스트
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // 제목 크기 설정
                  fontWeight: FontWeight.bold, // 굵게 설정
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 간격 설정
            _buildSectionTitle('店舗イメージ登録', screenWidth), // 가게 이미지 섹션 제목
            _buildImageUploadRow(screenWidth, screenHeight),  // 가게 이미지 업로드 UI
            SizedBox(height: screenHeight * 0.02), // 간격 설정
            _buildSectionTitle('店舗ロゴ登録', screenWidth), // 로고 섹션 제목
            _buildLogoUpload(screenWidth, screenHeight),  // 로고 업로드 UI
            SizedBox(height: screenHeight * 0.02), // 간격 설정
            _buildSectionTitle('店舗からのメッセージ', screenWidth), // 메시지 입력 섹션 제목
            _buildMessageField(screenWidth),  // 메시지 입력 필드 UI
            SizedBox(height: screenHeight * 0.04), // 간격 설정
            Center(
              child: ElevatedButton(
                onPressed: _submitDetails, // 버튼 클릭 시 Firestore에 업로드
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D2538), // 버튼 배경색 설정
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3, // 버튼 가로 패딩
                    vertical: screenHeight * 0.015, // 버튼 세로 패딩
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // 버튼 모서리 둥글게
                  ),
                ),
                child: Text(
                  '詳細情報登録', // 버튼 텍스트
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // 텍스트 크기 설정
                    color: Colors.white, // 텍스트 색상 설정
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 제목을 표시하는 위젯입니다.
  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.045, // 섹션 제목 크기
        fontWeight: FontWeight.bold, // 섹션 제목 굵게
      ),
    );
  }

  /// 가게 이미지 업로드 UI를 구성하는 함수입니다.
  Widget _buildImageUploadRow(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9, // 화면 너비의 90% 설정
      height: screenHeight * 0.16, // 화면 높이의 16% 설정
      padding: EdgeInsets.all(screenWidth * 0.02), // 안쪽 패딩 설정
      decoration: BoxDecoration(
        color: Colors.grey[200], // 밝은 회색 배경
        borderRadius: BorderRadius.circular(screenWidth * 0.02), // 둥근 모서리
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 요소들 간격 고르게
        children: List.generate(3, (index) {
          return GestureDetector(
            onTap: () => _pickImage(index), // 이미지 선택 기능
            child: Stack(
              children: [
                Container(
                  width: screenWidth * 0.25, // 이미지 박스 너비
                  height: screenWidth * 0.25, // 이미지 박스 높이 (정사각형)
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 박스
                    borderRadius: BorderRadius.zero, // 모서리 둥글지 않음
                    border: Border.all(color: Colors.transparent), // 테두리 제거
                  ),
                  // 첫 번째 이미지 칸에는 카메라 아이콘 추가
                  child: index == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: screenWidth * 0.08, color: Colors.grey),
                            Text("必須", style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.035)),
                          ],
                        )
                      : null,
                ),
                // 각 이미지 칸에 번호 추가
                Positioned(
                  top: screenHeight * 0.005,
                  left: screenWidth * 0.01,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: screenHeight * 0.005),
                    decoration: BoxDecoration(
                      color: Colors.grey[600], // 진한 회색 배경
                      borderRadius: BorderRadius.circular(screenWidth * 0.01), // 둥근 모서리
                    ),
                    child: Text(
                      '${index + 1}', // 번호 표시
                      style: TextStyle(
                        color: Colors.white, // 흰색 텍스트
                        fontSize: screenWidth * 0.03, // 텍스트 크기
                        fontWeight: FontWeight.bold, // 굵게
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

  /// 가게 로고 업로드 UI를 구성하는 함수입니다.
  Widget _buildLogoUpload(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        width: screenWidth * 0.5, // 화면 너비의 50%
        height: screenWidth * 0.5, // 정사각형 크기
        padding: EdgeInsets.all(screenWidth * 0.04), // 패딩 설정
        decoration: BoxDecoration(
          color: Colors.grey[200], // 밝은 회색 배경
          borderRadius: BorderRadius.circular(screenWidth * 0.02), // 둥근 모서리
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 흰색 박스
            borderRadius: BorderRadius.zero, // 모서리 둥글지 않음
          ),
          child: GestureDetector(
            onTap: () => _pickImage(0, isLogo: true), // 로고 선택 기능
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
    );
  }

  /// 가게 메시지를 입력하는 텍스트 필드 UI를 구성하는 함수입니다.
  Widget _buildMessageField(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.025),  // 모서리 둥글게 설정
        border: Border.all(color: Colors.grey[300]!, width: screenWidth * 0.01),  // 테두리 설정
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),  // 안쪽 패딩
      child: TextField(
        controller: messageController, // 메시지 입력 컨트롤러
        decoration: InputDecoration(
          border: InputBorder.none,  // 테두리 제거
          hintText: '店舗からのメッセージを入力してください', // 힌트 텍스트
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.04),  // 힌트 텍스트 스타일
        ),
        maxLines: 3,  // 여러 줄 입력 가능
      ),
    );
  }
}
