// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_code_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QrCode _$QrCodeFromJson(Map<String, dynamic> json) {
  return _QrCode.fromJson(json);
}

/// @nodoc
mixin _$QrCode {
  String get token => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get expiryDate => throw _privateConstructorUsedError;
  bool get isUsed => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this QrCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QrCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QrCodeCopyWith<QrCode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrCodeCopyWith<$Res> {
  factory $QrCodeCopyWith(QrCode value, $Res Function(QrCode) then) =
      _$QrCodeCopyWithImpl<$Res, QrCode>;
  @useResult
  $Res call(
      {String token,
      String createdAt,
      String expiryDate,
      bool isUsed,
      String userId});
}

/// @nodoc
class _$QrCodeCopyWithImpl<$Res, $Val extends QrCode>
    implements $QrCodeCopyWith<$Res> {
  _$QrCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QrCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? createdAt = null,
    Object? expiryDate = null,
    Object? isUsed = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrCodeImplCopyWith<$Res> implements $QrCodeCopyWith<$Res> {
  factory _$$QrCodeImplCopyWith(
          _$QrCodeImpl value, $Res Function(_$QrCodeImpl) then) =
      __$$QrCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      String createdAt,
      String expiryDate,
      bool isUsed,
      String userId});
}

/// @nodoc
class __$$QrCodeImplCopyWithImpl<$Res>
    extends _$QrCodeCopyWithImpl<$Res, _$QrCodeImpl>
    implements _$$QrCodeImplCopyWith<$Res> {
  __$$QrCodeImplCopyWithImpl(
      _$QrCodeImpl _value, $Res Function(_$QrCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of QrCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? createdAt = null,
    Object? expiryDate = null,
    Object? isUsed = null,
    Object? userId = null,
  }) {
    return _then(_$QrCodeImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      isUsed: null == isUsed
          ? _value.isUsed
          : isUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QrCodeImpl implements _QrCode {
  const _$QrCodeImpl(
      {required this.token,
      required this.createdAt,
      required this.expiryDate,
      required this.isUsed,
      required this.userId});

  factory _$QrCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$QrCodeImplFromJson(json);

  @override
  final String token;
  @override
  final String createdAt;
  @override
  final String expiryDate;
  @override
  final bool isUsed;
  @override
  final String userId;

  @override
  String toString() {
    return 'QrCode(token: $token, createdAt: $createdAt, expiryDate: $expiryDate, isUsed: $isUsed, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrCodeImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, token, createdAt, expiryDate, isUsed, userId);

  /// Create a copy of QrCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QrCodeImplCopyWith<_$QrCodeImpl> get copyWith =>
      __$$QrCodeImplCopyWithImpl<_$QrCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QrCodeImplToJson(
      this,
    );
  }
}

abstract class _QrCode implements QrCode {
  const factory _QrCode(
      {required final String token,
      required final String createdAt,
      required final String expiryDate,
      required final bool isUsed,
      required final String userId}) = _$QrCodeImpl;

  factory _QrCode.fromJson(Map<String, dynamic> json) = _$QrCodeImpl.fromJson;

  @override
  String get token;
  @override
  String get createdAt;
  @override
  String get expiryDate;
  @override
  bool get isUsed;
  @override
  String get userId;

  /// Create a copy of QrCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QrCodeImplCopyWith<_$QrCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
