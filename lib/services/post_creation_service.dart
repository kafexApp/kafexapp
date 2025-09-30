// lib/services/post_creation_service.dart
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';
import '../utils/user_manager.dart';
import 'firebase_storage_service.dart';

class PostCreationService {
  /// Cria um novo post no feed com suporte a imagens e vídeos
  static Future<bool> createPost({
    required String description,
    String? imageUrl,
    String? videoUrl,
    String? externalLink,
  }) async {
    try {
      final userManager = UserManager.instance;
      
      // Usa os nomes corretos das colunas da tabela FEED
      final postData = {
        'descricao': description.trim(),
        'criado_em': DateTime.now().toIso8601String(),
        'tipo': 'tradicional',
        'usuario_uid': userManager.userEmail, // uid do usuário para relacionar
      };

      // Adiciona URL da imagem se fornecida (campo url_foto)
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

      print('📝 Criando post na tabela FEED: $postData');

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

  /// Upload de imagem usando Firebase Storage
  static Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      print('📷 Iniciando upload de imagem via Firebase Storage...');
      final result = await FirebaseStorageService.uploadImageFromXFile(imageFile);
      if (result != null) {
        print('✅ Upload de imagem concluído: $result');
      } else {
        print('❌ Falha no upload da imagem');
      }
      return result;
    } catch (e) {
      print('❌ Erro no serviço de upload de imagem: $e');
      return null;
    }
  }

  /// Upload de vídeo usando Firebase Storage
  static Future<String?> uploadVideoFromXFile(XFile videoFile) async {
    try {
      print('🎥 Iniciando upload de vídeo via Firebase Storage...');
      final result = await FirebaseStorageService.uploadVideoFromXFile(videoFile);
      if (result != null) {
        print('✅ Upload de vídeo concluído: $result');
      } else {
        print('❌ Falha no upload do vídeo');
      }
      return result;
    } catch (e) {
      print('❌ Erro no serviço de upload de vídeo: $e');
      return null;
    }
  }

  /// Cria post completo com upload de mídia
  static Future<bool> createPostWithMedia({
    required String description,
    XFile? imageFile,
    XFile? videoFile,
    String? externalLink,
  }) async {
    try {
      String? imageUrl;
      String? videoUrl;

      // Upload da imagem se fornecida
      if (imageFile != null) {
        print('📷 Fazendo upload da imagem...');
        imageUrl = await uploadImageFromXFile(imageFile);
        if (imageUrl == null) {
          print('❌ Falha no upload da imagem');
          return false;
        }
      }

      // Upload do vídeo se fornecido
      if (videoFile != null) {
        print('🎥 Fazendo upload do vídeo...');
        videoUrl = await uploadVideoFromXFile(videoFile);
        if (videoUrl == null) {
          print('❌ Falha no upload do vídeo');
          // Se falhou o vídeo mas tinha imagem, cleanup da imagem
          if (imageUrl != null) {
            await FirebaseStorageService.deleteFile(imageUrl);
          }
          return false;
        }
      }

      // Cria o post com as URLs das mídias
      return await createPost(
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        externalLink: externalLink,
      );

    } catch (e) {
      print('❌ Erro ao criar post com mídia: $e');
      return false;
    }
  }

  /// Métodos legados - mantidos por compatibilidade
  static Future<String?> uploadImage(String filePath) async {
    print('⚠️ Método uploadImage foi substituído por uploadImageFromXFile');
    return null;
  }

  static Future<String?> uploadVideo(String filePath) async {
    print('⚠️ Método uploadVideo foi substituído por uploadVideoFromXFile');
    return null;
  }

  /// Utilitário para cleanup em caso de erro
  static Future<void> cleanupFailedUpload({
    String? imageUrl,
    String? videoUrl,
  }) async {
    if (imageUrl != null) {
      await FirebaseStorageService.deleteFile(imageUrl);
    }
    if (videoUrl != null) {
      await FirebaseStorageService.deleteFile(videoUrl);
    }
  }
}