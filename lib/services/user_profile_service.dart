// lib/services/user_profile_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../backend/supabase/supabase.dart';
import '../backend/supabase/tables/usuario_perfil.dart';
import '../utils/user_manager.dart';

class UserProfileService {
  static final _supabase = SupaClient.client;
  static final _storage = FirebaseStorage.instance;

  /// Busca o perfil do usuário no Supabase usando o ref do Firebase
  static Future<UsuarioPerfilRow?> getUserProfile(String firebaseUid) async {
    try {
      print('🔍 Buscando perfil do usuário: $firebaseUid');
      
      final response = await _supabase
          .from('usuario_perfil')
          .select()
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response != null) {
        print('✅ Perfil encontrado no Supabase');
        return UsuarioPerfilRow(response);
      }
      
      print('⚠️ Perfil não encontrado no Supabase');
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
          name: profile.nomeExibicao ?? firebaseUser.displayName ?? 'Usuário Kafex',
          email: profile.email ?? firebaseUser.email ?? '',
          photoUrl: profile.fotoUrl ?? firebaseUser.photoURL,
        );

        print('✅ Perfil carregado do Supabase: ${profile.nomeExibicao}');
      } else {
        // Se não encontrou no Supabase, criar perfil automaticamente
        final created = await _createUserProfileIfNotExists(firebaseUser);
        
        if (created) {
          print('✅ Novo perfil criado no Supabase');
          // Recarregar o perfil após criação
          await loadAndSyncUserProfile();
        } else {
          // Usar dados do Firebase como fallback
          UserManager.instance.setUserData(
            name: firebaseUser.displayName ?? 'Usuário Kafex',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL,
          );
          print('⚠️ Usando dados do Firebase como fallback');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
    }
  }

  /// Cria perfil do usuário no Supabase se não existir
  static Future<bool> _createUserProfileIfNotExists(User firebaseUser) async {
    try {
      print('👤 Criando perfil de usuário no Supabase...');

      final profileData = {
        'ref': firebaseUser.uid,
        'nome_exibicao': firebaseUser.displayName ?? 'Usuário Kafex',
        'email': firebaseUser.email,
        'foto_url': firebaseUser.photoURL,
        'ativo': true,
        'cadastro_completo': false,
        'criado_em': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('usuario_perfil')
          .insert(profileData)
          .select()
          .single();

      if (response != null) {
        print('✅ Perfil criado com sucesso: ${response['id']}');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Erro ao criar perfil de usuário: $e');
      return false;
    }
  }

  /// Atualiza o perfil do usuário no Supabase
  static Future<bool> updateUserProfile({
    required String firebaseUid,
    String? nomeExibicao,
    String? nomeUsuario,
    String? telefone,
    String? fotoUrl,
    String? endereco,
    String? cidade,
    String? estado,
    String? bairro,
    String? cep,
    String? cnpj,
    bool? profissional,
    bool? cadastroCompleto,
    // Redes sociais
    String? instagram,
    String? facebook,
    String? twitter,
    String? youtube,
    String? threads,
  }) async {
    try {
      print('💾 Atualizando perfil do usuário: $firebaseUid');

      // Verificar se o perfil existe
      final exists = await getUserProfile(firebaseUid);
      
      if (exists == null) {
        // Se não existe, criar primeiro
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await _createUserProfileIfNotExists(firebaseUser);
        }
      }

      // Montar objeto de atualização apenas com campos não nulos
      final updates = <String, dynamic>{};

      if (nomeExibicao != null) updates['nome_exibicao'] = nomeExibicao;
      if (nomeUsuario != null) updates['nome_usuario'] = nomeUsuario;
      if (telefone != null) updates['telefone'] = telefone;
      if (fotoUrl != null) updates['foto_url'] = fotoUrl;
      if (endereco != null) updates['endereco'] = endereco;
      if (cidade != null) updates['cidade'] = cidade;
      if (estado != null) updates['estado'] = estado;
      if (bairro != null) updates['bairro'] = bairro;
      if (cep != null) updates['cep'] = cep;
      if (cnpj != null) updates['cnpj'] = cnpj;
      if (profissional != null) updates['profissional'] = profissional;
      if (cadastroCompleto != null) updates['cadastro_completo'] = cadastroCompleto;
      if (instagram != null) updates['instagram'] = instagram;
      if (facebook != null) updates['facebook'] = facebook;
      if (twitter != null) updates['twitter'] = twitter;
      if (youtube != null) updates['youtube'] = youtube;
      if (threads != null) updates['threads'] = threads;

      if (updates.isEmpty) {
        print('⚠️ Nenhum campo para atualizar');
        return true;
      }

      print('📝 Campos sendo atualizados: ${updates.keys.join(", ")}');

      await _supabase
          .from('usuario_perfil')
          .update(updates)
          .eq('ref', firebaseUid);

      print('✅ Perfil atualizado no Supabase');
      
      // Recarregar dados no UserManager
      await loadAndSyncUserProfile();
      
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      return false;
    }
  }

  /// Faz upload da foto de perfil para o Firebase Storage
  static Future<String?> uploadProfilePhoto(XFile imageFile) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      print('📤 Fazendo upload da foto de perfil...');

      // Criar referência no Firebase Storage
      final fileName = 'profile_${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_photos/$fileName');

      // Fazer upload
      final uploadTask = await ref.putFile(File(imageFile.path));
      
      // Obter URL de download
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('✅ Foto de perfil enviada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro ao fazer upload da foto: $e');
      return null;
    }
  }

  /// Atualiza a foto de perfil do usuário
  static Future<bool> updateUserProfilePhoto(XFile imageFile) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ Usuário não autenticado');
        return false;
      }

      // Fazer upload da imagem
      final photoUrl = await uploadProfilePhoto(imageFile);
      
      if (photoUrl == null) {
        return false;
      }

      // Atualizar no Supabase
      final success = await updateUserProfile(
        firebaseUid: firebaseUser.uid,
        fotoUrl: photoUrl,
      );

      if (success) {
        // Atualizar no Firebase Auth também
        await firebaseUser.updatePhotoURL(photoUrl);
        print('✅ Foto de perfil atualizada com sucesso');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Erro ao atualizar foto de perfil: $e');
      return false;
    }
  }

  /// Verifica se o usuário tem foto de perfil
  static Future<bool> hasProfilePhoto() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;

    final profile = await getUserProfile(firebaseUser.uid);
    return profile?.fotoUrl != null && profile!.fotoUrl!.isNotEmpty;
  }

  /// Deleta a foto de perfil do usuário
  static Future<bool> deleteProfilePhoto() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ Usuário não autenticado');
        return false;
      }

      // Atualizar no Supabase (remover URL)
      final success = await updateUserProfile(
        firebaseUid: firebaseUser.uid,
        fotoUrl: '',
      );

      if (success) {
        // Remover do Firebase Auth também
        await firebaseUser.updatePhotoURL(null);
        print('✅ Foto de perfil removida com sucesso');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Erro ao remover foto de perfil: $e');
      return false;
    }
  }

  /// Marca o cadastro como completo
  static Future<bool> markProfileAsComplete() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return false;

      return await updateUserProfile(
        firebaseUid: firebaseUser.uid,
        cadastroCompleto: true,
      );
    } catch (e) {
      print('❌ Erro ao marcar cadastro como completo: $e');
      return false;
    }
  }

  /// Verifica se o cadastro está completo
  static Future<bool> isProfileComplete() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;

    final profile = await getUserProfile(firebaseUser.uid);
    return profile?.cadastroCompleto ?? false;
  }

  /// Atualiza as redes sociais do usuário
  static Future<bool> updateSocialMedia({
    required String firebaseUid,
    String? instagram,
    String? facebook,
    String? twitter,
    String? youtube,
    String? threads,
  }) async {
    return await updateUserProfile(
      firebaseUid: firebaseUid,
      instagram: instagram,
      facebook: facebook,
      twitter: twitter,
      youtube: youtube,
      threads: threads,
    );
  }
}