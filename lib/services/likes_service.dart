// lib/services/likes_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notifications_service.dart';

class LikesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtém o Firebase UID do usuário atual
  String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Verifica se o usuário atual curtiu um post específico do feed
  Future<bool> checkIfUserLikedFeedPost({
    required int feedId,
    required int userId,
  }) async {
    try {
      final response = await _supabase
          .from('curtidas')
          .select('id')
          .eq('feed_id', feedId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Erro ao verificar curtida: $e');
      return false;
    }
  }

  /// Verifica se o usuário atual curtiu uma avaliação específica
  Future<bool> checkIfUserLikedAvaliacao({
    required int avaliacaoId,
    required int userId,
  }) async {
    try {
      final response = await _supabase
          .from('curtidas')
          .select('id')
          .eq('avaliacao_id', avaliacaoId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Erro ao verificar curtida: $e');
      return false;
    }
  }

  /// Conta o total de curtidas de um post do feed
  Future<int> getFeedPostLikesCount(int feedId) async {
    try {
      final response = await _supabase
          .from('curtidas')
          .select()
          .eq('feed_id', feedId)
          .count();

      return response.count;
    } catch (e) {
      print('❌ Erro ao contar curtidas: $e');
      return 0;
    }
  }

  /// Conta o total de curtidas de uma avaliação
  Future<int> getAvaliacaoLikesCount(int avaliacaoId) async {
    try {
      final response = await _supabase
          .from('curtidas')
          .select()
          .eq('avaliacao_id', avaliacaoId)
          .count();

      return response.count;
    } catch (e) {
      print('❌ Erro ao contar curtidas: $e');
      return 0;
    }
  }

  /// Adiciona uma curtida em um post do feed
  /// ATUALIZADO: Agora cria notificação automaticamente
  Future<bool> likeFeedPost({required int feedId, required int userId}) async {
    try {
      // Verifica se já curtiu
      final alreadyLiked = await checkIfUserLikedFeedPost(
        feedId: feedId,
        userId: userId,
      );

      if (alreadyLiked) {
        print('⚠️ Usuário já curtiu este post');
        return false;
      }

      // Obtém o Firebase UID do usuário atual
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        print('❌ Firebase UID não encontrado');
        return false;
      }

      // Insere a curtida
      await _supabase.from('curtidas').insert({
        'user_id': userId,
        'feed_id': feedId,
        'ref': firebaseUid, // Ref do Firebase do usuário que curtiu
      });

      // Atualiza o contador de curtidas na tabela feed
      await _updateFeedLikesCount(feedId);

      // ===== NOVO: CRIAR NOTIFICAÇÃO =====
      await _createLikeNotification(feedId, firebaseUid);
      // ===================================

      print('✅ Post curtido com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao curtir post: $e');
      return false;
    }
  }

  /// Cria notificação quando alguém curte um post
  Future<void> _createLikeNotification(int feedId, String currentUserUid) async {
    try {
      print('📬 [NOTIF] Iniciando criação de notificação de curtida...');
      print('📬 [NOTIF] Feed ID: $feedId');
      print('📬 [NOTIF] Current User UID: $currentUserUid');

      // Busca o dono do post (usuario_uid do feed)
      print('📬 [NOTIF] Buscando dono do post...');
      final postResponse = await _supabase
          .from('feed')
          .select('usuario_uid')
          .eq('id', feedId)
          .maybeSingle();

      print('📬 [NOTIF] Post response: $postResponse');

      if (postResponse == null) {
        print('⚠️ [NOTIF] Post não encontrado');
        return;
      }

      final postOwnerUid = postResponse['usuario_uid'] as String?;
      print('📬 [NOTIF] Post Owner UID: $postOwnerUid');
      
      if (postOwnerUid == null) {
        print('⚠️ [NOTIF] Dono do post não identificado (usuario_uid é null)');
        return;
      }

      // Busca o nome do usuário que curtiu
      print('📬 [NOTIF] Buscando nome do usuário que curtiu...');
      final userResponse = await _supabase
          .from('usuario_perfil')
          .select('nome_exibicao')
          .eq('ref', currentUserUid)
          .maybeSingle();

      print('📬 [NOTIF] User response: $userResponse');
      final userName = userResponse?['nome_exibicao'] as String? ?? 'Alguém';
      print('📬 [NOTIF] User name: $userName');

      // Busca o user_id do usuário notificado para preencher usuario_notificado_id
      print('📬 [NOTIF] Buscando ID do usuário notificado...');
      final notifiedUserResponse = await _supabase
          .from('usuario_perfil')
          .select('id')
          .eq('ref', postOwnerUid)
          .maybeSingle();

      print('📬 [NOTIF] Notified user response: $notifiedUserResponse');
      final usuarioNotificadoId = notifiedUserResponse?['id'] as int?;
      print('📬 [NOTIF] Usuario notificado ID: $usuarioNotificadoId');

      if (usuarioNotificadoId == null) {
        print('⚠️ [NOTIF] ID do usuário notificado não encontrado');
        return;
      }

      // Cria a notificação manualmente com mensagem personalizada
      print('📬 [NOTIF] Inserindo notificação no banco...');
      await _supabase.from('notificacao').insert({
        'tipo': 'curtida_post',
        'usuario_notificado_id': usuarioNotificadoId,
        'user_notificado_ref': postOwnerUid,
        'feed_id': feedId,
        'previa_comentario': '$userName curtiu seu post!',
        'visivel': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ [NOTIF] Notificação de curtida criada com nome: $userName');
    } catch (e, stackTrace) {
      print('❌ [NOTIF] Erro ao criar notificação de curtida: $e');
      print('❌ [NOTIF] Stack trace: $stackTrace');
      // Não bloqueia a curtida se a notificação falhar
    }
  }

  /// Adiciona uma curtida em uma avaliação
  Future<bool> likeAvaliacao({
    required int avaliacaoId,
    required int userId,
  }) async {
    try {
      // Verifica se já curtiu
      final alreadyLiked = await checkIfUserLikedAvaliacao(
        avaliacaoId: avaliacaoId,
        userId: userId,
      );

      if (alreadyLiked) {
        print('⚠️ Usuário já curtiu esta avaliação');
        return false;
      }

      // Obtém o Firebase UID do usuário atual
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        print('❌ Firebase UID não encontrado');
        return false;
      }

      // Insere a curtida
      await _supabase.from('curtidas').insert({
        'user_id': userId,
        'avaliacao_id': avaliacaoId,
        'ref': firebaseUid, // Ref do Firebase do usuário que curtiu
      });

      // Atualiza o contador de curtidas na tabela avaliacao
      await _updateAvaliacaoLikesCount(avaliacaoId);

      print('✅ Avaliação curtida com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao curtir avaliação: $e');
      return false;
    }
  }

  /// Remove a curtida de um post do feed
  Future<bool> unlikeFeedPost({
    required int feedId,
    required int userId,
  }) async {
    try {
      await _supabase
          .from('curtidas')
          .delete()
          .eq('feed_id', feedId)
          .eq('user_id', userId);

      // Atualiza o contador de curtidas na tabela feed
      await _updateFeedLikesCount(feedId);

      print('✅ Curtida removida com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao remover curtida: $e');
      return false;
    }
  }

  /// Remove a curtida de uma avaliação
  Future<bool> unlikeAvaliacao({
    required int avaliacaoId,
    required int userId,
  }) async {
    try {
      await _supabase
          .from('curtidas')
          .delete()
          .eq('avaliacao_id', avaliacaoId)
          .eq('user_id', userId);

      // Atualiza o contador de curtidas na tabela avaliacao
      await _updateAvaliacaoLikesCount(avaliacaoId);

      print('✅ Curtida removida com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao remover curtida: $e');
      return false;
    }
  }

  /// Atualiza o campo 'curtidas' na tabela feed
  Future<void> _updateFeedLikesCount(int feedId) async {
    try {
      final count = await getFeedPostLikesCount(feedId);

      await _supabase.from('feed').update({'curtidas': count}).eq('id', feedId);
    } catch (e) {
      print('❌ Erro ao atualizar contador de curtidas do feed: $e');
    }
  }

  /// Atualiza o campo 'curtidas' na tabela avaliacao
  Future<void> _updateAvaliacaoLikesCount(int avaliacaoId) async {
    try {
      final count = await getAvaliacaoLikesCount(avaliacaoId);

      await _supabase
          .from('avaliacao')
          .update({'curtidas': count})
          .eq('id', avaliacaoId);
    } catch (e) {
      print('❌ Erro ao atualizar contador de curtidas da avaliação: $e');
    }
  }

  /// Busca todas as curtidas de um usuário (para exibir no perfil)
  Future<List<Map<String, dynamic>>> getUserLikes(int userId) async {
    try {
      final response = await _supabase
          .from('curtidas')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar curtidas do usuário: $e');
      return [];
    }
  }
}