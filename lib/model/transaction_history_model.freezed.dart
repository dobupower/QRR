// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionHistory _$TransactionHistoryFromJson(Map<String, dynamic> json) {
  return _TransactionHistory.fromJson(json);
}

/// @nodoc
mixin _$TransactionHistory {
  String get name => throw _privateConstructorUsedError; // 거래 상대방의 이름
  String get transactionType =>
      throw _privateConstructorUsedError; // 거래 유형 (예: '송금', '수신' 등)
  int get points => throw _privateConstructorUsedError; // 거래된 포인트 양
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this TransactionHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionHistoryCopyWith<TransactionHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionHistoryCopyWith<$Res> {
  factory $TransactionHistoryCopyWith(
          TransactionHistory value, $Res Function(TransactionHistory) then) =
      _$TransactionHistoryCopyWithImpl<$Res, TransactionHistory>;
  @useResult
  $Res call(
      {String name, String transactionType, int points, DateTime timestamp});
}

/// @nodoc
class _$TransactionHistoryCopyWithImpl<$Res, $Val extends TransactionHistory>
    implements $TransactionHistoryCopyWith<$Res> {
  _$TransactionHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? transactionType = null,
    Object? points = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionHistoryImplCopyWith<$Res>
    implements $TransactionHistoryCopyWith<$Res> {
  factory _$$TransactionHistoryImplCopyWith(_$TransactionHistoryImpl value,
          $Res Function(_$TransactionHistoryImpl) then) =
      __$$TransactionHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, String transactionType, int points, DateTime timestamp});
}

/// @nodoc
class __$$TransactionHistoryImplCopyWithImpl<$Res>
    extends _$TransactionHistoryCopyWithImpl<$Res, _$TransactionHistoryImpl>
    implements _$$TransactionHistoryImplCopyWith<$Res> {
  __$$TransactionHistoryImplCopyWithImpl(_$TransactionHistoryImpl _value,
      $Res Function(_$TransactionHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? transactionType = null,
    Object? points = null,
    Object? timestamp = null,
  }) {
    return _then(_$TransactionHistoryImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      transactionType: null == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionHistoryImpl implements _TransactionHistory {
  const _$TransactionHistoryImpl(
      {required this.name,
      required this.transactionType,
      required this.points,
      required this.timestamp});

  factory _$TransactionHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionHistoryImplFromJson(json);

  @override
  final String name;
// 거래 상대방의 이름
  @override
  final String transactionType;
// 거래 유형 (예: '송금', '수신' 등)
  @override
  final int points;
// 거래된 포인트 양
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'TransactionHistory(name: $name, transactionType: $transactionType, points: $points, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionHistoryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, transactionType, points, timestamp);

  /// Create a copy of TransactionHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionHistoryImplCopyWith<_$TransactionHistoryImpl> get copyWith =>
      __$$TransactionHistoryImplCopyWithImpl<_$TransactionHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionHistoryImplToJson(
      this,
    );
  }
}

abstract class _TransactionHistory implements TransactionHistory {
  const factory _TransactionHistory(
      {required final String name,
      required final String transactionType,
      required final int points,
      required final DateTime timestamp}) = _$TransactionHistoryImpl;

  factory _TransactionHistory.fromJson(Map<String, dynamic> json) =
      _$TransactionHistoryImpl.fromJson;

  @override
  String get name; // 거래 상대방의 이름
  @override
  String get transactionType; // 거래 유형 (예: '송금', '수신' 등)
  @override
  int get points; // 거래된 포인트 양
  @override
  DateTime get timestamp;

  /// Create a copy of TransactionHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionHistoryImplCopyWith<_$TransactionHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
