// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Usuário atual
  User? get currentUser => _auth.currentUser;
  
  // Stream para escutar mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar se usuário está logado
  bool get isLoggedIn => currentUser != null;

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
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          return AuthResult.error('Login cancelado pelo usuário');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
      return AuthResult.error('Erro ao fazer login com Google. Tente novamente.');
    }
  }

  // **LOGIN COM APPLE** (apenas iOS/macOS/Web)
  Future<AuthResult> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS && !kIsWeb) {
        return AuthResult.error('Login com Apple só está disponível em iOS, macOS e Web');
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
      return AuthResult.error('Erro ao fazer login com Apple. Tente novamente.');
    }
  }

  // **LOGOUT**
  Future<void> signOut() async {
    try {
      print('👋 Fazendo logout...');
      
      // Logout do Google se estiver logado
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Logout do Firebase
      await _auth.signOut();
      
      print('✅ Logout realizado com sucesso!');
    } catch (e) {
      print('❌ Erro no logout: $e');
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