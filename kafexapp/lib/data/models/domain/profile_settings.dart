import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_settings.freezed.dart';
part 'profile_settings.g.dart';

@freezed
class ProfileSettings with _$ProfileSettings {
  const factory ProfileSettings({
    required String name,
    required String username,
    required String email,
    String? phone,
    String? address,
    String? profileImagePath,
    @Default(false) bool hasChanges,
  }) = _ProfileSettings;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsFromJson(json);
}

@freezed
class ProfileSettingsState with _$ProfileSettingsState {
  const factory ProfileSettingsState({
    ProfileSettings? settings,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? selectedImagePath,
    String? errorMessage,
  }) = _ProfileSettingsState;

  factory ProfileSettingsState.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsStateFromJson(json);
}