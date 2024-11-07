import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String name,
    required String email,
    required int points,
    required String authType,
    String? pubId,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
extension UserExtensions on User {
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'points': points,
      'authType': authType,
      'pubId': pubId,
    };
  }
}