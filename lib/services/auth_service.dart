// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Usuário atual
  User? get currentUser => _auth.currentUser;
  
  // Stream para escutar mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar se usuário está logado
  bool get isLoggedIn => currentUser != null;

  // **RECUPERAR SENHA - NOVO MÉTODO**
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      print('📧 Enviando email de recuperação para: $email');
      
      await _auth.sendPasswordResetEmail(email: email);
      
      print('✅ Email de recuperação enviado com sucesso!');
      return {
        'success': true,
        'message': 'Email de recuperação enviado com sucesso!'
      };
    } on FirebaseAuthException catch (e) {
      print('❌ Erro ao enviar email de recuperação: ${e.code}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado. Verifique o email digitado.';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido. Verifique o formato do email.';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente em alguns minutos.';
          break;
        default:
          errorMessage = 'Erro inesperado: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return {
        'success': false,
        'message': 'Erro de conexão. Verifique sua internet e tente novamente.'
      };
    }
  }

  // **VALIDAR EMAIL - NOVO MÉTODO**
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // **LOGIN COM EMAIL E SENHA**
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Fazendo login: $email');
      
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login realizado com sucesso!');
      return AuthResult.success(result.user);
    } on FirebaseAuthException catch (e) {
      print('❌ Erro no login: ${e.code}');
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return AuthResult.error('Erro inesperado. Tente novamente.');
    }
  }

  // **LOGIN COM GOOGLE**
  Future<AuthResult> signInWithGoogle() async {
    try {
      print('🔍 Iniciando login com Google...');

      if (kIsWeb) {
        // Web: usar provider direto
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential result = await _auth.signInWithPopup(googleProvider);
        print('✅ Login Google Web realizado com sucesso!');
        return AuthResult.success(result.user);
      } else {
        // Mobile: usar GoogleSignIn
        
        // Fazer logout primeiro para garantir que o popup apareça
        await _googleSignIn.signOut();
        
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          print('⚠️ Login cancelado pelo usuário');
          return AuthResult.error('Login cancelado pelo usuário');
        }

        print('📱 Usuário Google selecionado: ${googleUser.email}');

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        print('🔑 Tokens obtidos - AccessToken: ${googleAuth.accessToken != null}, IdToken: ${googleAuth.idToken != null}');

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result = await _auth.signInWithCredential(credential);
        print('✅ Login Google Mobile realizado com sucesso!');
        return AuthResult.success(result.user);
      }
    } catch (e) {
      print('❌ Erro no login Google: $e');
      return AuthResult.error('Erro ao fazer login com Google: $e');
    }
  }

  // **LOGIN COM APPLE** (apenas iOS/macOS/Web)
  Future<AuthResult> signInWithApple() async {
    try {
      // Verificação corrigida para iOS
      if (!kIsWeb) {
        try {
          if (!Platform.isIOS && !Platform.isMacOS) {
            return AuthResult.error('Login com Apple só está disponível em iOS, macOS e Web');
          }
        } catch (e) {
          // Se der erro ao verificar Platform, continua (pode ser simulador)
          print('⚠️ Aviso ao verificar plataforma: $e');
        }
      }

      print('🍎 Iniciando login com Apple...');
      
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential result = await _auth.signInWithCredential(oauthCredential);
      
      // Se for primeiro login, atualizar nome
      if (result.additionalUserInfo?.isNewUser == true) {
        String? firstName = appleCredential.givenName;
        String? lastName = appleCredential.familyName;
        if (firstName != null && lastName != null) {
          await result.user?.updateDisplayName('$firstName $lastName');
        }
      }

      print('✅ Login Apple realizado com sucesso!');
      return AuthResult.success(result.user);
    } catch (e) {
      print('❌ Erro no login Apple: $e');
      return AuthResult.error('Erro ao fazer login com Apple: $e');
    }
  }

  // **LOGOUT**
  Future<void> signOut() async {
    try {
      print('👋 Fazendo logout...');
      
      // Verificar se o usuário está logado com Google antes de tentar logout
      final user = _auth.currentUser;
      if (user != null) {
        // Verificar se o provedor é Google
        final providerData = user.providerData;
        final isGoogleUser = providerData.any((info) => info.providerId == 'google.com');
        
        if (isGoogleUser && !kIsWeb) {
          // Só tenta logout do Google no mobile
          try {
            if (await _googleSignIn.isSignedIn()) {
              await _googleSignIn.signOut();
            }
          } catch (e) {
            print('⚠️ Aviso ao fazer logout do Google: $e');
          }
        }
      }
      
      // Logout do Firebase
      await _auth.signOut();
      
      print('✅ Logout realizado com sucesso!');
    } catch (e) {
      print('❌ Erro no logout: $e');
      rethrow;
    }
  }

  // Converter códigos de erro em mensagens amigáveis
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta conta foi desabilitada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'invalid-credential':
        return 'Email ou senha incorretos';
      default:
        return 'Erro desconhecido. Tente novamente';
    }
  }
}

// Classe para resultado das operações de autenticação
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;
  final String? successMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      successMessage: message,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}