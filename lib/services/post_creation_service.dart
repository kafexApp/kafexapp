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
      
      // Buscar dados do usuário logado
      String authorName = userManager.userName;
      String? authorAvatar = userManager.userPhotoUrl;
      String userEmail = userManager.userEmail;
      
      // Se os dados estão vazios, buscar do Supabase Auth
      final currentUser = SupaClient.client.auth.currentUser;
      if (currentUser != null && (authorName == 'Usuário Kafex' || authorName.isEmpty)) {
        final metadata = currentUser.userMetadata;
        if (metadata != null) {
          authorName = metadata['full_name']?.toString() ?? 
                      metadata['name']?.toString() ?? 
                      metadata['display_name']?.toString() ??
                      currentUser.email?.split('@')[0] ?? 
                      'Usuário';
                      
          authorAvatar = metadata['avatar_url']?.toString() ?? 
                        metadata['picture']?.toString();
        }
      }
      
      // Primeiro, verificar se o usuário existe na tabela usuario_perfil
      await _ensureUserProfileExists(userEmail, authorName, authorAvatar);
      
      // Criar o post na tabela feed (apenas com campos que existem)
      final postData = {
        'descricao': description.trim(),
        'criado_em': DateTime.now().toIso8601String(),
        'tipo': 'tradicional',
        'usuario_uid': userEmail,
        'nome_usuario': authorName,  // Campo que existe na tabela feed
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
      print('   Email: $userEmail');
      print('   Avatar: $authorAvatar');

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

  /// Garante que o usuário existe na tabela usuario_perfil para o JOIN funcionar
  static Future<void> _ensureUserProfileExists(String userEmail, String userName, String? userAvatar) async {
    try {
      print('🔍 Verificando se usuário existe na tabela usuario_perfil...');
      
      // Tentar obter foto do Firebase Auth se não tiver uma
      if (userAvatar == null || userAvatar.isEmpty) {
        final currentUser = SupaClient.client.auth.currentUser;
        if (currentUser != null) {
          userAvatar = currentUser.userMetadata?['avatar_url']?.toString() ?? 
                       currentUser.userMetadata?['picture']?.toString();
          print('🔄 Obtendo foto do Firebase Auth: $userAvatar');
        }
      }
      
      // Primeiro, buscar se já existe um perfil para este usuário
      final existingUser = await SupaClient.client
          .from('usuario_perfil')
          .select('id, foto_url')
          .eq('email', userEmail)
          .maybeSingle();

      if (existingUser == null) {
        print('👤 Criando perfil de usuário para: $userName');
        
        // Se não existe, criar o perfil de usuário
        final userProfileData = {
          'email': userEmail,
          'nome_exibicao': userName,
          'foto_url': userAvatar,
          'created_at': DateTime.now().toIso8601String(),
        };

        await SupaClient.client
            .from('usuario_perfil')
            .insert(userProfileData);
            
        print('✅ Perfil de usuário criado com sucesso');
        
        // Atualizar UserManager com a foto se obteve uma
        if (userAvatar != null && userAvatar.isNotEmpty) {
          UserManager.instance.setUserData(
            name: userName,
            email: userEmail,
            photoUrl: userAvatar,
          );
        }
      } else {
        print('👤 Usuário já existe na tabela usuario_perfil');
        
        // Se existe, atualizar apenas se tiver dados novos
        final existingPhotoUrl = existingUser['foto_url'] as String?;
        
        // Só atualiza se o nome mudou ou se não tinha foto antes e agora tem
        final shouldUpdate = existingPhotoUrl != userAvatar || 
                           (existingPhotoUrl == null && userAvatar != null);
        
        if (shouldUpdate) {
          await SupaClient.client
              .from('usuario_perfil')
              .update({
                'nome_exibicao': userName,
                'foto_url': userAvatar,
              })
              .eq('email', userEmail);
              
          print('✅ Dados do usuário atualizados');
        } else {
          print('ℹ️ Dados do usuário já estão atualizados');
        }
      }
      
    } catch (e) {
      print('⚠️ Erro ao verificar/criar perfil de usuário: $e');
      // Não falha o processo de criação do post por causa disso
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