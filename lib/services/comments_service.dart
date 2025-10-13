// lib/services/comments_service.dart
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/models/comment_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notifications_service.dart';

class CommentsService {
  /// Busca comentários reais de um post específico
  static Future<List<CommentData>> getCommentsByPostId(String postId) async {
    try {
      final response = await SupaClient.client
          .from('comentario_com_usuario')
          .select()
          .eq('feed_id', postId)
          .order('comentario_criado_em', ascending: true);

      return (response as List).map((comentario) {
        return CommentData(
          id: comentario['comentario_id']?.toString() ?? '',
          userName: comentario['nome_exibicao'] ?? 'Usuário',
          userAvatar: comentario['foto_perfil'],
          content: comentario['comentario'] ?? '',
          timestamp:
              DateTime.tryParse(comentario['comentario_criado_em'] ?? '') ??
              DateTime.now(),
          likes: 0,
          isLiked: false,
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar comentários: $e');
      return [];
    }
  }

  /// Adiciona um novo comentário real e cria notificação para o dono do post
  static Future<CommentData?> addComment({
    required String postId,
    required String conteudo,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Usuário não está logado');
        return null;
      }

      // Buscar dados do usuário atual
      final userData = await _getUserData(user.uid);
      print('🔍 Dados do usuário encontrados: $userData');

      // CORREÇÃO: Inserir na tabela comentario (não na view)
      final response = await SupaClient.client
          .from('comentario')
          .insert({
            'feed_id': int.parse(postId),
            'user_ref': user.uid,
            'comentario': conteudo,
            'criado_em': DateTime.now().toIso8601String(),
            'user_id': userData['user_id'],
          })
          .select()
          .single();

      print('✅ Comentário inserido com sucesso: $response');

      // Atualizar contador no post
      await _updatePostCommentsCount(postId);

      // 🔔 NOVO: Criar notificação para o dono do post
      await _createCommentNotification(
        postId: postId,
        commentId: response['id'],
        commentContent: conteudo,
      );

      // Retornar dados do comentário combinados com dados do usuário
      return CommentData(
        id: response['id']?.toString() ?? '',
        userName: userData['nome_exibicao'] ?? user.displayName ?? 'Usuário',
        userAvatar: userData['foto_url'] ?? user.photoURL,
        content: response['comentario'] ?? '',
        timestamp:
            DateTime.tryParse(response['criado_em'] ?? '') ?? DateTime.now(),
        likes: 0,
        isLiked: false,
      );
    } catch (e) {
      print('❌ Erro ao adicionar comentário: $e');
      return null;
    }
  }

  /// 🔔 NOVO: Cria notificação para o dono do post
  static Future<void> _createCommentNotification({
    required String postId,
    required int commentId,
    required String commentContent,
  }) async {
    try {
      print('🔔 === INICIANDO CRIAÇÃO DE NOTIFICAÇÃO ===');
      print('   Post ID: $postId');
      print('   Comment ID: $commentId');
      print('   Conteúdo: $commentContent');

      // Buscar o Firebase UID do dono do post
      print('🔍 Buscando dono do post...');
      final postData = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .maybeSingle();

      print('📦 Resposta do banco: $postData');

      if (postData == null) {
        print('⚠️ Post não encontrado, notificação não criada');
        return;
      }

      final postOwnerUid = postData['usuario_uid'] as String?;
      print('👤 Dono do post (Firebase UID): $postOwnerUid');

      if (postOwnerUid == null || postOwnerUid.isEmpty) {
        print('⚠️ Dono do post não identificado, notificação não criada');
        return;
      }

      // Criar prévia do comentário (primeiros 50 caracteres)
      String preview = commentContent.trim();
      if (preview.length > 50) {
        preview = preview.substring(0, 50) + '...';
      }
      print('📝 Prévia do comentário: $preview');

      // Criar a notificação
      print('🔔 Chamando NotificationsService.notifyPostComment...');
      final success = await NotificationsService.notifyPostComment(
        feedId: int.parse(postId),
        comentarioId: commentId,
        postOwnerFirebaseUid: postOwnerUid,
        comentarioPreview: preview,
      );

      if (success) {
        print('✅ Notificação de comentário criada com sucesso');
      } else {
        print('⚠️ Falha ao criar notificação de comentário');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao criar notificação de comentário: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Edita um comentário existente
  static Future<bool> editComment({
    required String commentId,
    required String novoConteudo,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await SupaClient.client
          .from('comentario')
          .update({'comentario': novoConteudo})
          .eq('id', commentId)
          .eq('user_ref', user.uid);

      return true;
    } catch (e) {
      print('❌ Erro ao editar comentário: $e');
      return false;
    }
  }

  /// Remove um comentário
  static Future<bool> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await SupaClient.client
          .from('comentario')
          .delete()
          .eq('id', commentId)
          .eq('user_ref', user.uid);

      // Atualizar contador no post
      await _updatePostCommentsCount(postId);

      return true;
    } catch (e) {
      print('❌ Erro ao excluir comentário: $e');
      return false;
    }
  }

  /// Verifica se comentário pertence ao usuário atual
  static Future<bool> isUserComment(String commentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final response = await SupaClient.client
          .from('comentario')
          .select('user_ref')
          .eq('id', commentId)
          .maybeSingle();

      return response?['user_ref'] == user.uid;
    } catch (e) {
      print('❌ Erro ao verificar propriedade do comentário: $e');
      return false;
    }
  }

  /// Busca dados do usuário atual
  static Future<Map<String, dynamic>> _getUserData(String userRef) async {
    try {
      print('🔍 Buscando dados do usuário: $userRef');

      final response = await SupaClient.client
          .from('usuario_perfil')
          .select('id, nome_exibicao, foto_url')
          .eq('ref', userRef)
          .maybeSingle();

      if (response != null) {
        print('✅ Usuário encontrado: $response');
        return {
          'user_id': response['id'],
          'nome_exibicao': response['nome_exibicao'],
          'foto_url': response['foto_url'],
        };
      }

      print('⚠️ Usuário não encontrado no banco pelo ref, tentando criar...');

      // Se não encontrou pelo ref, criar o perfil
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newProfile = await _createUserProfile(userRef, user);
        return newProfile;
      }

      throw Exception('Usuário não autenticado');
    } catch (e) {
      print('❌ Erro ao buscar dados do usuário: $e');
      throw e;
    }
  }

  /// Cria perfil do usuário no Supabase se não existir
  static Future<Map<String, dynamic>> _createUserProfile(
    String userRef,
    User firebaseUser,
  ) async {
    try {
      print('👤 Criando perfil de usuário no Supabase...');

      final profileData = {
        'ref': userRef,
        'nome_exibicao': firebaseUser.displayName ?? 'Usuário',
        'email': firebaseUser.email,
        'foto_url': firebaseUser.photoURL,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await SupaClient.client
          .from('usuario_perfil')
          .insert(profileData)
          .select('id, nome_exibicao, foto_url')
          .single();

      print('✅ Perfil criado com sucesso: $response');

      return {
        'user_id': response['id'],
        'nome_exibicao': response['nome_exibicao'],
        'foto_url': response['foto_url'],
      };
    } catch (e) {
      print('❌ Erro ao criar perfil de usuário: $e');
      throw e;
    }
  }

  /// Atualiza contador de comentários no post
  static Future<void> _updatePostCommentsCount(String postId) async {
    try {
      print('✅ Trigger atualizará automaticamente o contador de comentários');
    } catch (e) {
      print('⚠️ Erro ao atualizar contador de comentários: $e');
    }
  }
}