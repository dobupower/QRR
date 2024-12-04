import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_model.freezed.dart';
part 'owner_model.g.dart';

@freezed
class Owner with _$Owner {
  const factory Owner({
    required String uid,             // 고유 ID
    required String storeName,       // 점포명
    required String email,           // 이메일 주소
    required String zipCode,         // 우편번호
    required String prefecture,      // 도도부현
    required String city,            // 시/구/읍/면/동
    required String address,         // 상세 주소
    String? building,                // 건물명 (선택사항)
    @Default('email') String authType, // 인증 유형
    @Default('owner') String type,     // 사용자 유형
    @Default(100000) int pointLimit,   // 포인트 제한
  }) = _Owner;

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);
}
