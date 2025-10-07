// lib/ui/profile_settings/viewmodel/profile_settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/data/repositories/profile_settings_repository.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/services/user_profile_service.dart';
import 'package:kafex/utils/user_manager.dart';

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

  // Método para carregar settings do Supabase
  Future<Result<void>> _loadSettings() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser == null) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        ));
        return Result.error(Exception('Usuário não autenticado'));
      }

      print('🔍 Carregando perfil do usuário: ${firebaseUser.uid}');

      // Buscar perfil no Supabase
      final profile = await UserProfileService.getUserProfile(firebaseUser.uid);

      if (profile != null) {
        // Converter UsuarioPerfilRow para ProfileSettings
        final settings = ProfileSettings(
          name: profile.nomeExibicao ?? firebaseUser.displayName ?? 'Usuário',
          username: profile.nomeUsuario ?? '',
          email: profile.email ?? firebaseUser.email ?? '',
          phone: profile.telefone,
          address: profile.endereco,
          profileImagePath: profile.fotoUrl,
          hasChanges: false,
        );

        _updateState(_state.copyWith(
          settings: settings,
          isLoading: false,
        ));

        print('✅ Perfil carregado com sucesso: ${settings.name}');
        return Result.ok(null);
      } else {
        // Se não encontrou no Supabase, usar dados do Firebase
        final settings = ProfileSettings(
          name: firebaseUser.displayName ?? 'Usuário',
          username: '',
          email: firebaseUser.email ?? '',
          phone: null,
          address: null,
          profileImagePath: firebaseUser.photoURL,
          hasChanges: false,
        );

        _updateState(_state.copyWith(
          settings: settings,
          isLoading: false,
        ));

        print('⚠️ Perfil não encontrado no Supabase, usando Firebase');
        return Result.ok(null);
      }
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar perfil: $e',
      ));
      return Result.error(Exception('Erro ao carregar perfil: $e'));
    }
  }

  // Método para selecionar imagem
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
        _updateState(_state.copyWith(selectedImagePath: image.path));
        
        // Marcar como tendo mudanças
        if (_state.settings != null) {
          _updateState(_state.copyWith(
            settings: _state.settings!.copyWith(hasChanges: true),
          ));
        }
        
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

  // Método para salvar settings no Supabase
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

      print('💾 Salvando perfil do usuário: ${firebaseUser.uid}');

      // Atualizar no Supabase
      final success = await UserProfileService.updateUserProfile(
        firebaseUid: firebaseUser.uid,
        nomeExibicao: settings.name,
        nomeUsuario: settings.username,
        telefone: settings.phone,
        endereco: settings.address,
        fotoUrl: settings.profileImagePath,
      );

      if (success) {
        // Atualizar UserManager
        UserManager.instance.setUserData(
          name: settings.name,
          email: settings.email,
          photoUrl: settings.profileImagePath,
        );

        // Atualizar estado local
        _updateState(_state.copyWith(
          settings: settings.copyWith(hasChanges: false),
          isSaving: false,
          selectedImagePath: null,
        ));

        print('✅ Perfil salvo com sucesso');
        return Result.ok(null);
      } else {
        _updateState(_state.copyWith(
          isSaving: false,
          errorMessage: 'Erro ao salvar perfil no Supabase',
        ));
        return Result.error(Exception('Erro ao salvar perfil'));
      }
    } catch (e) {
      print('❌ Erro ao salvar perfil: $e');
      _updateState(_state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar perfil: $e',
      ));
      return Result.error(Exception('Erro ao salvar perfil: $e'));
    }
  }

  // Método para redefinir senha
  Future<Result<void>> _resetPassword() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser == null || firebaseUser.email == null) {
        _updateState(_state.copyWith(
          errorMessage: 'Usuário não autenticado ou sem email',
        ));
        return Result.error(Exception('Usuário não autenticado'));
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: firebaseUser.email!,
      );

      print('✅ Email de redefinição enviado para: ${firebaseUser.email}');
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao enviar email de redefinição: $e');
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao enviar email de redefinição: $e',
      ));
      return Result.error(Exception('Erro ao enviar email de redefinição: $e'));
    }
  }

  // Método para deletar conta
  Future<Result<void>> _deleteAccount() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser == null) {
        _updateState(_state.copyWith(
          errorMessage: 'Usuário não autenticado',
        ));
        return Result.error(Exception('Usuário não autenticado'));
      }

      // TODO: Implementar lógica de deleção no Supabase
      // Por enquanto, apenas deleta do Firebase
      await firebaseUser.delete();
      
      // Limpar UserManager
      UserManager.instance.clearUserData();

      print('✅ Conta deletada com sucesso');
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao deletar conta: $e');
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao deletar conta. Tente fazer login novamente: $e',
      ));
      return Result.error(Exception('Erro ao deletar conta: $e'));
    }
  }

  // Método para atualizar settings localmente
  Future<Result<void>> _updateSettings(ProfileSettings settings) async {
    _updateState(_state.copyWith(settings: settings));
    return Result.ok(null);
  }

  // Método auxiliar para atualizar estado
  void _updateState(ProfileSettingsState newState) {
    _state = newState;
    notifyListeners();
  }

  // Método para obter caminho da imagem de perfil
  String getProfileImagePath() {
    if (_state.selectedImagePath != null) {
      return _state.selectedImagePath!;
    }
    
    return _state.settings?.profileImagePath ?? 
           UserManager.instance.userPhotoUrl ?? 
           '';
  }

  // Método para construir avatar de fallback
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