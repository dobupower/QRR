// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Owner _$OwnerFromJson(Map<String, dynamic> json) {
  return _Owner.fromJson(json);
}

/// @nodoc
mixin _$Owner {
  String get uid => throw _privateConstructorUsedError; // 고유 ID
  String get storeName => throw _privateConstructorUsedError; // 점포명
  String get email => throw _privateConstructorUsedError; // 이메일 주소
  String get zipCode => throw _privateConstructorUsedError; // 우편번호
  String get prefecture => throw _privateConstructorUsedError; // 도도부현
  String get city => throw _privateConstructorUsedError; // 시/구/읍/면/동
  String get address => throw _privateConstructorUsedError; // 상세 주소
  String? get building => throw _privateConstructorUsedError; // 건물명 (선택사항)
  String get authType => throw _privateConstructorUsedError; // 인증 유형
  String get type => throw _privateConstructorUsedError; // 사용자 유형
  int get pointLimit => throw _privateConstructorUsedError;

  /// Serializes this Owner to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OwnerCopyWith<Owner> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OwnerCopyWith<$Res> {
  factory $OwnerCopyWith(Owner value, $Res Function(Owner) then) =
      _$OwnerCopyWithImpl<$Res, Owner>;
  @useResult
  $Res call(
      {String uid,
      String storeName,
      String email,
      String zipCode,
      String prefecture,
      String city,
      String address,
      String? building,
      String authType,
      String type,
      int pointLimit});
}

/// @nodoc
class _$OwnerCopyWithImpl<$Res, $Val extends Owner>
    implements $OwnerCopyWith<$Res> {
  _$OwnerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? storeName = null,
    Object? email = null,
    Object? zipCode = null,
    Object? prefecture = null,
    Object? city = null,
    Object? address = null,
    Object? building = freezed,
    Object? authType = null,
    Object? type = null,
    Object? pointLimit = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      authType: null == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      pointLimit: null == pointLimit
          ? _value.pointLimit
          : pointLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OwnerImplCopyWith<$Res> implements $OwnerCopyWith<$Res> {
  factory _$$OwnerImplCopyWith(
          _$OwnerImpl value, $Res Function(_$OwnerImpl) then) =
      __$$OwnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String storeName,
      String email,
      String zipCode,
      String prefecture,
      String city,
      String address,
      String? building,
      String authType,
      String type,
      int pointLimit});
}

/// @nodoc
class __$$OwnerImplCopyWithImpl<$Res>
    extends _$OwnerCopyWithImpl<$Res, _$OwnerImpl>
    implements _$$OwnerImplCopyWith<$Res> {
  __$$OwnerImplCopyWithImpl(
      _$OwnerImpl _value, $Res Function(_$OwnerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? storeName = null,
    Object? email = null,
    Object? zipCode = null,
    Object? prefecture = null,
    Object? city = null,
    Object? address = null,
    Object? building = freezed,
    Object? authType = null,
    Object? type = null,
    Object? pointLimit = null,
  }) {
    return _then(_$OwnerImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      prefecture: null == prefecture
          ? _value.prefecture
          : prefecture // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      building: freezed == building
          ? _value.building
          : building // ignore: cast_nullable_to_non_nullable
              as String?,
      authType: null == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      pointLimit: null == pointLimit
          ? _value.pointLimit
          : pointLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OwnerImpl implements _Owner {
  const _$OwnerImpl(
      {required this.uid,
      required this.storeName,
      required this.email,
      required this.zipCode,
      required this.prefecture,
      required this.city,
      required this.address,
      this.building,
      this.authType = 'email',
      this.type = 'owner',
      this.pointLimit = 100000});

  factory _$OwnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$OwnerImplFromJson(json);

  @override
  final String uid;
// 고유 ID
  @override
  final String storeName;
// 점포명
  @override
  final String email;
// 이메일 주소
  @override
  final String zipCode;
// 우편번호
  @override
  final String prefecture;
// 도도부현
  @override
  final String city;
// 시/구/읍/면/동
  @override
  final String address;
// 상세 주소
  @override
  final String? building;
// 건물명 (선택사항)
  @override
  @JsonKey()
  final String authType;
// 인증 유형
  @override
  @JsonKey()
  final String type;
// 사용자 유형
  @override
  @JsonKey()
  final int pointLimit;

  @override
  String toString() {
    return 'Owner(uid: $uid, storeName: $storeName, email: $email, zipCode: $zipCode, prefecture: $prefecture, city: $city, address: $address, building: $building, authType: $authType, type: $type, pointLimit: $pointLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnerImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.prefecture, prefecture) ||
                other.prefecture == prefecture) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pointLimit, pointLimit) ||
                other.pointLimit == pointLimit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, storeName, email, zipCode,
      prefecture, city, address, building, authType, type, pointLimit);

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      __$$OwnerImplCopyWithImpl<_$OwnerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OwnerImplToJson(
      this,
    );
  }
}

abstract class _Owner implements Owner {
  const factory _Owner(
      {required final String uid,
      required final String storeName,
      required final String email,
      required final String zipCode,
      required final String prefecture,
      required final String city,
      required final String address,
      final String? building,
      final String authType,
      final String type,
      final int pointLimit}) = _$OwnerImpl;

  factory _Owner.fromJson(Map<String, dynamic> json) = _$OwnerImpl.fromJson;

  @override
  String get uid; // 고유 ID
  @override
  String get storeName; // 점포명
  @override
  String get email; // 이메일 주소
  @override
  String get zipCode; // 우편번호
  @override
  String get prefecture; // 도도부현
  @override
  String get city; // 시/구/읍/면/동
  @override
  String get address; // 상세 주소
  @override
  String? get building; // 건물명 (선택사항)
  @override
  String get authType; // 인증 유형
  @override
  String get type; // 사용자 유형
  @override
  int get pointLimit;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
