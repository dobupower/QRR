import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_upload_model.freezed.dart';
part 'photo_upload_model.g.dart';

@freezed
class PhotoUpload with _$PhotoUpload {
  const factory PhotoUpload({
    @Default('') String pubId,
    required String ownerId,
    String? logoUrl,
    required List<String?> photoUrls,
    required String message,
  }) = _PhotoUpload;

  /// Firestore에서 데이터를 가져올 때 사용할 팩토리 생성자
  factory PhotoUpload.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadFromJson(json);
}
