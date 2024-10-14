import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_code_model.freezed.dart';
part 'qr_code_model.g.dart';

@freezed
class QrCode with _$QrCode {
  const factory QrCode({
    required String token,
    required String createdAt,
    required String expiryDate,
    required bool isUsed,
    required String userId,
  }) = _QrCode;

  factory QrCode.fromJson(Map<String, dynamic> json) => _$QrCodeFromJson(json);
}
