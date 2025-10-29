// lib/services/email_verification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

/// Serviço para gerenciar verificação de email
class EmailVerificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// URL base das Edge Functions
  static const String _functionsUrl = 'https://mroljkgkiseuqlwlaibu.supabase.co/functions/v1';

  /// Envia email de verificação para o usuário
  /// 
  /// Parâmetros:
  /// - [userRef]: Firebase UID do usuário
  /// - [email]: Email do usuário
  /// - [nomeExibicao]: Nome de exibição do usuário
  /// 
  /// Retorna: true se enviado com sucesso, false caso contrário
  static Future<bool> sendVerificationEmail({
    required String userRef,
    required String email,
    required String nomeExibicao,
  }) async {
    try {
      print('📧 Enviando email de verificação para: $email');
      print('📧 UserRef: $userRef');
      print('📧 Nome: $nomeExibicao');

      final response = await _supabase.functions.invoke(
        'send-verification-email',
        body: {
          'userRef': userRef,
          'email': email,
          'nomeExibicao': nomeExibicao,
          'type': 'verification',
        },
      );

      print('📧 Status da resposta: ${response.status}');
      print('📧 Dados da resposta: ${response.data}');

      // Verificar se houve erro na resposta
      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['error'] != null) {
          print('❌ Erro no envio: ${data['error']}');
          return false;
        }
      }

      if (response.status == 200) {
        print('✅ Email de verificação enviado com sucesso!');
        return true;
      } else {
        print('❌ Erro ao enviar email: Status ${response.status}');
        print('Resposta completa: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao enviar email de verificação: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Envia email de boas-vindas para o usuário
  /// 
  /// Parâmetros:
  /// - [userRef]: Firebase UID do usuário
  /// - [email]: Email do usuário
  /// - [nomeExibicao]: Nome de exibição do usuário
  /// 
  /// Retorna: true se enviado com sucesso, false caso contrário
  static Future<bool> sendWelcomeEmail({
    required String userRef,
    required String email,
    required String nomeExibicao,
  }) async {
    try {
      print('🎉 Enviando email de boas-vindas para: $email');

      final response = await _supabase.functions.invoke(
        'send-verification-email',
        body: {
          'userRef': userRef,
          'email': email,
          'nomeExibicao': nomeExibicao,
          'type': 'welcome',
        },
      );

      if (response.status == 200) {
        print('✅ Email de boas-vindas enviado com sucesso!');
        return true;
      } else {
        print('❌ Erro ao enviar email: ${response.status}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao enviar email de boas-vindas: $e');
      return false;
    }
  }

  /// Verifica um email usando o token (versão simplificada)
  /// 
  /// Parâmetros:
  /// - [token]: Token de verificação recebido no email
  /// 
  /// Retorna: true se verificado com sucesso, false caso contrário
  static Future<bool> verifyEmail(String token) async {
    final result = await verifyEmailToken(token);
    return result['success'] == true;
  }

  /// Verifica um token de email (versão completa)
  /// 
  /// Parâmetros:
  /// - [token]: Token de verificação recebido no email
  /// 
  /// Retorna: Map com informações do resultado da verificação
  static Future<Map<String, dynamic>> verifyEmailToken(String token) async {
    try {
      print('🔍 Verificando token: $token');

      final response = await _supabase.functions.invoke(
        'verify-email-token',
        body: {
          'token': token,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        print('✅ Token verificado com sucesso!');
        return {
          'success': true,
          'message': data['message'] ?? 'Email verificado com sucesso!',
          'alreadyVerified': data['alreadyVerified'] ?? false,
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        print('❌ Erro ao verificar token: ${response.status}');
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao verificar token',
          'expired': data['expired'] ?? false,
        };
      }
    } catch (e) {
      print('❌ Erro ao verificar token: $e');
      return {
        'success': false,
        'message': 'Erro ao verificar token: $e',
      };
    }
  }

  /// Verifica se o email do usuário atual está verificado no banco
  /// 
  /// Retorna: true se verificado, false caso contrário
  static Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Nenhum usuário logado');
        return false;
      }

      final firebaseUid = user.uid;

      // Buscar status no banco
      final response = await _supabase
          .from('usuario_perfil')
          .select('email_verificado')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Usuário não encontrado no banco');
        return false;
      }

      final isVerified = response['email_verificado'] == true;
      print('📋 Email verificado: $isVerified');
      return isVerified;
    } catch (e) {
      print('❌ Erro ao verificar status do email: $e');
      return false;
    }
  }

  /// Reenvia email de verificação para o usuário atual
  /// 
  /// Retorna: true se reenviado com sucesso, false caso contrário
  static Future<bool> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ Nenhum usuário logado');
        return false;
      }

      // Buscar dados do usuário no banco
      final response = await _supabase
          .from('usuario_perfil')
          .select('email, nome_exibicao')
          .eq('ref', user.uid)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Usuário não encontrado no banco');
        return false;
      }

      final email = response['email'] ?? user.email;
      final nomeExibicao = response['nome_exibicao'] ?? 'Usuário';

      // Enviar novo email de verificação
      return await sendVerificationEmail(
        userRef: user.uid,
        email: email,
        nomeExibicao: nomeExibicao,
      );
    } catch (e) {
      print('❌ Erro ao reenviar email de verificação: $e');
      return false;
    }
  }

  /// Marca o email como verificado manualmente (uso administrativo)
  /// 
  /// Parâmetros:
  /// - [userRef]: Firebase UID do usuário
  /// 
  /// Retorna: true se marcado com sucesso, false caso contrário
  static Future<bool> markEmailAsVerified(String userRef) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('usuario_perfil')
          .update({
            'email_verificado': true,
            'atualizado_em': now,
          })
          .eq('ref', userRef);

      print('✅ Email marcado como verificado manualmente');
      return true;
    } catch (e) {
      print('❌ Erro ao marcar email como verificado: $e');
      return false;
    }
  }

  /// Busca informações de verificação do usuário
  /// 
  /// Parâmetros:
  /// - [userRef]: Firebase UID do usuário
  /// 
  /// Retorna: Map com informações de verificação ou null se não encontrado
  static Future<Map<String, dynamic>?> getVerificationInfo(String userRef) async {
    try {
      final response = await _supabase
          .from('email_verification')
          .select()
          .eq('user_ref', userRef)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Nenhuma verificação encontrada para o usuário');
        return null;
      }

      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erro ao buscar informações de verificação: $e');
      return null;
    }
  }
}