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
      print('🔍 Dados do usuário encontrados: $userData');

      // CORREÇÃO: Inserir na tabela comentario (não na view)
      final response = await SupaClient.client
          .from('comentario') // Tabela base, não a view
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

  /// Edita um comentário existente
  static Future<bool> editComment({
    required String commentId,
    required String novoConteudo,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // CORREÇÃO: Atualizar na tabela comentario (não na view)
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

      // CORREÇÃO: Deletar da tabela comentario (não da view)
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

      // CORREÇÃO: Buscar na tabela usuario_perfil pelo campo 'ref' (não 'user_ref')
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
        'ref': userRef, // CORREÇÃO: campo correto é 'ref'
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
      // O trigger já faz isso automaticamente
      print('✅ Trigger atualizará automaticamente o contador de comentários');
    } catch (e) {
      print('⚠️ Erro ao atualizar contador de comentários: $e');
    }
  }
}
