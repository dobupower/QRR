import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_points_state_model.freezed.dart';

@freezed
class UserPointsState with _$UserPointsState {
  const factory UserPointsState({
    required int points,
    required String uid,
  }) = _UserPointsState;
}
