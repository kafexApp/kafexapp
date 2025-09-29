import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/data/repositories/profile_settings_repository.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/utils/app_colors.dart';

class ProfileSettingsViewModel extends ChangeNotifier {
  final ProfileSettingsRepository _repository;

  ProfileSettingsViewModel({
    required ProfileSettingsRepository repository,
  }) : _repository = repository;

  // Estados
  ProfileSettingsState _state = const ProfileSettingsState();

  // Getters
  ProfileSettingsState get state => _state;
  ProfileSettings? get settings => _state.settings;
  bool get isLoading => _state.isLoading;
  bool get isSaving => _state.isSaving;
  String? get selectedImagePath => _state.selectedImagePath;
  bool get hasChanges => _state.settings?.hasChanges ?? false;

  // Commands
  late final Command0<void> loadSettings = Command0(_loadSettings);
  late final Command0<void> selectImage = Command0(_selectImage);
  late final Command1<void, ProfileSettings> saveSettings = Command1(_saveSettings);
  late final Command0<void> resetPassword = Command0(_resetPassword);
  late final Command0<void> deleteAccount = Command0(_deleteAccount);
  late final Command1<void, ProfileSettings> updateSettings = Command1(_updateSettings);

  // Métodos dos Commands
  Future<Result<void>> _loadSettings() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _repository.loadUserSettings();
    
    if (result.isOk) {
      _updateState(_state.copyWith(
        settings: result.asOk.value,
        isLoading: false,
      ));
      return Result.ok(null);
    } else {
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: result.asError.error.toString(),
      ));
      return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        _updateState(_state.copyWith(selectedImagePath: image.path));
        
        // Marcar como tendo alterações
        if (_state.settings != null) {
          final updatedSettings = _state.settings!.copyWith(hasChanges: true);
          _updateState(_state.copyWith(settings: updatedSettings));
        }
        
        return Result.ok(null);
      }
      
      return Result.error(Exception('Nenhuma imagem selecionada'));
    } catch (e) {
      return Result.error(Exception('Erro ao selecionar imagem: $e'));
    }
  }

  Future<Result<void>> _saveSettings(ProfileSettings settings) async {
    _updateState(_state.copyWith(isSaving: true, errorMessage: null));
    
    // Criar settings com imagem selecionada se houver
    final settingsToSave = settings.copyWith(
      profileImagePath: _state.selectedImagePath ?? settings.profileImagePath,
    );
    
    final result = await _repository.saveUserSettings(settingsToSave);
    
    if (result.isOk) {
      final updatedSettings = settingsToSave.copyWith(
        hasChanges: false,
        profileImagePath: _state.selectedImagePath ?? settings.profileImagePath,
      );
      
      _updateState(_state.copyWith(
        settings: updatedSettings,
        isSaving: false,
        selectedImagePath: null, // Limpar imagem selecionada após salvar
      ));
      
      return Result.ok(null);
    } else {
      _updateState(_state.copyWith(
        isSaving: false,
        errorMessage: result.asError.error.toString(),
      ));
      return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _resetPassword() async {
    if (_state.settings == null) {
      return Result.error(Exception('Configurações não carregadas'));
    }
    
    final result = await _repository.resetPassword(_state.settings!.email);
    
    if (result.isError) {
      _updateState(_state.copyWith(errorMessage: result.asError.error.toString()));
    }
    
    return result;
  }

  Future<Result<void>> _deleteAccount() async {
    _updateState(_state.copyWith(isSaving: true, errorMessage: null));
    
    final result = await _repository.deleteUserAccount();
    
    if (result.isError) {
      _updateState(_state.copyWith(
        isSaving: false,
        errorMessage: result.asError.error.toString(),
      ));
    }
    
    return result;
  }

  Future<Result<void>> _updateSettings(ProfileSettings newSettings) async {
    _updateState(_state.copyWith(settings: newSettings));
    return Result.ok(null);
  }

  // Métodos utilitários
  String getProfileImagePath() {
    return _state.selectedImagePath ?? 
           _state.settings?.profileImagePath ?? 
           '';
  }

  Widget buildFallbackAvatar(String userName) {
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.carbon,
      AppColors.grayScale2,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 114,
      height: 114,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
          ).copyWith(color: avatarColor),
        ),
      ),
    );
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  void _updateState(ProfileSettingsState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    loadSettings.dispose();
    selectImage.dispose();
    saveSettings.dispose();
    resetPassword.dispose();
    deleteAccount.dispose();
    updateSettings.dispose();
    super.dispose();
  }
}