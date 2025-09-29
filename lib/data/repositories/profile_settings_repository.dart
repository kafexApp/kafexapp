import 'package:firebase_auth/firebase_auth.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/utils/user_manager.dart';

abstract class ProfileSettingsRepository {
  Future<Result<ProfileSettings>> loadUserSettings();
  Future<Result<void>> saveUserSettings(ProfileSettings settings);
  Future<Result<void>> resetPassword(String email);
  Future<Result<void>> deleteUserAccount();
}

class ProfileSettingsRepositoryImpl implements ProfileSettingsRepository {
  @override
  Future<Result<ProfileSettings>> loadUserSettings() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      final userManager = UserManager.instance;
      
      final settings = ProfileSettings(
        name: userManager.userName,
        username: _extractUsernameFromEmail(userManager.userEmail),
        email: userManager.userEmail,
        phone: '', // TODO: Carregar do Supabase
        address: '', // TODO: Carregar do Supabase
        profileImagePath: userManager.userPhotoUrl,
      );
      
      return Result.ok(settings);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar configurações: $e'));
    }
  }

  @override
  Future<Result<void>> saveUserSettings(ProfileSettings settings) async {
    try {
      // Simular delay de API
      await Future.delayed(Duration(seconds: 1));
      
      // Atualizar UserManager
      UserManager.instance.setUserData(
        name: settings.name,
        email: settings.email,
        photoUrl: settings.profileImagePath,
      );
      
      // TODO: Implementar salvamento no Supabase
      // - Salvar dados completos do usuário
      // - Upload da imagem se necessário
      // - Atualizar tabela de usuários
      
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
      
      // TODO: Excluir dados do Supabase antes de excluir conta do Firebase
      // - Excluir posts do usuário
      // - Excluir comentários
      // - Excluir favoritos
      // - Excluir dados do perfil
      
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