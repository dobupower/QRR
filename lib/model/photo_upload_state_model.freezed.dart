// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PhotoUploadState {
  List<XFile?> get storeImages => throw _privateConstructorUsedError;
  XFile? get storeLogo => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get uploadError => throw _privateConstructorUsedError;
  String? get ownerEmail => throw _privateConstructorUsedError;

  /// Create a copy of PhotoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoUploadStateCopyWith<PhotoUploadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoUploadStateCopyWith<$Res> {
  factory $PhotoUploadStateCopyWith(
          PhotoUploadState value, $Res Function(PhotoUploadState) then) =
      _$PhotoUploadStateCopyWithImpl<$Res, PhotoUploadState>;
  @useResult
  $Res call(
      {List<XFile?> storeImages,
      XFile? storeLogo,
      String message,
      bool isLoading,
      String? uploadError,
      String? ownerEmail});
}

/// @nodoc
class _$PhotoUploadStateCopyWithImpl<$Res, $Val extends PhotoUploadState>
    implements $PhotoUploadStateCopyWith<$Res> {
  _$PhotoUploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeImages = null,
    Object? storeLogo = freezed,
    Object? message = null,
    Object? isLoading = null,
    Object? uploadError = freezed,
    Object? ownerEmail = freezed,
  }) {
    return _then(_value.copyWith(
      storeImages: null == storeImages
          ? _value.storeImages
          : storeImages // ignore: cast_nullable_to_non_nullable
              as List<XFile?>,
      storeLogo: freezed == storeLogo
          ? _value.storeLogo
          : storeLogo // ignore: cast_nullable_to_non_nullable
              as XFile?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadError: freezed == uploadError
          ? _value.uploadError
          : uploadError // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerEmail: freezed == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhotoUploadStateImplCopyWith<$Res>
    implements $PhotoUploadStateCopyWith<$Res> {
  factory _$$PhotoUploadStateImplCopyWith(_$PhotoUploadStateImpl value,
          $Res Function(_$PhotoUploadStateImpl) then) =
      __$$PhotoUploadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<XFile?> storeImages,
      XFile? storeLogo,
      String message,
      bool isLoading,
      String? uploadError,
      String? ownerEmail});
}

/// @nodoc
class __$$PhotoUploadStateImplCopyWithImpl<$Res>
    extends _$PhotoUploadStateCopyWithImpl<$Res, _$PhotoUploadStateImpl>
    implements _$$PhotoUploadStateImplCopyWith<$Res> {
  __$$PhotoUploadStateImplCopyWithImpl(_$PhotoUploadStateImpl _value,
      $Res Function(_$PhotoUploadStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhotoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeImages = null,
    Object? storeLogo = freezed,
    Object? message = null,
    Object? isLoading = null,
    Object? uploadError = freezed,
    Object? ownerEmail = freezed,
  }) {
    return _then(_$PhotoUploadStateImpl(
      storeImages: null == storeImages
          ? _value._storeImages
          : storeImages // ignore: cast_nullable_to_non_nullable
              as List<XFile?>,
      storeLogo: freezed == storeLogo
          ? _value.storeLogo
          : storeLogo // ignore: cast_nullable_to_non_nullable
              as XFile?,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadError: freezed == uploadError
          ? _value.uploadError
          : uploadError // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerEmail: freezed == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PhotoUploadStateImpl implements _PhotoUploadState {
  const _$PhotoUploadStateImpl(
      {required final List<XFile?> storeImages,
      required this.storeLogo,
      required this.message,
      this.isLoading = false,
      this.uploadError,
      this.ownerEmail})
      : _storeImages = storeImages;

  final List<XFile?> _storeImages;
  @override
  List<XFile?> get storeImages {
    if (_storeImages is EqualUnmodifiableListView) return _storeImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storeImages);
  }

  @override
  final XFile? storeLogo;
  @override
  final String message;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? uploadError;
  @override
  final String? ownerEmail;

  @override
  String toString() {
    return 'PhotoUploadState(storeImages: $storeImages, storeLogo: $storeLogo, message: $message, isLoading: $isLoading, uploadError: $uploadError, ownerEmail: $ownerEmail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoUploadStateImpl &&
            const DeepCollectionEquality()
                .equals(other._storeImages, _storeImages) &&
            (identical(other.storeLogo, storeLogo) ||
                other.storeLogo == storeLogo) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.uploadError, uploadError) ||
                other.uploadError == uploadError) &&
            (identical(other.ownerEmail, ownerEmail) ||
                other.ownerEmail == ownerEmail));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_storeImages),
      storeLogo,
      message,
      isLoading,
      uploadError,
      ownerEmail);

  /// Create a copy of PhotoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoUploadStateImplCopyWith<_$PhotoUploadStateImpl> get copyWith =>
      __$$PhotoUploadStateImplCopyWithImpl<_$PhotoUploadStateImpl>(
          this, _$identity);
}

abstract class _PhotoUploadState implements PhotoUploadState {
  const factory _PhotoUploadState(
      {required final List<XFile?> storeImages,
      required final XFile? storeLogo,
      required final String message,
      final bool isLoading,
      final String? uploadError,
      final String? ownerEmail}) = _$PhotoUploadStateImpl;

  @override
  List<XFile?> get storeImages;
  @override
  XFile? get storeLogo;
  @override
  String get message;
  @override
  bool get isLoading;
  @override
  String? get uploadError;
  @override
  String? get ownerEmail;

  /// Create a copy of PhotoUploadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoUploadStateImplCopyWith<_$PhotoUploadStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
