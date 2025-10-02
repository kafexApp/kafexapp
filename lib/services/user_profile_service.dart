// lib/services/user_profile_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../backend/supabase/supabase.dart';
import '../backend/supabase/tables/usuario_perfil.dart';
import '../utils/user_manager.dart';

class UserProfileService {
  static final _supabase = SupaClient.client;

  /// Busca o perfil do usuário no Supabase usando o ref do Firebase
  static Future<UsuarioPerfilRow?> getUserProfile(String firebaseUid) async {
    try {
      final response = await _supabase
          .from('usuario_perfil')
          .select()
          .eq('ref', firebaseUid)
          .single();

      if (response != null) {
        return UsuarioPerfilRow(response);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }

  /// Carrega os dados do usuário do Supabase e salva no UserManager
  static Future<void> loadAndSyncUserProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print('❌ Nenhum usuário logado no Firebase');
      return;
    }

    try {
      final profile = await getUserProfile(firebaseUser.uid);

      if (profile != null) {
        // Atualizar UserManager com dados do Supabase
        UserManager.instance.setUserData(
          name:
              profile.nomeExibicao ??
              firebaseUser.displayName ??
              'Usuário Kafex',
          email: profile.email ?? firebaseUser.email ?? '',
          photoUrl: profile.fotoUrl ?? firebaseUser.photoURL,
        );

        print('✅ Perfil carregado do Supabase: ${profile.nomeExibicao}');
      } else {
        // Se não encontrou no Supabase, usar dados do Firebase
        UserManager.instance.setUserData(
          name: firebaseUser.displayName ?? 'Usuário Kafex',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
        );

        print('⚠️ Perfil não encontrado no Supabase, usando Firebase');
      }
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
    }
  }

  /// Atualiza o perfil do usuário no Supabase
  static Future<bool> updateUserProfile({
    required String firebaseUid,
    String? nomeExibicao,
    String? telefone,
    String? fotoUrl,
    String? endereco,
    String? cidade,
    String? estado,
    String? bairro,
    String? cep,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (nomeExibicao != null) updates['nome_exibicao'] = nomeExibicao;
      if (telefone != null) updates['telefone'] = telefone;
      if (fotoUrl != null) updates['foto_url'] = fotoUrl;
      if (endereco != null) updates['endereco'] = endereco;
      if (cidade != null) updates['cidade'] = cidade;
      if (estado != null) updates['estado'] = estado;
      if (bairro != null) updates['bairro'] = bairro;
      if (cep != null) updates['cep'] = cep;

      await _supabase
          .from('usuario_perfil')
          .update(updates)
          .eq('ref', firebaseUid);

      print('✅ Perfil atualizado no Supabase');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      return false;
    }
  }
}
