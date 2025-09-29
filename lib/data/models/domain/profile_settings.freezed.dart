// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileSettings _$ProfileSettingsFromJson(Map<String, dynamic> json) {
  return _ProfileSettings.fromJson(json);
}

/// @nodoc
mixin _$ProfileSettings {
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get profileImagePath => throw _privateConstructorUsedError;
  bool get hasChanges => throw _privateConstructorUsedError;

  /// Serializes this ProfileSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSettingsCopyWith<ProfileSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSettingsCopyWith<$Res> {
  factory $ProfileSettingsCopyWith(
    ProfileSettings value,
    $Res Function(ProfileSettings) then,
  ) = _$ProfileSettingsCopyWithImpl<$Res, ProfileSettings>;
  @useResult
  $Res call({
    String name,
    String username,
    String email,
    String? phone,
    String? address,
    String? profileImagePath,
    bool hasChanges,
  });
}

/// @nodoc
class _$ProfileSettingsCopyWithImpl<$Res, $Val extends ProfileSettings>
    implements $ProfileSettingsCopyWith<$Res> {
  _$ProfileSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? email = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? profileImagePath = freezed,
    Object? hasChanges = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImagePath: freezed == profileImagePath
                ? _value.profileImagePath
                : profileImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasChanges: null == hasChanges
                ? _value.hasChanges
                : hasChanges // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileSettingsImplCopyWith<$Res>
    implements $ProfileSettingsCopyWith<$Res> {
  factory _$$ProfileSettingsImplCopyWith(
    _$ProfileSettingsImpl value,
    $Res Function(_$ProfileSettingsImpl) then,
  ) = __$$ProfileSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String username,
    String email,
    String? phone,
    String? address,
    String? profileImagePath,
    bool hasChanges,
  });
}

/// @nodoc
class __$$ProfileSettingsImplCopyWithImpl<$Res>
    extends _$ProfileSettingsCopyWithImpl<$Res, _$ProfileSettingsImpl>
    implements _$$ProfileSettingsImplCopyWith<$Res> {
  __$$ProfileSettingsImplCopyWithImpl(
    _$ProfileSettingsImpl _value,
    $Res Function(_$ProfileSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? email = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? profileImagePath = freezed,
    Object? hasChanges = null,
  }) {
    return _then(
      _$ProfileSettingsImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImagePath: freezed == profileImagePath
            ? _value.profileImagePath
            : profileImagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasChanges: null == hasChanges
            ? _value.hasChanges
            : hasChanges // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileSettingsImpl implements _ProfileSettings {
  const _$ProfileSettingsImpl({
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.address,
    this.profileImagePath,
    this.hasChanges = false,
  });

  factory _$ProfileSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileSettingsImplFromJson(json);

  @override
  final String name;
  @override
  final String username;
  @override
  final String email;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  final String? profileImagePath;
  @override
  @JsonKey()
  final bool hasChanges;

  @override
  String toString() {
    return 'ProfileSettings(name: $name, username: $username, email: $email, phone: $phone, address: $address, profileImagePath: $profileImagePath, hasChanges: $hasChanges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSettingsImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.profileImagePath, profileImagePath) ||
                other.profileImagePath == profileImagePath) &&
            (identical(other.hasChanges, hasChanges) ||
                other.hasChanges == hasChanges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    username,
    email,
    phone,
    address,
    profileImagePath,
    hasChanges,
  );

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSettingsImplCopyWith<_$ProfileSettingsImpl> get copyWith =>
      __$$ProfileSettingsImplCopyWithImpl<_$ProfileSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileSettingsImplToJson(this);
  }
}

abstract class _ProfileSettings implements ProfileSettings {
  const factory _ProfileSettings({
    required final String name,
    required final String username,
    required final String email,
    final String? phone,
    final String? address,
    final String? profileImagePath,
    final bool hasChanges,
  }) = _$ProfileSettingsImpl;

  factory _ProfileSettings.fromJson(Map<String, dynamic> json) =
      _$ProfileSettingsImpl.fromJson;

  @override
  String get name;
  @override
  String get username;
  @override
  String get email;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  String? get profileImagePath;
  @override
  bool get hasChanges;

  /// Create a copy of ProfileSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSettingsImplCopyWith<_$ProfileSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileSettingsState _$ProfileSettingsStateFromJson(Map<String, dynamic> json) {
  return _ProfileSettingsState.fromJson(json);
}

/// @nodoc
mixin _$ProfileSettingsState {
  ProfileSettings? get settings => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  String? get selectedImagePath => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this ProfileSettingsState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSettingsStateCopyWith<ProfileSettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSettingsStateCopyWith<$Res> {
  factory $ProfileSettingsStateCopyWith(
    ProfileSettingsState value,
    $Res Function(ProfileSettingsState) then,
  ) = _$ProfileSettingsStateCopyWithImpl<$Res, ProfileSettingsState>;
  @useResult
  $Res call({
    ProfileSettings? settings,
    bool isLoading,
    bool isSaving,
    String? selectedImagePath,
    String? errorMessage,
  });

  $ProfileSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$ProfileSettingsStateCopyWithImpl<
  $Res,
  $Val extends ProfileSettingsState
>
    implements $ProfileSettingsStateCopyWith<$Res> {
  _$ProfileSettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settings = freezed,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? selectedImagePath = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as ProfileSettings?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSaving: null == isSaving
                ? _value.isSaving
                : isSaving // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedImagePath: freezed == selectedImagePath
                ? _value.selectedImagePath
                : selectedImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $ProfileSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileSettingsStateImplCopyWith<$Res>
    implements $ProfileSettingsStateCopyWith<$Res> {
  factory _$$ProfileSettingsStateImplCopyWith(
    _$ProfileSettingsStateImpl value,
    $Res Function(_$ProfileSettingsStateImpl) then,
  ) = __$$ProfileSettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ProfileSettings? settings,
    bool isLoading,
    bool isSaving,
    String? selectedImagePath,
    String? errorMessage,
  });

  @override
  $ProfileSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$ProfileSettingsStateImplCopyWithImpl<$Res>
    extends _$ProfileSettingsStateCopyWithImpl<$Res, _$ProfileSettingsStateImpl>
    implements _$$ProfileSettingsStateImplCopyWith<$Res> {
  __$$ProfileSettingsStateImplCopyWithImpl(
    _$ProfileSettingsStateImpl _value,
    $Res Function(_$ProfileSettingsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settings = freezed,
    Object? isLoading = null,
    Object? isSaving = null,
    Object? selectedImagePath = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ProfileSettingsStateImpl(
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as ProfileSettings?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSaving: null == isSaving
            ? _value.isSaving
            : isSaving // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedImagePath: freezed == selectedImagePath
            ? _value.selectedImagePath
            : selectedImagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileSettingsStateImpl implements _ProfileSettingsState {
  const _$ProfileSettingsStateImpl({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.selectedImagePath,
    this.errorMessage,
  });

  factory _$ProfileSettingsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileSettingsStateImplFromJson(json);

  @override
  final ProfileSettings? settings;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSaving;
  @override
  final String? selectedImagePath;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ProfileSettingsState(settings: $settings, isLoading: $isLoading, isSaving: $isSaving, selectedImagePath: $selectedImagePath, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSettingsStateImpl &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.selectedImagePath, selectedImagePath) ||
                other.selectedImagePath == selectedImagePath) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    settings,
    isLoading,
    isSaving,
    selectedImagePath,
    errorMessage,
  );

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSettingsStateImplCopyWith<_$ProfileSettingsStateImpl>
  get copyWith =>
      __$$ProfileSettingsStateImplCopyWithImpl<_$ProfileSettingsStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileSettingsStateImplToJson(this);
  }
}

abstract class _ProfileSettingsState implements ProfileSettingsState {
  const factory _ProfileSettingsState({
    final ProfileSettings? settings,
    final bool isLoading,
    final bool isSaving,
    final String? selectedImagePath,
    final String? errorMessage,
  }) = _$ProfileSettingsStateImpl;

  factory _ProfileSettingsState.fromJson(Map<String, dynamic> json) =
      _$ProfileSettingsStateImpl.fromJson;

  @override
  ProfileSettings? get settings;
  @override
  bool get isLoading;
  @override
  bool get isSaving;
  @override
  String? get selectedImagePath;
  @override
  String? get errorMessage;

  /// Create a copy of ProfileSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSettingsStateImplCopyWith<_$ProfileSettingsStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
