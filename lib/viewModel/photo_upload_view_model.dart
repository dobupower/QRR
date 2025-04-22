import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/photo_upload_state_model.dart'; // 수정된 PhotoUploadState를 import
import '../model/photo_upload_model.dart'; // 수정된 PhotoUpload 모델
import '../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoUploadViewModel extends StateNotifier<PhotoUploadState> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  PhotoUploadViewModel()
      : super(
          PhotoUploadState(
            storeImages: List<XFile?>.filled(3, null),
            storeLogo: null,
            message: '',
          ),
        );

  void setOwnerEmail(String email) {
    state = state.copyWith(ownerEmail: email);
  }

  Future<void> pickImage(int index, {bool isLogo = false}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return;

    // 1) XFile → File
    final original = File(picked.path);

    // 2) 압축
    final compressed = await compressImage(original);

    // 3) 다시 XFile 형태로
    final xFileCompressed = XFile(compressed.path);

    if (isLogo) {
      state = state.copyWith(storeLogo: xFileCompressed);
    } else {
      final imgs = [...state.storeImages];
      imgs[index] = xFileCompressed;
      state = state.copyWith(storeImages: imgs);
    }
  }

  Future<String?> uploadImage(XFile? imageFile, String folderName) async {
    if (imageFile == null) return null;
    try {
      print('Uploading image: ${imageFile.path}');
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('$folderName/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Upload success: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<File> compressImage(File file) async {
    // 임시 파일 경로
    final tmpDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tmpDir.path,
      '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}',
    );

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,         // 0~100
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );

    return File(targetPath).writeAsBytes(compressedBytes!);
  }

  Future<void> submitDetails(BuildContext context) async {
    final ownerEmail = state.ownerEmail;
    if (ownerEmail == null) {
      state = state.copyWith(uploadError: AppLocalizations.of(context)?.photoUploadViewModelSubmitError ?? '');
      return;
    }

    state = state.copyWith(isLoading: true, uploadError: null);
    List<String?> imageUrls = [];

    // 각 이미지 업로드 및 URL 저장
    for (int i = 0; i < state.storeImages.length; i++) {
      if (state.storeImages[i] != null) {
        String? imageUrl =
            await uploadImage(state.storeImages[i], 'storeImages');
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          imageUrls.add(null); // 업로드 실패 시 null 추가
        }
      } else {
        imageUrls.add(null); // 이미지가 없을 경우 null 추가
      }
    }

    // 로고 이미지 업로드
    String? logoUrl = await uploadImage(state.storeLogo, 'storeLogo');

    // Firestore에 저장할 데이터를 준비
    PhotoUpload photoUpload = PhotoUpload(
      ownerId: ownerEmail,
      logoUrl: logoUrl,
      photoUrls: imageUrls,
      message: state.message,
    );

    try {
      DocumentReference docRef =
          await _firestore.collection('PubInfos').add(photoUpload.toJson());

      await docRef.update({'pubId': docRef.id});
      state = state.copyWith(isLoading: false);
      print('Data saved with pubId: ${docRef.id}');
    } catch (e) {
      print('Error occurred while saving to Firestore: $e');
      state = state.copyWith(
          isLoading: false, uploadError: AppLocalizations.of(context)?.photoUploadViewModelUploadError ?? '');
    }
  }

  void updateMessage(String message) {
    state = state.copyWith(message: message);
  }

  bool get isFormValid {
    bool hasAtLeastOneImage =
        state.storeImages.any((image) => image != null);
    return state.message.isNotEmpty &&
        hasAtLeastOneImage &&
        state.storeLogo != null;
  }
  
  Future<void> _deleteExistingImages(String ownerEmail) async {
    try {
      // Firestore에서 해당 가게의 기존 데이터 가져오기
      QuerySnapshot querySnapshot = await _firestore
          .collection('PubInfos')
          .where('ownerId', isEqualTo: ownerEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('해당 ownerEmail로 가게를 찾을 수 없습니다.');
        return;
      }

      var docSnapshot = querySnapshot.docs.first; // 첫 번째 문서 선택
      var data = docSnapshot.data() as Map<String, dynamic>;

      // 기존 로고 이미지 삭제
      String? existingLogoUrl = data['logoUrl'];
      if (existingLogoUrl != null) {
        Reference logoRef = _storage.refFromURL(existingLogoUrl);
        await logoRef.delete();
        print('기존 로고 이미지를 삭제했습니다.');
      }

      // 기존 가게 이미지들 삭제
      List<dynamic> existingPhotoUrls = data['photoUrls'] ?? [];
      for (var photoUrl in existingPhotoUrls) {
        if (photoUrl != null) {
          Reference photoRef = _storage.refFromURL(photoUrl);
          await photoRef.delete();
          print('기존 가게 이미지를 삭제했습니다.');
        }
      }
    } catch (e) {
      print('기존 이미지를 삭제하는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> updateStorePhotos(BuildContext context) async {
    final ownerEmail = await PreferencesManager.instance.getEmail();
    if (ownerEmail == null) {
      state = state.copyWith(uploadError: AppLocalizations.of(context)?.photoUploadViewModelSubmitError ?? '',);
      return;
    }

    state = state.copyWith(isLoading: true, uploadError: null);
    List<String?> imageUrls = [];

    // 1. 기존 이미지 삭제
    await _deleteExistingImages(ownerEmail);

    // 2. 새로운 이미지 업로드 및 URL 수집
    for (int i = 0; i < state.storeImages.length; i++) {
      if (state.storeImages[i] != null) {
        String? imageUrl =
            await uploadImage(state.storeImages[i], 'storeImages');
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          imageUrls.add(null); // 업로드 실패
        }
      } else {
        imageUrls.add(null); // 업로드할 이미지 없음
      }
    }

    // 3. 로고 이미지가 있을 경우 업로드
    String? logoUrl = await uploadImage(state.storeLogo, 'storeLogo');

    // 4. Firestore 업데이트를 위한 데이터 준비
    PhotoUpload photoUpload = PhotoUpload(
      ownerId: ownerEmail,
      logoUrl: logoUrl,
      photoUrls: imageUrls,
      message: state.message,
    );

    try {
      // 5. Firestore 문서 업데이트
      QuerySnapshot querySnapshot = await _firestore
          .collection('PubInfos')
          .where('ownerId', isEqualTo: ownerEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        state = state.copyWith(
            isLoading: false, uploadError: AppLocalizations.of(context)?.photoUploadViewModelStoreNotFound ?? '');
        return;
      }

      var docSnapshot = querySnapshot.docs.first; // 첫 번째 문서 선택
      DocumentReference docRef = docSnapshot.reference;

      // Firestore에서 해당 문서 업데이트
      await docRef.update(photoUpload.toJson());

      state = state.copyWith(isLoading: false);
      print('가게 사진이 성공적으로 업데이트되었습니다.');
    } catch (e) {
      print('가게 사진 업데이트 중 오류 발생: $e');
      state = state.copyWith(
          isLoading: false, uploadError: AppLocalizations.of(context)?.photoUploadViewModelUploadError ?? '');
    }
  }
}

final photoUploadViewModelProvider =
    StateNotifierProvider<PhotoUploadViewModel, PhotoUploadState>(
  (ref) => PhotoUploadViewModel(),
);
