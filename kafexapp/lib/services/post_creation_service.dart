// lib/services/post_creation_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../backend/supabase/supabase.dart';
import 'dart:io';

class PostCreationService {
  /// Cria um novo post tradicional no feed
  static Future<bool> createTraditionalPost({
    required String description,
    String? imageUrl,
    String? videoUrl,
    String? externalLink,
  }) async {
    try {
      // CORREÇÃO: Usar Firebase Auth ao invés de Supabase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Erro: Usuário não autenticado');
        return false;
      }

      // CORREÇÃO: Usar o Firebase UID ao invés do email
      final firebaseUid = currentUser.uid; // Firebase UID (ref)
      final userEmail = currentUser.email ?? '';

      String authorName = 'Usuário';
      String? authorAvatar;

      // Tentar obter nome e foto do Firebase Auth
      authorName =
          currentUser.displayName ??
          currentUser.email?.split('@')[0] ??
          'Usuário';
      authorAvatar = currentUser.photoURL;

      // Primeiro, verificar se o usuário existe na tabela usuario_perfil e obter o user_id
      final userId = await _ensureUserProfileExists(
        firebaseUid, // CORREÇÃO: Passar o UID ao invés do email
        userEmail,
        authorName,
        authorAvatar,
      );

      if (userId == null) {
        print('❌ Erro: Não foi possível obter o user_id');
        return false;
      }

      // Criar o post na tabela feed
      final postData = {
        'descricao': description.trim(),
        'criado_em': DateTime.now().toIso8601String(),
        'tipo': 'tradicional',
        'usuario_uid': firebaseUid, // CORREÇÃO: Salvar Firebase UID (ref)
        'nome_usuario': authorName,
        'user_id': userId, // ID numérico da tabela usuario_perfil
      };

      // Adiciona URL da imagem se fornecida
      if (imageUrl != null && imageUrl.isNotEmpty) {
        postData['url_foto'] = imageUrl;
        print('📷 Salvando URL da imagem no post: $imageUrl');
      }

      // Adiciona URL do vídeo se fornecida
      if (videoUrl != null && videoUrl.isNotEmpty) {
        postData['url_video'] = videoUrl;
        print('🎥 Salvando URL do vídeo no post: $videoUrl');
      }

      // Adiciona URL externa se fornecida
      if (externalLink != null && externalLink.isNotEmpty) {
        postData['url_externa'] = externalLink;
      }

      print('📝 Criando post com dados:');
      print('   Nome: $authorName');
      print('   Firebase UID: $firebaseUid'); // CORREÇÃO: Log do UID
      print('   Email: $userEmail');
      print('   Avatar: $authorAvatar');
      print('   User ID: $userId');

      // Insere na tabela FEED
      final response = await SupaClient.client
          .from('feed')
          .insert(postData)
          .select();

      if (response != null && response.isNotEmpty) {
        print('✅ Post criado com sucesso: ${response.first['id']}');
        return true;
      } else {
        print('❌ Erro: Resposta vazia do Supabase');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao criar post: $e');
      return false;
    }
  }

  /// Garante que o usuário existe na tabela usuario_perfil e retorna o user_id
  static Future<int?> _ensureUserProfileExists(
    String firebaseUid, // CORREÇÃO: Receber Firebase UID
    String userEmail,
    String userName,
    String? userAvatar,
  ) async {
    try {
      print('🔍 Verificando se usuário existe na tabela usuario_perfil...');

      // Tentar obter foto do Firebase Auth se não tiver uma
      if (userAvatar == null || userAvatar.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          userAvatar = currentUser.photoURL;
        }
      }

      // CORREÇÃO: Verificar se usuário já existe pela REF (Firebase UID)
      final existingUser = await SupaClient.client
          .from('usuario_perfil')
          .select('id, nome_exibicao, foto_url, email')
          .eq('ref', firebaseUid) // CORREÇÃO: Buscar por ref, não por email
          .maybeSingle();

      if (existingUser != null) {
        print('✅ Usuário encontrado com ID: ${existingUser['id']}');

        // Verificar se precisa atualizar os dados
        final existingName = existingUser['nome_exibicao'];
        final existingPhotoUrl = existingUser['foto_url'];
        final existingEmail = existingUser['email'];

        // Atualiza se o nome, email ou foto mudaram
        final shouldUpdate =
            existingName != userName ||
            existingEmail != userEmail ||
            (existingPhotoUrl == null && userAvatar != null) ||
            (existingPhotoUrl != userAvatar && userAvatar != null);

        if (shouldUpdate) {
          await SupaClient.client
              .from('usuario_perfil')
              .update({
                'nome_exibicao': userName,
                'email': userEmail,
                'foto_url': userAvatar,
              })
              .eq('ref', firebaseUid); // CORREÇÃO: Atualizar por ref

          print('✅ Dados do usuário atualizados');
        } else {
          print('ℹ️ Dados do usuário já estão atualizados');
        }

        // Retorna o ID do usuário existente
        return existingUser['id'] as int;
      } else {
        // Usuário não existe, criar novo
        print('ℹ️ Usuário não encontrado, criando novo registro...');

        final newUser = await SupaClient.client
            .from('usuario_perfil')
            .insert({
              'ref': firebaseUid, // CORREÇÃO: Salvar Firebase UID na ref
              'email': userEmail,
              'nome_exibicao': userName,
              'foto_url': userAvatar,
              'nome_usuario': userName.toLowerCase().replaceAll(' ', '_'),
            })
            .select('id')
            .single();

        print('✅ Novo usuário criado com ID: ${newUser['id']}');
        return newUser['id'] as int;
      }
    } catch (e) {
      print('⚠️ Erro ao verificar/criar perfil de usuário: $e');
      return null;
    }
  }

  /// Upload de imagem usando Firebase Storage
  static Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      print('📷 Iniciando upload de imagem via Firebase Storage...');

      // Obter referência do usuário
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      // Criar referência única no Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'posts/${user.uid}/$timestamp.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      print('📤 Fazendo upload para: $fileName');

      // Fazer upload
      final uploadTask = await storageRef.putFile(File(imageFile.path));

      // Obter URL de download
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Upload concluído! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro no upload de imagem: $e');
      return null;
    }
  }

  /// Upload de vídeo usando Firebase Storage
  static Future<String?> uploadVideoFromXFile(XFile videoFile) async {
    try {
      print('🎥 Iniciando upload de vídeo via Firebase Storage...');

      // Obter referência do usuário
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      // Criar referência única no Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'videos/${user.uid}/$timestamp.mp4';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      print('📤 Fazendo upload de vídeo para: $fileName');

      // Fazer upload
      final uploadTask = await storageRef.putFile(File(videoFile.path));

      // Obter URL de download
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Upload de vídeo concluído! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro no upload de vídeo: $e');
      return null;
    }
  }
}
