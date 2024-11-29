// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhotoUpload _$PhotoUploadFromJson(Map<String, dynamic> json) {
  return _PhotoUpload.fromJson(json);
}

/// @nodoc
mixin _$PhotoUpload {
  String get pubId => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  List<String?> get photoUrls => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this PhotoUpload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoUploadCopyWith<PhotoUpload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoUploadCopyWith<$Res> {
  factory $PhotoUploadCopyWith(
          PhotoUpload value, $Res Function(PhotoUpload) then) =
      _$PhotoUploadCopyWithImpl<$Res, PhotoUpload>;
  @useResult
  $Res call(
      {String pubId,
      String ownerId,
      String? logoUrl,
      List<String?> photoUrls,
      String message});
}

/// @nodoc
class _$PhotoUploadCopyWithImpl<$Res, $Val extends PhotoUpload>
    implements $PhotoUploadCopyWith<$Res> {
  _$PhotoUploadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pubId = null,
    Object? ownerId = null,
    Object? logoUrl = freezed,
    Object? photoUrls = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      pubId: null == pubId
          ? _value.pubId
          : pubId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: null == photoUrls
          ? _value.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoUploadImplCopyWith<$Res>
    implements $PhotoUploadCopyWith<$Res> {
  factory _$$PhotoUploadImplCopyWith(
          _$PhotoUploadImpl value, $Res Function(_$PhotoUploadImpl) then) =
      __$$PhotoUploadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pubId,
      String ownerId,
      String? logoUrl,
      List<String?> photoUrls,
      String message});
}

/// @nodoc
class __$$PhotoUploadImplCopyWithImpl<$Res>
    extends _$PhotoUploadCopyWithImpl<$Res, _$PhotoUploadImpl>
    implements _$$PhotoUploadImplCopyWith<$Res> {
  __$$PhotoUploadImplCopyWithImpl(
      _$PhotoUploadImpl _value, $Res Function(_$PhotoUploadImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhotoUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pubId = null,
    Object? ownerId = null,
    Object? logoUrl = freezed,
    Object? photoUrls = null,
    Object? message = null,
  }) {
    return _then(_$PhotoUploadImpl(
      pubId: null == pubId
          ? _value.pubId
          : pubId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: null == photoUrls
          ? _value._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoUploadImpl implements _PhotoUpload {
  const _$PhotoUploadImpl(
      {this.pubId = '',
      required this.ownerId,
      this.logoUrl,
      required final List<String?> photoUrls,
      required this.message})
      : _photoUrls = photoUrls;

  factory _$PhotoUploadImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoUploadImplFromJson(json);

  @override
  @JsonKey()
  final String pubId;
  @override
  final String ownerId;
  @override
  final String? logoUrl;
  final List<String?> _photoUrls;
  @override
  List<String?> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  final String message;

  @override
  String toString() {
    return 'PhotoUpload(pubId: $pubId, ownerId: $ownerId, logoUrl: $logoUrl, photoUrls: $photoUrls, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoUploadImpl &&
            (identical(other.pubId, pubId) || other.pubId == pubId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pubId, ownerId, logoUrl,
      const DeepCollectionEquality().hash(_photoUrls), message);

  /// Create a copy of PhotoUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoUploadImplCopyWith<_$PhotoUploadImpl> get copyWith =>
      __$$PhotoUploadImplCopyWithImpl<_$PhotoUploadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoUploadImplToJson(
      this,
    );
  }
}

abstract class _PhotoUpload implements PhotoUpload {
  const factory _PhotoUpload(
      {final String pubId,
      required final String ownerId,
      final String? logoUrl,
      required final List<String?> photoUrls,
      required final String message}) = _$PhotoUploadImpl;

  factory _PhotoUpload.fromJson(Map<String, dynamic> json) =
      _$PhotoUploadImpl.fromJson;

  @override
  String get pubId;
  @override
  String get ownerId;
  @override
  String? get logoUrl;
  @override
  List<String?> get photoUrls;
  @override
  String get message;

  /// Create a copy of PhotoUpload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoUploadImplCopyWith<_$PhotoUploadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
