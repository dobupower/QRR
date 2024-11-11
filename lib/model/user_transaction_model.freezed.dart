// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserTransaction _$UserTransactionFromJson(Map<String, dynamic> json) {
  return _UserTransaction.fromJson(json);
}

/// @nodoc
mixin _$UserTransaction {
  String get transactionId => throw _privateConstructorUsedError; // 트랜잭션 고유 ID
  String get senderEmail => throw _privateConstructorUsedError; // 보내는 사람 이메일
  String get receiverEmail => throw _privateConstructorUsedError; // 받는 사람 이메일
  int get amount => throw _privateConstructorUsedError; // 거래 금액
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this UserTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserTransactionCopyWith<UserTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserTransactionCopyWith<$Res> {
  factory $UserTransactionCopyWith(
          UserTransaction value, $Res Function(UserTransaction) then) =
      _$UserTransactionCopyWithImpl<$Res, UserTransaction>;
  @useResult
  $Res call(
      {String transactionId,
      String senderEmail,
      String receiverEmail,
      int amount,
      DateTime timestamp});
}

/// @nodoc
class _$UserTransactionCopyWithImpl<$Res, $Val extends UserTransaction>
    implements $UserTransactionCopyWith<$Res> {
  _$UserTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? senderEmail = null,
    Object? receiverEmail = null,
    Object? amount = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      senderEmail: null == senderEmail
          ? _value.senderEmail
          : senderEmail // ignore: cast_nullable_to_non_nullable
              as String,
      receiverEmail: null == receiverEmail
          ? _value.receiverEmail
          : receiverEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserTransactionImplCopyWith<$Res>
    implements $UserTransactionCopyWith<$Res> {
  factory _$$UserTransactionImplCopyWith(_$UserTransactionImpl value,
          $Res Function(_$UserTransactionImpl) then) =
      __$$UserTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String transactionId,
      String senderEmail,
      String receiverEmail,
      int amount,
      DateTime timestamp});
}

/// @nodoc
class __$$UserTransactionImplCopyWithImpl<$Res>
    extends _$UserTransactionCopyWithImpl<$Res, _$UserTransactionImpl>
    implements _$$UserTransactionImplCopyWith<$Res> {
  __$$UserTransactionImplCopyWithImpl(
      _$UserTransactionImpl _value, $Res Function(_$UserTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transactionId = null,
    Object? senderEmail = null,
    Object? receiverEmail = null,
    Object? amount = null,
    Object? timestamp = null,
  }) {
    return _then(_$UserTransactionImpl(
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      senderEmail: null == senderEmail
          ? _value.senderEmail
          : senderEmail // ignore: cast_nullable_to_non_nullable
              as String,
      receiverEmail: null == receiverEmail
          ? _value.receiverEmail
          : receiverEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
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
class _$UserTransactionImpl implements _UserTransaction {
  const _$UserTransactionImpl(
      {required this.transactionId,
      required this.senderEmail,
      required this.receiverEmail,
      required this.amount,
      required this.timestamp});

  factory _$UserTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserTransactionImplFromJson(json);

  @override
  final String transactionId;
// 트랜잭션 고유 ID
  @override
  final String senderEmail;
// 보내는 사람 이메일
  @override
  final String receiverEmail;
// 받는 사람 이메일
  @override
  final int amount;
// 거래 금액
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'UserTransaction(transactionId: $transactionId, senderEmail: $senderEmail, receiverEmail: $receiverEmail, amount: $amount, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserTransactionImpl &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.senderEmail, senderEmail) ||
                other.senderEmail == senderEmail) &&
            (identical(other.receiverEmail, receiverEmail) ||
                other.receiverEmail == receiverEmail) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, transactionId, senderEmail,
      receiverEmail, amount, timestamp);

  /// Create a copy of UserTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserTransactionImplCopyWith<_$UserTransactionImpl> get copyWith =>
      __$$UserTransactionImplCopyWithImpl<_$UserTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserTransactionImplToJson(
      this,
    );
  }
}

abstract class _UserTransaction implements UserTransaction {
  const factory _UserTransaction(
      {required final String transactionId,
      required final String senderEmail,
      required final String receiverEmail,
      required final int amount,
      required final DateTime timestamp}) = _$UserTransactionImpl;

  factory _UserTransaction.fromJson(Map<String, dynamic> json) =
      _$UserTransactionImpl.fromJson;

  @override
  String get transactionId; // 트랜잭션 고유 ID
  @override
  String get senderEmail; // 보내는 사람 이메일
  @override
  String get receiverEmail; // 받는 사람 이메일
  @override
  int get amount; // 거래 금액
  @override
  DateTime get timestamp;

  /// Create a copy of UserTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserTransactionImplCopyWith<_$UserTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
