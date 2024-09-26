import 'dart:io'; // File 처리에 필요한 라이브러리
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod 상태 관리를 위한 라이브러리
import 'package:image_picker/image_picker.dart'; // 이미지 선택 기능을 위한 라이브러리
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage를 사용하여 이미지 업로드
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore를 사용하여 데이터를 저장
import '../model/photo_upload_model.dart'; // PhotoUpload 모델 가져오기

/// [PhotoUploadState]는 이미지 업로드 화면에서 사용되는 상태를 정의하는 클래스입니다.
/// - storeImages: 선택된 가게 이미지 리스트 (최대 3개)
/// - storeLogo: 선택된 로고 이미지
/// - message: 가게 설명 메시지
/// - isLoading: 업로드 중인지 여부
/// - uploadError: 업로드 실패 시 에러 메시지
class PhotoUploadState {
  final List<XFile?> storeImages; // 3개의 이미지 슬롯
  final XFile? storeLogo; // 로고 이미지
  final String message; // 가게 설명 메시지
  final bool isLoading; // 업로드 중인지 확인
  final String? uploadError; // 업로드 실패 시 에러 메시지

  PhotoUploadState({
    required this.storeImages,
    required this.storeLogo,
    required this.message,
    this.isLoading = false,
    this.uploadError,
  });

  /// 상태를 복사하여 새로운 상태를 반환하는 메서드
  PhotoUploadState copyWith({
    List<XFile?>? storeImages,
    XFile? storeLogo,
    String? message,
    bool? isLoading,
    String? uploadError,
  }) {
    return PhotoUploadState(
      storeImages: storeImages ?? this.storeImages,
      storeLogo: storeLogo ?? this.storeLogo,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      uploadError: uploadError,
    );
  }
}

/// [PhotoUploadViewModel]은 사진 업로드 화면에서 로직을 관리하는 ViewModel입니다.
class PhotoUploadViewModel extends StateNotifier<PhotoUploadState> {
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firebase Firestore 인스턴스
  final ImagePicker _picker = ImagePicker(); // 갤러리에서 이미지를 선택하기 위한 ImagePicker 인스턴스

  PhotoUploadViewModel()
      : super(
          PhotoUploadState(
            storeImages: List<XFile?>.filled(3, null), // 이미지 슬롯 3개를 null로 초기화
            storeLogo: null, // 로고 이미지도 null로 초기화
            message: '', // 설명 메시지는 빈 문자열로 초기화
          ),
        );

  /// 이미지를 선택하고 상태를 업데이트하는 메서드
  /// [index]: 이미지 슬롯의 인덱스 (0 ~ 2), [isLogo]: 로고를 선택하는지 여부
  Future<void> pickImage(int index, {bool isLogo = false}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택
    if (pickedFile != null) {
      if (isLogo) {
        // 로고 이미지가 선택된 경우
        state = state.copyWith(storeLogo: pickedFile); // 상태 업데이트
      } else {
        // 일반 가게 이미지가 선택된 경우
        List<XFile?> updatedImages = List.from(state.storeImages); // 기존 이미지를 복사
        updatedImages[index] = pickedFile; // 선택된 이미지로 업데이트
        state = state.copyWith(storeImages: updatedImages); // 상태 업데이트
      }
    } else {
      print("이미지 선택이 취소되었습니다."); // 사용자가 이미지를 선택하지 않은 경우
    }
  }

  /// Firebase Storage에 이미지를 업로드하고 URL을 반환하는 메서드
  /// [imageFile]: 업로드할 이미지 파일, [folderName]: 저장할 폴더 이름
  Future<String?> uploadImage(XFile? imageFile, String folderName) async {
    if (imageFile == null) return null; // 이미지가 선택되지 않은 경우 null 반환
    try {
      print('Uploading image: ${imageFile.path}'); // 업로드 진행 로그 출력
      String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // 파일 이름을 현재 시간으로 생성
      Reference storageRef = _storage.ref().child('$folderName/$fileName'); // Firebase Storage 경로 설정
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path)); // 파일을 업로드
      TaskSnapshot snapshot = await uploadTask; // 업로드가 완료될 때까지 대기
      String downloadUrl = await snapshot.ref.getDownloadURL(); // 다운로드 가능한 URL 가져오기
      print('Upload success: $downloadUrl'); // 업로드 성공 로그
      return downloadUrl; // 업로드 성공 시 URL 반환
    } catch (e) {
      print('Image upload failed: $e'); // 업로드 실패 로그
      return null; // 실패 시 null 반환
    }
  }

  /// Firebase Firestore에 데이터 저장 및 업로드된 이미지 URL을 처리하는 메서드
  /// [ownerEmail]: 현재 사용자의 이메일을 ownerId로 사용
  Future<void> submitDetails(String ownerEmail) async {
    state = state.copyWith(isLoading: true, uploadError: null); // 업로드 시작, 상태를 로딩으로 설정
    List<String?> imageUrls = []; // 업로드된 이미지 URL을 저장할 리스트

    // 각 이미지 업로드 및 URL 저장
    for (int i = 0; i < state.storeImages.length; i++) {
      if (state.storeImages[i] != null) {
        String? imageUrl = await uploadImage(state.storeImages[i], 'storeImages'); // 이미지 업로드
        if (imageUrl != null) {
          imageUrls.add(imageUrl); // 성공적으로 업로드된 경우 URL 추가
        }
      }
    }

    // 로고 이미지 업로드
    String? logoUrl = await uploadImage(state.storeLogo, 'storeLogo');

    // Firestore에 저장할 데이터를 PhotoUpload 모델을 사용하여 준비
    PhotoUpload photoUpload = PhotoUpload(
      pubId: '', // pubId는 Firestore에서 자동 생성
      ownerId: ownerEmail, // ownerEmail을 ownerId로 사용
      logoUrl: logoUrl, // 업로드된 로고 URL
      photoUrls: imageUrls, // 업로드된 이미지 URL 리스트
      message: state.message, // 사용자가 입력한 메시지
    );

    try {
      // Firestore에 데이터 저장 후, 자동 생성된 pubId를 가져옴
      DocumentReference docRef = await _firestore.collection('PubInfos').add(photoUpload.toMap());

      // 생성된 pubId를 Firestore에 업데이트
      await docRef.update({'pubId': docRef.id}); // 자동 생성된 pubId로 업데이트
      state = state.copyWith(isLoading: false); // 상태 업데이트, 로딩 종료
      print('Data saved with pubId: ${docRef.id}'); // 성공적으로 저장된 pubId 출력
    } catch (e) {
      print('Error occurred while saving to Firestore: $e'); // 저장 중 오류 발생 시 로그 출력
      state = state.copyWith(isLoading: false, uploadError: 'Upload failed. Please try again.'); // 오류 메시지 상태 업데이트
    }
  }

  /// 메시지 업데이트 메서드
  /// 사용자가 입력한 메시지를 상태에 반영
  void updateMessage(String message) {
    state = state.copyWith(message: message); // 메시지 상태 업데이트
    _validateForm(); // 폼 유효성 검사 호출
  }

  /// 폼 유효성 검사
  /// 최소한 1개의 이미지, 로고, 그리고 메시지가 입력되었는지 확인
  bool get isFormValid {
    bool hasAtLeastOneImage = state.storeImages.any((image) => image != null); // 1개 이상의 이미지가 있는지 확인
    return state.message.isNotEmpty && hasAtLeastOneImage && state.storeLogo != null; // 메시지, 이미지, 로고가 있는지 확인
  }

  /// 폼 유효성을 체크하여 버튼 활성화 여부 결정
  void _validateForm() {
    state = state.copyWith(isLoading: !isFormValid); // 폼이 유효하지 않으면 isLoading을 true로 설정하여 버튼 비활성화
  }
}

// PhotoUploadViewModel provider를 정의
final photoUploadViewModelProvider =
    StateNotifierProvider<PhotoUploadViewModel, PhotoUploadState>(
  (ref) => PhotoUploadViewModel(),
);
