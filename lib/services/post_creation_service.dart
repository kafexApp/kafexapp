// lib/services/post_creation_service.dart
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';
import '../utils/user_manager.dart';

class PostCreationService {
  /// Cria um novo post no feed (apenas texto por enquanto)
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
      }

      // Adiciona URL do vídeo se fornecida
      if (videoUrl != null && videoUrl.isNotEmpty) {
        postData['url_video'] = videoUrl;
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

  /// Upload de imagem - TEMPORARIAMENTE DESABILITADO
  static Future<String?> uploadImageFromXFile(XFile imageFile) async {
    print('📷 Upload de imagem temporariamente desabilitado');
    print('🔧 Configuração do Firebase Storage pendente');
    return null;
  }

  /// Upload de vídeo - TEMPORARIAMENTE DESABILITADO  
  static Future<String?> uploadVideoFromXFile(XFile videoFile) async {
    print('🎥 Upload de vídeo temporariamente desabilitado');
    print('🔧 Configuração do Firebase Storage pendente');
    return null;
  }

  /// Métodos legados
  static Future<String?> uploadImage(String filePath) async {
    print('⚠️ uploadImage não suportado no Flutter Web');
    return null;
  }

  static Future<String?> uploadVideo(String filePath) async {
    print('⚠️ uploadVideo não suportado no Flutter Web');
    return null;
  }
}