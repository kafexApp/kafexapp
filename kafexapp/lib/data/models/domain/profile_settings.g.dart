// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileSettingsImpl _$$ProfileSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsImpl(
  name: json['name'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  profileImagePath: json['profileImagePath'] as String?,
  hasChanges: json['hasChanges'] as bool? ?? false,
);

Map<String, dynamic> _$$ProfileSettingsImplToJson(
  _$ProfileSettingsImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'username': instance.username,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'profileImagePath': instance.profileImagePath,
  'hasChanges': instance.hasChanges,
};

_$ProfileSettingsStateImpl _$$ProfileSettingsStateImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsStateImpl(
  settings: json['settings'] == null
      ? null
      : ProfileSettings.fromJson(json['settings'] as Map<String, dynamic>),
  isLoading: json['isLoading'] as bool? ?? false,
  isSaving: json['isSaving'] as bool? ?? false,
  selectedImagePath: json['selectedImagePath'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$ProfileSettingsStateImplToJson(
  _$ProfileSettingsStateImpl instance,
) => <String, dynamic>{
  'settings': instance.settings,
  'isLoading': instance.isLoading,
  'isSaving': instance.isSaving,
  'selectedImagePath': instance.selectedImagePath,
  'errorMessage': instance.errorMessage,
};
