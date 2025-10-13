// lib/ui/create_account/viewmodel/create_account_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_profile_service.dart';
import '../../../services/username_service.dart';
import '../../../utils/user_manager.dart';
import '../../../utils/validators/form_validator.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
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

  // Gerar sugestões de username baseado no nome
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
      
      // Seleciona automaticamente o primeiro username se houver sugestões
      if (suggestions.isNotEmpty) {
        _selectedUsername = suggestions.first;
      } else {
        _selectedUsername = null;
      }
    } catch (e) {
      print('Erro ao gerar sugestões de username: $e');
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

  // Limpar sugestões
  void clearUsernameSuggestions() {
    _usernameSuggestions = [];
    _selectedUsername = null;
    _customUsernameError = null;
    notifyListeners();
  }

  // Validar username customizado
  Future<bool> validateCustomUsername(String username) async {
    _customUsernameError = null;
    
    // Validações básicas
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

    // Apenas letras minúsculas, números e underscore
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      _customUsernameError = 'Use apenas letras minúsculas, números e _';
      notifyListeners();
      return false;
    }

    _isValidatingCustomUsername = true;
    notifyListeners();

    try {
      // Verificar disponibilidade no banco
      final isAvailable = await UsernameService.isUsernameAvailable(username);
      
      if (!isAvailable) {
        _customUsernameError = 'Username já está em uso';
        _isValidatingCustomUsername = false;
        notifyListeners();
        return false;
      }

      // Username válido e disponível
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

  // Limpar erro de username customizado
  void clearCustomUsernameError() {
    _customUsernameError = null;
    notifyListeners();
  }

  // Criar conta com email e senha
  Future<CreateAccountResult> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) async {
    // Validar se username foi selecionado
    if (_selectedUsername == null || _selectedUsername!.isEmpty) {
      return CreateAccountResult(
        success: false,
        errorMessage: 'Por favor, selecione um username',
      );
    }

    // Validar formulário
    final validationResults = FormValidator.validateCreateAccountForm(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      termsAccepted: termsAccepted,
    );

    if (!FormValidator.isFormValid(validationResults)) {
      final errorMessage = FormValidator.getFirstError(validationResults);
      return CreateAccountResult(
        success: false,
        errorMessage: errorMessage ?? 'Erro na validação',
      );
    }

    _setLoading(true);

    try {
      // Criar conta no Firebase
      final UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Atualizar displayName
        await result.user!.updateDisplayName(name.trim());
        await result.user!.reload();
        
        final String firebaseUid = result.user!.uid;
        
        // Criar perfil no Supabase com username
        final bool profileCreated = await UserProfileService.createUserProfile(
          firebaseUid: firebaseUid,
          nomeExibicao: name.trim(),
          email: email.trim(),
          telefone: phone.trim(),
          nomeUsuario: _selectedUsername!,
          fotoUrl: result.user?.photoURL,
        );

        if (profileCreated) {
          print('✅ Conta criada com sucesso: $name (@$_selectedUsername) (UID: $firebaseUid)');
          _setLoading(false);
          return CreateAccountResult(
            success: true,
            successMessage: 'Conta criada com sucesso!',
          );
        } else {
          // Deletar conta do Firebase se falhar no Supabase
          await result.user!.delete();
          _setLoading(false);
          return CreateAccountResult(
            success: false,
            errorMessage: 'Erro ao criar perfil no banco de dados',
          );
        }
      }

      _setLoading(false);
      return CreateAccountResult(
        success: false,
        errorMessage: 'Erro ao criar conta',
      );
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return CreateAccountResult(
        success: false,
        errorMessage: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      _setLoading(false);
      return CreateAccountResult(
        success: false,
        errorMessage: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  // Login com Google
  Future<CreateAccountResult> signInWithGoogle() async {
    _setLoading(true);

    try {
      final result = await _authService.signInWithGoogle();

      if (result.isSuccess && result.user != null) {
        final String firebaseUid = result.user!.uid;
        final String email = result.user?.email ?? 'usuario@gmail.com';
        final String name = result.user?.displayName ?? 
                           UserManager.instance.extractNameFromEmail(email);
        
        // Verificar se perfil já existe
        final existingProfile = await UserProfileService.getUserProfile(firebaseUid);
        
        if (existingProfile == null) {
          // Criar perfil para novos usuários
          await UserProfileService.createUserProfile(
            firebaseUid: firebaseUid,
            nomeExibicao: name,
            email: email,
            telefone: '',
            fotoUrl: result.user?.photoURL,
          );
        } else {
          // Carregar perfil existente
          await UserProfileService.loadAndSyncUserProfile();
        }
        
        print('✅ Login Google: $name (UID: $firebaseUid)');
        _setLoading(false);
        
        return CreateAccountResult(
          success: true,
          successMessage: 'Login com Google realizado com sucesso!',
        );
      } else {
        _setLoading(false);
        return CreateAccountResult(
          success: false,
          errorMessage: result.errorMessage ?? 'Erro no login com Google',
        );
      }
    } catch (e) {
      _setLoading(false);
      return CreateAccountResult(
        success: false,
        errorMessage: 'Erro no login com Google: ${e.toString()}',
      );
    }
  }

  // Login com Apple
  Future<CreateAccountResult> signInWithApple() async {
    _setLoading(true);

    try {
      final result = await _authService.signInWithApple();

      if (result.isSuccess && result.user != null) {
        final String firebaseUid = result.user!.uid;
        final String email = result.user?.email ?? 'usuario@icloud.com';
        final String name = result.user?.displayName ?? 
                           UserManager.instance.extractNameFromEmail(email);
        
        // Verificar se perfil já existe
        final existingProfile = await UserProfileService.getUserProfile(firebaseUid);
        
        if (existingProfile == null) {
          // Criar perfil para novos usuários
          await UserProfileService.createUserProfile(
            firebaseUid: firebaseUid,
            nomeExibicao: name,
            email: email,
            telefone: '',
            fotoUrl: result.user?.photoURL,
          );
        } else {
          // Carregar perfil existente
          await UserProfileService.loadAndSyncUserProfile();
        }
        
        print('✅ Login Apple: $name (UID: $firebaseUid)');
        _setLoading(false);
        
        return CreateAccountResult(
          success: true,
          successMessage: 'Login com Apple realizado com sucesso!',
        );
      } else {
        _setLoading(false);
        return CreateAccountResult(
          success: false,
          errorMessage: result.errorMessage ?? 'Erro no login com Apple',
        );
      }
    } catch (e) {
      _setLoading(false);
      return CreateAccountResult(
        success: false,
        errorMessage: 'Erro no login com Apple: ${e.toString()}',
      );
    }
  }

  // Métodos auxiliares
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      default:
        return 'Erro desconhecido: $errorCode';
    }
  }
}

// Classe de resultado
class CreateAccountResult {
  final bool success;
  final String? successMessage;
  final String? errorMessage;

  CreateAccountResult({
    required this.success,
    this.successMessage,
    this.errorMessage,
  });
}