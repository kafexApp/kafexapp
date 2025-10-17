import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/data/repositories/profile_settings_repository.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/services/avatar_service.dart';
import 'package:kafex/utils/user_manager.dart';

class ProfileSettingsViewModel extends ChangeNotifier {
  final ProfileSettingsRepository _repository;

  ProfileSettingsViewModel({
    required ProfileSettingsRepository repository,
  }) : _repository = repository;

  // Estados
  ProfileSettingsState _state = const ProfileSettingsState();
  List<int>? _imageBytes;

  // Getters
  ProfileSettingsState get state => _state;
  ProfileSettings? get settings => _state.settings;
  bool get isLoading => _state.isLoading;
  bool get isSaving => _state.isSaving;
  String? get selectedImagePath => _state.selectedImagePath;
  List<int>? get imageBytes => _imageBytes;
  bool get hasChanges => _state.settings?.hasChanges ?? false;

  // Commands
  late final Command0<void> loadSettings = Command0(_loadSettings);
  late final Command0<void> selectImage = Command0(_selectImage);
  late final Command1<void, ProfileSettings> saveSettings = Command1(_saveSettings);
  late final Command0<void> resetPassword = Command0(_resetPassword);
  late final Command0<void> deleteAccount = Command0(_deleteAccount);
  late final Command1<void, ProfileSettings> updateSettings = Command1(_updateSettings);

  Future<Result<void>> _loadSettings() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    try {
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
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar perfil: $e',
      ));
      return Result.error(Exception('Erro ao carregar perfil: $e'));
    }
  }

  Future<Result<void>> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _imageBytes = await image.readAsBytes();
        
        _updateState(_state.copyWith(selectedImagePath: image.path));
        
        if (_state.settings != null) {
          _updateState(_state.copyWith(
            settings: _state.settings!.copyWith(hasChanges: true),
          ));
        }
        
        print('✅ Imagem selecionada: ${image.path}');
        return Result.ok(null);
      }
      
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao selecionar imagem: $e');
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao selecionar imagem: $e',
      ));
      return Result.error(Exception('Erro ao selecionar imagem: $e'));
    }
  }

  Future<Result<void>> _saveSettings(ProfileSettings settings) async {
    _updateState(_state.copyWith(isSaving: true, errorMessage: null));
    
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser == null) {
        _updateState(_state.copyWith(
          isSaving: false,
          errorMessage: 'Usuário não autenticado',
        ));
        return Result.error(Exception('Usuário não autenticado'));
      }

      String? fotoUrl = settings.fotoUrl;
      
      if (_state.selectedImagePath != null && _imageBytes != null) {
        print('📸 Fazendo upload da nova foto...');
        
        final uploadResult = await AvatarService.uploadAvatar(
          userId: firebaseUser.uid,
          imagePath: _state.selectedImagePath!,
          imageBytes: _imageBytes,
        );
        
        if (uploadResult != null) {
          fotoUrl = uploadResult;
          print('✅ Upload concluído: $fotoUrl');
          
          if (settings.fotoUrl != null && settings.fotoUrl!.isNotEmpty) {
            await AvatarService.deleteAvatar(settings.fotoUrl!);
          }
          
          // Limpar cache da imagem antiga
          if (settings.fotoUrl != null) {
            await CachedNetworkImage.evictFromCache(settings.fotoUrl!);
          }
        } else {
          print('⚠️ Falha no upload da foto');
        }
      }

      final updatedSettings = settings.copyWith(fotoUrl: fotoUrl);

      final result = await _repository.saveUserSettings(updatedSettings);

      if (result.isOk) {
        // Atualizar Firebase Auth com nova foto
        if (fotoUrl != null) {
          await firebaseUser.updatePhotoURL(fotoUrl);
          await firebaseUser.reload();
          print('✅ Firebase Auth atualizado com nova foto');
        }
        
        // Atualizar nome se mudou
        if (settings.nomeExibicao != firebaseUser.displayName) {
          await firebaseUser.updateDisplayName(settings.nomeExibicao);
          await firebaseUser.reload();
          print('✅ Firebase Auth atualizado com novo nome');
        }
        
        _updateState(_state.copyWith(
          settings: updatedSettings.copyWith(hasChanges: false),
          isSaving: false,
          selectedImagePath: null,
        ));
        
        // Limpar bytes da imagem
        _imageBytes = null;
        
        return Result.ok(null);
      } else {
        _updateState(_state.copyWith(
          isSaving: false,
          errorMessage: result.asError.error.toString(),
        ));
        return Result.error(result.asError.error);
      }
    } catch (e) {
      _updateState(_state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar perfil: $e',
      ));
      return Result.error(Exception('Erro ao salvar perfil: $e'));
    }
  }

  Future<Result<void>> _resetPassword() async {
    try {
      if (_state.settings?.email == null) {
        _updateState(_state.copyWith(
          errorMessage: 'Email não encontrado',
        ));
        return Result.error(Exception('Email não encontrado'));
      }

      final result = await _repository.resetPassword(_state.settings!.email);
      
      if (result.isError) {
        _updateState(_state.copyWith(
          errorMessage: result.asError.error.toString(),
        ));
      }
      
      return result;
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao enviar email de redefinição: $e',
      ));
      return Result.error(Exception('Erro ao enviar email de redefinição: $e'));
    }
  }

  Future<Result<void>> _deleteAccount() async {
    _updateState(_state.copyWith(isSaving: true, errorMessage: null));
    
    try {
      final result = await _repository.deleteUserAccount();
      
      if (result.isOk) {
        _updateState(_state.copyWith(isSaving: false));
        return Result.ok(null);
      } else {
        _updateState(_state.copyWith(
          isSaving: false,
          errorMessage: result.asError.error.toString(),
        ));
        return Result.error(result.asError.error);
      }
    } catch (e) {
      _updateState(_state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao deletar conta: $e',
      ));
      return Result.error(Exception('Erro ao deletar conta: $e'));
    }
  }

  Future<Result<void>> _updateSettings(ProfileSettings settings) async {
    _updateState(_state.copyWith(settings: settings));
    return Result.ok(null);
  }

  void _updateState(ProfileSettingsState newState) {
    _state = newState;
    notifyListeners();
  }

  String getProfileImagePath() {
    if (_state.selectedImagePath != null) {
      return _state.selectedImagePath!;
    }
    
    return _state.settings?.fotoUrl ?? 
           UserManager.instance.userPhotoUrl ?? 
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
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }
}