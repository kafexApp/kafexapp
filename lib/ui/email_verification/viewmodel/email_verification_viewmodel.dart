// lib/ui/email_verification/viewmodel/email_verification_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  String? get errorMessage => _errorMessage;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown == 0 && !_isResending;

  /// Envia o email de verificação
  Future<bool> sendVerificationEmail() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      
      if (user == null) {
        _errorMessage = 'Usuário não encontrado. Faça login novamente.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await user.sendEmailVerification();
      
      print('✅ Email de verificação enviado para: ${user.email}');
      
      _isLoading = false;
      _startResendCountdown();
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erro ao enviar email: ${e.code}');
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Erro inesperado: $e');
      _errorMessage = 'Erro ao enviar email. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verifica se o email foi confirmado
  Future<bool> checkEmailVerified() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      
      if (user == null) {
        _errorMessage = 'Usuário não encontrado.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Recarrega os dados do usuário do Firebase
      await user.reload();
      
      // Pega o usuário atualizado
      final refreshedUser = _auth.currentUser;
      
      if (refreshedUser == null) {
        _errorMessage = 'Erro ao verificar status.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isVerified = refreshedUser.emailVerified;
      
      print('📧 Email verificado: $isVerified');
      
      if (!isVerified) {
        _errorMessage = 'Email ainda não foi verificado. Verifique sua caixa de entrada.';
      }
      
      _isLoading = false;
      notifyListeners();
      return isVerified;
      
    } catch (e) {
      print('❌ Erro ao verificar email: $e');
      _errorMessage = 'Erro ao verificar email. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reenvia o email de verificação
  Future<bool> resendVerificationEmail() async {
    if (!canResend) return false;
    
    try {
      _isResending = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      
      if (user == null) {
        _errorMessage = 'Usuário não encontrado.';
        _isResending = false;
        notifyListeners();
        return false;
      }

      await user.sendEmailVerification();
      
      print('✅ Email de verificação reenviado');
      
      _isResending = false;
      _startResendCountdown();
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('❌ Erro ao reenviar email: ${e.code}');
      _errorMessage = _getErrorMessage(e.code);
      _isResending = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Erro inesperado: $e');
      _errorMessage = 'Erro ao reenviar email.';
      _isResending = false;
      notifyListeners();
      return false;
    }
  }

  /// Inicia contagem regressiva para reenvio (60 segundos)
  void _startResendCountdown() {
    _resendCountdown = 60;
    notifyListeners();
    
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtém mensagem de erro amigável
  String _getErrorMessage(String code) {
    switch (code) {
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro ao processar. Tente novamente.';
    }
  }

  /// Obtém email do usuário atual
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  @override
  void dispose() {
    super.dispose();
  }
}