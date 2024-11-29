import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/photo_upload_state_model.dart'; // 수정된 PhotoUploadState를 import
import '../model/photo_upload_model.dart'; // 수정된 PhotoUpload 모델

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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (isLogo) {
        state = state.copyWith(storeLogo: pickedFile);
      } else {
        List<XFile?> updatedImages = List.from(state.storeImages);
        updatedImages[index] = pickedFile;
        state = state.copyWith(storeImages: updatedImages);
      }
    } else {
      print("이미지 선택이 취소되었습니다.");
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

  Future<void> submitDetails() async {
    final ownerEmail = state.ownerEmail;
    if (ownerEmail == null) {
      state = state.copyWith(uploadError: '오류가 발생했습니다. 다시 시도해주세요.');
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
          isLoading: false, uploadError: '업로드에 실패했습니다. 다시 시도해주세요.');
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
}

final photoUploadViewModelProvider =
    StateNotifierProvider<PhotoUploadViewModel, PhotoUploadState>(
  (ref) => PhotoUploadViewModel(),
);
