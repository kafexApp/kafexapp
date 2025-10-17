// lib/ui/complete_profile/viewmodel/complete_profile_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/username_service.dart';
import '../../../services/user_profile_service.dart';

class CompleteProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingUsernames = false;
  bool get isLoadingUsernames => _isLoadingUsernames;

  List<String> _usernameSuggestions = [];
  List<String> get usernameSuggestions => _usernameSuggestions;

  String? _selectedUsername;
  String? get selectedUsername => _selectedUsername;

  String? _customUsernameError;
  String? get customUsernameError => _customUsernameError;

  bool _isValidatingCustomUsername = false;
  bool get isValidatingCustomUsername => _isValidatingCustomUsername;

  // Gerar sugestões de username
  Future<void> generateUsernameSuggestions(String fullName) async {
    if (fullName.trim().length < 3) {
      _usernameSuggestions = [];
      _selectedUsername = null;
      notifyListeners();
      return;
    }

    _isLoadingUsernames = true;
    notifyListeners();

    try {
      final suggestions = await UsernameService.generateUsernameSuggestions(fullName);
      _usernameSuggestions = suggestions;
      
      if (suggestions.isNotEmpty) {
        _selectedUsername = suggestions.first;
      } else {
        _selectedUsername = null;
      }
    } catch (e) {
      print('Erro ao gerar sugestões: $e');
      _usernameSuggestions = [];
      _selectedUsername = null;
    } finally {
      _isLoadingUsernames = false;
      notifyListeners();
    }
  }

  // Selecionar username
  void selectUsername(String username) {
    _selectedUsername = username;
    _customUsernameError = null;
    notifyListeners();
  }

  // Validar username customizado
  Future<bool> validateCustomUsername(String username) async {
    _customUsernameError = null;
    
    if (username.isEmpty) {
      _customUsernameError = 'Digite um username';
      notifyListeners();
      return false;
    }

    if (username.length < 3) {
      _customUsernameError = 'Username deve ter pelo menos 3 caracteres';
      notifyListeners();
      return false;
    }

    if (username.length > 20) {
      _customUsernameError = 'Username deve ter no máximo 20 caracteres';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      _customUsernameError = 'Use apenas letras minúsculas, números e _';
      notifyListeners();
      return false;
    }

    _isValidatingCustomUsername = true;
    notifyListeners();

    try {
      final isAvailable = await UsernameService.isUsernameAvailable(username);
      
      if (!isAvailable) {
        _customUsernameError = 'Username já está em uso';
        _isValidatingCustomUsername = false;
        notifyListeners();
        return false;
      }

      _selectedUsername = username;
      _customUsernameError = null;
      _isValidatingCustomUsername = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _customUsernameError = 'Erro ao validar username';
      _isValidatingCustomUsername = false;
      notifyListeners();
      return false;
    }
  }

  // Completar perfil
  Future<bool> completeProfile({
    required String name,
    required String email,
  }) async {
    if (_selectedUsername == null || _selectedUsername!.isEmpty) {
      return false;
    }

    if (name.trim().isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Atualizar displayName no Firebase
      await user.updateDisplayName(name.trim());
      await user.reload();

      // Criar ou atualizar perfil no Supabase
      final success = await UserProfileService.createUserProfile(
        firebaseUid: user.uid,
        nomeExibicao: name.trim(),
        email: email.trim(),
        telefone: '',
        nomeUsuario: _selectedUsername!,
        fotoUrl: user.photoURL,
      );

      _isLoading = false;
      notifyListeners();
      return success;
      
    } catch (e) {
      print('❌ Erro ao completar perfil: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}