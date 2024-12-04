import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'photo_upload_state_model.freezed.dart';

@freezed
class PhotoUploadState with _$PhotoUploadState {
  const factory PhotoUploadState({
    required List<XFile?> storeImages,
    required XFile? storeLogo,
    required String message,
    @Default(false) bool isLoading,
    String? uploadError,
    String? ownerEmail,
  }) = _PhotoUploadState;
}
