// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SignUpState _$SignUpStateFromJson(Map<String, dynamic> json) {
  return _SignUpState.fromJson(json);
}

/// @nodoc
mixin _$SignUpState {
  @JsonKey(ignore: true)
  TextEditingController? get nameController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  TextEditingController? get emailController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  TextEditingController? get passwordController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  TextEditingController? get confirmPasswordController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  TextEditingController? get codeController =>
      throw _privateConstructorUsedError;
  String? get verificationCode => throw _privateConstructorUsedError;
  String? get emailError => throw _privateConstructorUsedError;
  String? get passwordError => throw _privateConstructorUsedError;
  String? get confirmPasswordError => throw _privateConstructorUsedError;
  String? get verificationErrorMessage => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get isPasswordVisible => throw _privateConstructorUsedError;
  bool get isConfirmPasswordVisible => throw _privateConstructorUsedError;
  String? get selectedStore => throw _privateConstructorUsedError;
  List<String> get stores =>
      throw _privateConstructorUsedError; // 스토어 목록 기본값 설정
  List<String> get filteredStores => throw _privateConstructorUsedError;

  /// Serializes this SignUpState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignUpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignUpStateCopyWith<SignUpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignUpStateCopyWith<$Res> {
  factory $SignUpStateCopyWith(
          SignUpState value, $Res Function(SignUpState) then) =
      _$SignUpStateCopyWithImpl<$Res, SignUpState>;
  @useResult
  $Res call(
      {@JsonKey(ignore: true) TextEditingController? nameController,
      @JsonKey(ignore: true) TextEditingController? emailController,
      @JsonKey(ignore: true) TextEditingController? passwordController,
      @JsonKey(ignore: true) TextEditingController? confirmPasswordController,
      @JsonKey(ignore: true) TextEditingController? codeController,
      String? verificationCode,
      String? emailError,
      String? passwordError,
      String? confirmPasswordError,
      String? verificationErrorMessage,
      bool isLoading,
      String type,
      bool isPasswordVisible,
      bool isConfirmPasswordVisible,
      String? selectedStore,
      List<String> stores,
      List<String> filteredStores});
}

/// @nodoc
class _$SignUpStateCopyWithImpl<$Res, $Val extends SignUpState>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignUpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nameController = freezed,
    Object? emailController = freezed,
    Object? passwordController = freezed,
    Object? confirmPasswordController = freezed,
    Object? codeController = freezed,
    Object? verificationCode = freezed,
    Object? emailError = freezed,
    Object? passwordError = freezed,
    Object? confirmPasswordError = freezed,
    Object? verificationErrorMessage = freezed,
    Object? isLoading = null,
    Object? type = null,
    Object? isPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? selectedStore = freezed,
    Object? stores = null,
    Object? filteredStores = null,
  }) {
    return _then(_value.copyWith(
      nameController: freezed == nameController
          ? _value.nameController
          : nameController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      emailController: freezed == emailController
          ? _value.emailController
          : emailController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      passwordController: freezed == passwordController
          ? _value.passwordController
          : passwordController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      confirmPasswordController: freezed == confirmPasswordController
          ? _value.confirmPasswordController
          : confirmPasswordController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      codeController: freezed == codeController
          ? _value.codeController
          : codeController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      verificationCode: freezed == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      emailError: freezed == emailError
          ? _value.emailError
          : emailError // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _value.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmPasswordError: freezed == confirmPasswordError
          ? _value.confirmPasswordError
          : confirmPasswordError // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationErrorMessage: freezed == verificationErrorMessage
          ? _value.verificationErrorMessage
          : verificationErrorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfirmPasswordVisible: null == isConfirmPasswordVisible
          ? _value.isConfirmPasswordVisible
          : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedStore: freezed == selectedStore
          ? _value.selectedStore
          : selectedStore // ignore: cast_nullable_to_non_nullable
              as String?,
      stores: null == stores
          ? _value.stores
          : stores // ignore: cast_nullable_to_non_nullable
              as List<String>,
      filteredStores: null == filteredStores
          ? _value.filteredStores
          : filteredStores // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SignUpStateImplCopyWith<$Res>
    implements $SignUpStateCopyWith<$Res> {
  factory _$$SignUpStateImplCopyWith(
          _$SignUpStateImpl value, $Res Function(_$SignUpStateImpl) then) =
      __$$SignUpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(ignore: true) TextEditingController? nameController,
      @JsonKey(ignore: true) TextEditingController? emailController,
      @JsonKey(ignore: true) TextEditingController? passwordController,
      @JsonKey(ignore: true) TextEditingController? confirmPasswordController,
      @JsonKey(ignore: true) TextEditingController? codeController,
      String? verificationCode,
      String? emailError,
      String? passwordError,
      String? confirmPasswordError,
      String? verificationErrorMessage,
      bool isLoading,
      String type,
      bool isPasswordVisible,
      bool isConfirmPasswordVisible,
      String? selectedStore,
      List<String> stores,
      List<String> filteredStores});
}

/// @nodoc
class __$$SignUpStateImplCopyWithImpl<$Res>
    extends _$SignUpStateCopyWithImpl<$Res, _$SignUpStateImpl>
    implements _$$SignUpStateImplCopyWith<$Res> {
  __$$SignUpStateImplCopyWithImpl(
      _$SignUpStateImpl _value, $Res Function(_$SignUpStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SignUpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nameController = freezed,
    Object? emailController = freezed,
    Object? passwordController = freezed,
    Object? confirmPasswordController = freezed,
    Object? codeController = freezed,
    Object? verificationCode = freezed,
    Object? emailError = freezed,
    Object? passwordError = freezed,
    Object? confirmPasswordError = freezed,
    Object? verificationErrorMessage = freezed,
    Object? isLoading = null,
    Object? type = null,
    Object? isPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? selectedStore = freezed,
    Object? stores = null,
    Object? filteredStores = null,
  }) {
    return _then(_$SignUpStateImpl(
      nameController: freezed == nameController
          ? _value.nameController
          : nameController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      emailController: freezed == emailController
          ? _value.emailController
          : emailController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      passwordController: freezed == passwordController
          ? _value.passwordController
          : passwordController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      confirmPasswordController: freezed == confirmPasswordController
          ? _value.confirmPasswordController
          : confirmPasswordController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      codeController: freezed == codeController
          ? _value.codeController
          : codeController // ignore: cast_nullable_to_non_nullable
              as TextEditingController?,
      verificationCode: freezed == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      emailError: freezed == emailError
          ? _value.emailError
          : emailError // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _value.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmPasswordError: freezed == confirmPasswordError
          ? _value.confirmPasswordError
          : confirmPasswordError // ignore: cast_nullable_to_non_nullable
              as String?,
      verificationErrorMessage: freezed == verificationErrorMessage
          ? _value.verificationErrorMessage
          : verificationErrorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfirmPasswordVisible: null == isConfirmPasswordVisible
          ? _value.isConfirmPasswordVisible
          : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedStore: freezed == selectedStore
          ? _value.selectedStore
          : selectedStore // ignore: cast_nullable_to_non_nullable
              as String?,
      stores: null == stores
          ? _value._stores
          : stores // ignore: cast_nullable_to_non_nullable
              as List<String>,
      filteredStores: null == filteredStores
          ? _value._filteredStores
          : filteredStores // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SignUpStateImpl implements _SignUpState {
  const _$SignUpStateImpl(
      {@JsonKey(ignore: true) this.nameController,
      @JsonKey(ignore: true) this.emailController,
      @JsonKey(ignore: true) this.passwordController,
      @JsonKey(ignore: true) this.confirmPasswordController,
      @JsonKey(ignore: true) this.codeController,
      this.verificationCode,
      this.emailError,
      this.passwordError,
      this.confirmPasswordError,
      this.verificationErrorMessage,
      this.isLoading = false,
      this.type = 'customer',
      this.isPasswordVisible = false,
      this.isConfirmPasswordVisible = false,
      this.selectedStore,
      final List<String> stores = const [],
      final List<String> filteredStores = const []})
      : _stores = stores,
        _filteredStores = filteredStores;

  factory _$SignUpStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignUpStateImplFromJson(json);

  @override
  @JsonKey(ignore: true)
  final TextEditingController? nameController;
  @override
  @JsonKey(ignore: true)
  final TextEditingController? emailController;
  @override
  @JsonKey(ignore: true)
  final TextEditingController? passwordController;
  @override
  @JsonKey(ignore: true)
  final TextEditingController? confirmPasswordController;
  @override
  @JsonKey(ignore: true)
  final TextEditingController? codeController;
  @override
  final String? verificationCode;
  @override
  final String? emailError;
  @override
  final String? passwordError;
  @override
  final String? confirmPasswordError;
  @override
  final String? verificationErrorMessage;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final bool isPasswordVisible;
  @override
  @JsonKey()
  final bool isConfirmPasswordVisible;
  @override
  final String? selectedStore;
  final List<String> _stores;
  @override
  @JsonKey()
  List<String> get stores {
    if (_stores is EqualUnmodifiableListView) return _stores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stores);
  }

// 스토어 목록 기본값 설정
  final List<String> _filteredStores;
// 스토어 목록 기본값 설정
  @override
  @JsonKey()
  List<String> get filteredStores {
    if (_filteredStores is EqualUnmodifiableListView) return _filteredStores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredStores);
  }

  @override
  String toString() {
    return 'SignUpState(nameController: $nameController, emailController: $emailController, passwordController: $passwordController, confirmPasswordController: $confirmPasswordController, codeController: $codeController, verificationCode: $verificationCode, emailError: $emailError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, verificationErrorMessage: $verificationErrorMessage, isLoading: $isLoading, type: $type, isPasswordVisible: $isPasswordVisible, isConfirmPasswordVisible: $isConfirmPasswordVisible, selectedStore: $selectedStore, stores: $stores, filteredStores: $filteredStores)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignUpStateImpl &&
            (identical(other.nameController, nameController) ||
                other.nameController == nameController) &&
            (identical(other.emailController, emailController) ||
                other.emailController == emailController) &&
            (identical(other.passwordController, passwordController) ||
                other.passwordController == passwordController) &&
            (identical(other.confirmPasswordController,
                    confirmPasswordController) ||
                other.confirmPasswordController == confirmPasswordController) &&
            (identical(other.codeController, codeController) ||
                other.codeController == codeController) &&
            (identical(other.verificationCode, verificationCode) ||
                other.verificationCode == verificationCode) &&
            (identical(other.emailError, emailError) ||
                other.emailError == emailError) &&
            (identical(other.passwordError, passwordError) ||
                other.passwordError == passwordError) &&
            (identical(other.confirmPasswordError, confirmPasswordError) ||
                other.confirmPasswordError == confirmPasswordError) &&
            (identical(
                    other.verificationErrorMessage, verificationErrorMessage) ||
                other.verificationErrorMessage == verificationErrorMessage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isPasswordVisible, isPasswordVisible) ||
                other.isPasswordVisible == isPasswordVisible) &&
            (identical(
                    other.isConfirmPasswordVisible, isConfirmPasswordVisible) ||
                other.isConfirmPasswordVisible == isConfirmPasswordVisible) &&
            (identical(other.selectedStore, selectedStore) ||
                other.selectedStore == selectedStore) &&
            const DeepCollectionEquality().equals(other._stores, _stores) &&
            const DeepCollectionEquality()
                .equals(other._filteredStores, _filteredStores));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      nameController,
      emailController,
      passwordController,
      confirmPasswordController,
      codeController,
      verificationCode,
      emailError,
      passwordError,
      confirmPasswordError,
      verificationErrorMessage,
      isLoading,
      type,
      isPasswordVisible,
      isConfirmPasswordVisible,
      selectedStore,
      const DeepCollectionEquality().hash(_stores),
      const DeepCollectionEquality().hash(_filteredStores));

  /// Create a copy of SignUpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignUpStateImplCopyWith<_$SignUpStateImpl> get copyWith =>
      __$$SignUpStateImplCopyWithImpl<_$SignUpStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignUpStateImplToJson(
      this,
    );
  }
}

abstract class _SignUpState implements SignUpState {
  const factory _SignUpState(
      {@JsonKey(ignore: true) final TextEditingController? nameController,
      @JsonKey(ignore: true) final TextEditingController? emailController,
      @JsonKey(ignore: true) final TextEditingController? passwordController,
      @JsonKey(ignore: true)
      final TextEditingController? confirmPasswordController,
      @JsonKey(ignore: true) final TextEditingController? codeController,
      final String? verificationCode,
      final String? emailError,
      final String? passwordError,
      final String? confirmPasswordError,
      final String? verificationErrorMessage,
      final bool isLoading,
      final String type,
      final bool isPasswordVisible,
      final bool isConfirmPasswordVisible,
      final String? selectedStore,
      final List<String> stores,
      final List<String> filteredStores}) = _$SignUpStateImpl;

  factory _SignUpState.fromJson(Map<String, dynamic> json) =
      _$SignUpStateImpl.fromJson;

  @override
  @JsonKey(ignore: true)
  TextEditingController? get nameController;
  @override
  @JsonKey(ignore: true)
  TextEditingController? get emailController;
  @override
  @JsonKey(ignore: true)
  TextEditingController? get passwordController;
  @override
  @JsonKey(ignore: true)
  TextEditingController? get confirmPasswordController;
  @override
  @JsonKey(ignore: true)
  TextEditingController? get codeController;
  @override
  String? get verificationCode;
  @override
  String? get emailError;
  @override
  String? get passwordError;
  @override
  String? get confirmPasswordError;
  @override
  String? get verificationErrorMessage;
  @override
  bool get isLoading;
  @override
  String get type;
  @override
  bool get isPasswordVisible;
  @override
  bool get isConfirmPasswordVisible;
  @override
  String? get selectedStore;
  @override
  List<String> get stores; // 스토어 목록 기본값 설정
  @override
  List<String> get filteredStores;

  /// Create a copy of SignUpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignUpStateImplCopyWith<_$SignUpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
