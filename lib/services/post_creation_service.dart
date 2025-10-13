// lib/services/post_creation_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Erro: Usuário não autenticado');
        return false;
      }

      final firebaseUid = currentUser.uid;
      final userEmail = currentUser.email ?? '';

      String authorName = 'Usuário';
      String? authorAvatar;

      authorName =
          currentUser.displayName ??
          currentUser.email?.split('@')[0] ??
          'Usuário';
      authorAvatar = currentUser.photoURL;

      final userId = await _ensureUserProfileExists(
        firebaseUid,
        userEmail,
        authorName,
        authorAvatar,
      );

      if (userId == null) {
        print('❌ Erro: Não foi possível obter o user_id');
        return false;
      }

      final postData = {
        'descricao': description.trim(),
        'criado_em': DateTime.now().toIso8601String(),
        'tipo': 'tradicional',
        'usuario_uid': firebaseUid,
        'nome_usuario': authorName,
        'user_id': userId,
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        postData['url_foto'] = imageUrl;
        print('📷 Salvando URL da imagem no post: $imageUrl');
      }

      if (videoUrl != null && videoUrl.isNotEmpty) {
        postData['url_video'] = videoUrl;
        print('🎥 Salvando URL do vídeo no post: $videoUrl');
      }

      if (externalLink != null && externalLink.isNotEmpty) {
        postData['url_externa'] = externalLink;
      }

      print('📝 Criando post com dados:');
      print('   Nome: $authorName');
      print('   Firebase UID: $firebaseUid');
      print('   Email: $userEmail');
      print('   Avatar: $authorAvatar');
      print('   User ID: $userId');

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
    String firebaseUid,
    String userEmail,
    String userName,
    String? userAvatar,
  ) async {
    try {
      print('🔍 Verificando se usuário existe na tabela usuario_perfil...');

      if (userAvatar == null || userAvatar.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          userAvatar = currentUser.photoURL;
        }
      }

      final existingUser = await SupaClient.client
          .from('usuario_perfil')
          .select('id, nome_exibicao, foto_url, email')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (existingUser != null) {
        print('✅ Usuário encontrado com ID: ${existingUser['id']}');

        final existingName = existingUser['nome_exibicao'];
        final existingPhotoUrl = existingUser['foto_url'];
        final existingEmail = existingUser['email'];

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
              .eq('ref', firebaseUid);

          print('✅ Dados do usuário atualizados');
        } else {
          print('ℹ️ Dados do usuário já estão atualizados');
        }

        return existingUser['id'] as int;
      } else {
        print('ℹ️ Usuário não encontrado, criando novo registro...');

        final newUser = await SupaClient.client
            .from('usuario_perfil')
            .insert({
              'ref': firebaseUid,
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

  /// Upload de imagem usando Firebase Storage (funciona em Android, iOS e Web)
  static Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      print('📷 Iniciando upload de imagem via Firebase Storage...');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'posts/${user.uid}/$timestamp.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      print('📤 Fazendo upload para: $fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // WEB: Usa bytes ao invés de File
        print('🌐 Modo Web detectado - usando bytes');
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // MOBILE: Usa File normalmente
        print('📱 Modo Mobile detectado - usando File');
        uploadTask = storageRef.putFile(File(imageFile.path));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload concluído! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro no upload de imagem: $e');
      return null;
    }
  }

  /// Upload de vídeo usando Firebase Storage (funciona em Android, iOS e Web)
  static Future<String?> uploadVideoFromXFile(XFile videoFile) async {
    try {
      print('🎥 Iniciando upload de vídeo via Firebase Storage...');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'videos/${user.uid}/$timestamp.mp4';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      print('📤 Fazendo upload de vídeo para: $fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // WEB: Usa bytes ao invés de File
        print('🌐 Modo Web detectado - usando bytes');
        final bytes = await videoFile.readAsBytes();
        uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'video/mp4'),
        );
      } else {
        // MOBILE: Usa File normalmente
        print('📱 Modo Mobile detectado - usando File');
        uploadTask = storageRef.putFile(File(videoFile.path));
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload de vídeo concluído! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro no upload de vídeo: $e');
      return null;
    }
  }
}