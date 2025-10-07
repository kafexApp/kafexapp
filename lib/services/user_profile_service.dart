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

        print('✅ Perfil carregado do Supabase:');
        print('   ID: ${profile.id}');
        print('   Nome: ${profile.nomeExibicao}');
        print('   Email: ${profile.email}');
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
      final Map<String, dynamic> updateData = {};

      if (nomeExibicao != null) updateData['nome_exibicao'] = nomeExibicao;
      if (telefone != null) updateData['telefone'] = telefone;
      if (fotoUrl != null) updateData['foto_url'] = fotoUrl;
      if (endereco != null) updateData['endereco'] = endereco;
      if (cidade != null) updateData['cidade'] = cidade;
      if (estado != null) updateData['estado'] = estado;
      if (bairro != null) updateData['bairro'] = bairro;
      if (cep != null) updateData['cep'] = cep;

      if (updateData.isEmpty) {
        print('⚠️ Nenhum dado para atualizar');
        return false;
      }

      await _supabase
          .from('usuario_perfil')
          .update(updateData)
          .eq('ref', firebaseUid);

      print('✅ Perfil atualizado no Supabase');

      // Recarregar perfil para atualizar UserManager com dados atualizados
      await loadAndSyncUserProfile();

      return true;
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      return false;
    }
  }

  /// Busca o user_id (ID numérico) do usuário no Supabase pelo Firebase UID
  static Future<int?> getUserId(String firebaseUid) async {
    try {
      final response = await _supabase
          .from('usuario_perfil')
          .select('id')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response != null) {
        return response['id'] as int?;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      return null;
    }
  }

  /// Busca o user_id do usuário atualmente logado
  static Future<int?> getCurrentUserId() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print('❌ Nenhum usuário logado no Firebase');
      return null;
    }

    return await getUserId(firebaseUser.uid);
  }
}
