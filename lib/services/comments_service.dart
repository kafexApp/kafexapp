// lib/services/comments_service.dart
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/models/comment_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          likes: 0, // Campo não existe na estrutura atual
          isLiked: false,
        );
      }).toList();
    } catch (e) {
      print('Erro ao buscar comentários: $e');
      return [];
    }
  }

  /// Adiciona um novo comentário real
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

      final response = await SupaClient.client
          .from('comentario_com_usuario')
          .insert({
            'feed_id': postId,
            'user_ref': user.uid,
            'comentario': conteudo,
            'comentario_criado_em': DateTime.now().toIso8601String(),
            'nome_exibicao':
                userData['nome_exibicao'] ?? user.displayName ?? 'Usuário',
            'foto_perfil': userData['foto_perfil'] ?? user.photoURL,
            'user_id': userData['user_id'] ?? '0',
          })
          .select()
          .single();

      // Atualizar contador no post
      await _updatePostCommentsCount(postId);

      return CommentData(
        id: response['comentario_id']?.toString() ?? '',
        userName: response['nome_exibicao'] ?? 'Usuário',
        userAvatar: response['foto_perfil'],
        content: response['comentario'] ?? '',
        timestamp:
            DateTime.tryParse(response['comentario_criado_em'] ?? '') ??
            DateTime.now(),
        likes: 0,
        isLiked: false,
      );
    } catch (e) {
      print('Erro ao adicionar comentário: $e');
      return null;
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
          .from('comentario_com_usuario')
          .update({'comentario': novoConteudo})
          .eq('comentario_id', commentId)
          .eq('user_ref', user.uid);

      return true;
    } catch (e) {
      print('Erro ao editar comentário: $e');
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
          .from('comentario_com_usuario')
          .delete()
          .eq('comentario_id', commentId)
          .eq('user_ref', user.uid);

      // Atualizar contador no post
      await _updatePostCommentsCount(postId);

      return true;
    } catch (e) {
      print('Erro ao excluir comentário: $e');
      return false;
    }
  }

  /// Verifica se comentário pertence ao usuário atual
  static Future<bool> isUserComment(String commentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final response = await SupaClient.client
          .from('comentario_com_usuario')
          .select('user_ref')
          .eq('comentario_id', commentId)
          .maybeSingle();

      return response?['user_ref'] == user.uid;
    } catch (e) {
      print('Erro ao verificar propriedade do comentário: $e');
      return false;
    }
  }

  /// Busca dados do usuário atual (ajustar conforme sua estrutura)
  static Future<Map<String, dynamic>> _getUserData(String userRef) async {
    try {
      // Ajustar conforme o nome da sua tabela de usuários
      final response = await SupaClient.client
          .from('users') // ou o nome correto da sua tabela
          .select('user_id, nome_exibicao, foto_perfil')
          .eq('user_ref', userRef)
          .maybeSingle();

      return response ?? {};
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return {};
    }
  }

  /// Atualiza contador de comentários no post
  static Future<void> _updatePostCommentsCount(String postId) async {
    try {
      // Contar comentários reais
      final response = await SupaClient.client
          .from('comentario_com_usuario')
          .select('comentario_id')
          .eq('feed_id', postId);

      final count = (response as List).length;

      // Atualizar contador na tabela de posts
      await SupaClient.client
          .from('feed_com_usuario')
          .update({'comentarios': count.toString()})
          .eq('id', postId);
    } catch (e) {
      print('Erro ao atualizar contador de comentários: $e');
    }
  }
}
