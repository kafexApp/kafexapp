import 'package:firebase_auth/firebase_auth.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/utils/user_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileSettingsRepository {
  Future<Result<ProfileSettings>> loadUserSettings();
  Future<Result<void>> saveUserSettings(ProfileSettings settings);
  Future<Result<void>> resetPassword(String email);
  Future<Result<void>> deleteUserAccount();
}

class ProfileSettingsRepositoryImpl implements ProfileSettingsRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<Result<ProfileSettings>> loadUserSettings() async {
    try {
      final userManager = UserManager.instance;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Buscar dados do Supabase
      final response = await _supabase
          .from('usuario_perfil')
          .select()
          .eq('ref', userId)
          .single();

      final settings = ProfileSettings.fromSupabase(response);
      
      return Result.ok(settings);
    } catch (e) {
      // Se não encontrar no Supabase, retorna dados básicos do Firebase
      try {
        final userManager = UserManager.instance;
        
        final settings = ProfileSettings(
          nomeExibicao: userManager.userName,
          nomeUsuario: _extractUsernameFromEmail(userManager.userEmail),
          email: userManager.userEmail,
          fotoUrl: userManager.userPhotoUrl,
        );
        
        return Result.ok(settings);
      } catch (e) {
        return Result.error(Exception('Erro ao carregar configurações: $e'));
      }
    }
  }

  @override
  Future<Result<void>> saveUserSettings(ProfileSettings settings) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (userId == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Verificar se o usuário já existe
      final existing = await _supabase
          .from('usuario_perfil')
          .select('id')
          .eq('ref', userId)
          .maybeSingle();

      final data = settings.toSupabase();
      data['ref'] = userId;

      if (existing != null) {
        // Atualizar registro existente
        await _supabase
            .from('usuario_perfil')
            .update(data)
            .eq('ref', userId);
      } else {
        // Criar novo registro
        await _supabase
            .from('usuario_perfil')
            .insert(data);
      }

      // Atualizar UserManager
      final userManager = UserManager.instance;
      userManager.setUserData(
        uid: userId,
        name: settings.nomeExibicao,
        email: settings.email,
        photoUrl: settings.fotoUrl,
      );
      
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao salvar configurações: $e'));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao enviar email de redefinição';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        case 'network-request-failed':
          errorMessage = 'Erro de conexão. Verifique sua internet';
          break;
        case 'unauthorized-continue-uri':
          errorMessage = 'Configuração de domínio pendente. Tente novamente em alguns minutos';
          break;
        default:
          errorMessage = 'Erro ao enviar email: ${e.message}';
      }
      
      return Result.error(Exception(errorMessage));
    } catch (e) {
      return Result.error(Exception('Erro inesperado ao enviar email: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUserAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        return Result.error(Exception('Usuário não encontrado'));
      }

      // Excluir dados do Supabase
      await _supabase
          .from('usuario_perfil')
          .delete()
          .eq('ref', user.uid);
      
      // Excluir conta do Firebase
      await user.delete();
      
      // Limpar dados locais
      UserManager.instance.clearUserData();
      
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao excluir conta';
      
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Para sua segurança, faça login novamente antes de excluir a conta';
          break;
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado';
          break;
        default:
          errorMessage = 'Erro ao excluir conta: ${e.message}';
      }
      
      return Result.error(Exception(errorMessage));
    } catch (e) {
      return Result.error(Exception('Erro inesperado ao excluir conta: $e'));
    }
  }

  String _extractUsernameFromEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0].replaceAll('.', '_');
    }
    return email;
  }
}