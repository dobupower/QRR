// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_points_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserPointsState {
  int get points => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;

  /// Create a copy of UserPointsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPointsStateCopyWith<UserPointsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPointsStateCopyWith<$Res> {
  factory $UserPointsStateCopyWith(
          UserPointsState value, $Res Function(UserPointsState) then) =
      _$UserPointsStateCopyWithImpl<$Res, UserPointsState>;
  @useResult
  $Res call({int points, String uid});
}

/// @nodoc
class _$UserPointsStateCopyWithImpl<$Res, $Val extends UserPointsState>
    implements $UserPointsStateCopyWith<$Res> {
  _$UserPointsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPointsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? uid = null,
  }) {
    return _then(_value.copyWith(
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPointsStateImplCopyWith<$Res>
    implements $UserPointsStateCopyWith<$Res> {
  factory _$$UserPointsStateImplCopyWith(_$UserPointsStateImpl value,
          $Res Function(_$UserPointsStateImpl) then) =
      __$$UserPointsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int points, String uid});
}

/// @nodoc
class __$$UserPointsStateImplCopyWithImpl<$Res>
    extends _$UserPointsStateCopyWithImpl<$Res, _$UserPointsStateImpl>
    implements _$$UserPointsStateImplCopyWith<$Res> {
  __$$UserPointsStateImplCopyWithImpl(
      _$UserPointsStateImpl _value, $Res Function(_$UserPointsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPointsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? uid = null,
  }) {
    return _then(_$UserPointsStateImpl(
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserPointsStateImpl implements _UserPointsState {
  const _$UserPointsStateImpl({required this.points, required this.uid});

  @override
  final int points;
  @override
  final String uid;

  @override
  String toString() {
    return 'UserPointsState(points: $points, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPointsStateImpl &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, points, uid);

  /// Create a copy of UserPointsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPointsStateImplCopyWith<_$UserPointsStateImpl> get copyWith =>
      __$$UserPointsStateImplCopyWithImpl<_$UserPointsStateImpl>(
          this, _$identity);
}

abstract class _UserPointsState implements UserPointsState {
  const factory _UserPointsState(
      {required final int points,
      required final String uid}) = _$UserPointsStateImpl;

  @override
  int get points;
  @override
  String get uid;

  /// Create a copy of UserPointsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPointsStateImplCopyWith<_$UserPointsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
