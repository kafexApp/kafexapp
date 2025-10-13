// lib/ui/create_account/viewmodel/create_account_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_profile_service.dart';
import '../../../utils/user_manager.dart';
import '../../../utils/validators/form_validator.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Criar conta com email e senha
  Future<CreateAccountResult> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) async {
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
        
        // Criar perfil no Supabase
        final bool profileCreated = await UserProfileService.createUserProfile(
          firebaseUid: firebaseUid,
          nomeExibicao: name.trim(),
          email: email.trim(),
          telefone: phone.trim(),
          fotoUrl: result.user?.photoURL,
        );

        if (profileCreated) {
          print('✅ Conta criada com sucesso: $name (UID: $firebaseUid)');
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