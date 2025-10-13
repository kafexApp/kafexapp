// lib/services/notifications_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para gerenciar notificações no Supabase
class NotificationsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtém o Firebase UID do usuário atual
  static String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Busca o user_id do Supabase a partir do Firebase UID
  static Future<int?> _getUserIdFromFirebaseUid(String firebaseUid) async {
    try {
      final response = await _supabase
          .from('usuario_perfil')
          .select('id')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response != null) {
        return response['id'] as int;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      return null;
    }
  }

  /// Busca todas as notificações do usuário atual (visíveis e invisíveis)
  /// Retorna as notificações ordenadas por data (mais recentes primeiro)
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        print('❌ Usuário não autenticado');
        return [];
      }

      print('🔍 Buscando notificações para o usuário: $firebaseUid');

      // Buscar todas as notificações do usuário
      final response = await _supabase
          .from('notificacao')
          .select()
          .eq('user_notificado_ref', firebaseUid)
          .order('created_at', ascending: false);

      print('✅ ${response.length} notificações encontradas');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar notificações: $e');
      return [];
    }
  }

  /// Busca apenas notificações não lidas (visível = true) do usuário atual
  static Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        print('❌ Usuário não autenticado');
        return [];
      }

      // visivel = true significa "não lida"
      final response = await _supabase
          .from('notificacao')
          .select()
          .eq('user_notificado_ref', firebaseUid)
          .eq('visivel', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar notificações não lidas: $e');
      return [];
    }
  }

  /// Conta quantas notificações não lidas (visível = true) o usuário tem
  static Future<int> getUnreadNotificationsCount() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) return 0;

      final response = await _supabase
          .from('notificacao')
          .select()
          .eq('user_notificado_ref', firebaseUid)
          .eq('visivel', true)
          .count();

      return response.count;
    } catch (e) {
      print('❌ Erro ao contar notificações não lidas: $e');
      return 0;
    }
  }

  /// Marca uma notificação específica como lida (visivel = false)
  static Future<bool> markAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notificacao')
          .update({'visivel': false})
          .eq('id', notificationId);

      print('✅ Notificação $notificationId marcada como lida');
      return true;
    } catch (e) {
      print('❌ Erro ao marcar notificação como lida: $e');
      return false;
    }
  }

  /// Marca todas as notificações do usuário como lidas (visivel = false)
  static Future<bool> markAllAsRead() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        print('❌ Usuário não autenticado');
        return false;
      }

      await _supabase
          .from('notificacao')
          .update({'visivel': false})
          .eq('user_notificado_ref', firebaseUid);

      print('✅ Todas as notificações marcadas como lidas');
      return true;
    } catch (e) {
      print('❌ Erro ao marcar todas como lidas: $e');
      return false;
    }
  }

  /// Deleta uma notificação permanentemente do banco
  static Future<bool> deleteNotification(int notificationId) async {
    try {
      await _supabase
          .from('notificacao')
          .delete()
          .eq('id', notificationId);

      print('✅ Notificação $notificationId deletada permanentemente');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar notificação: $e');
      return false;
    }
  }

  /// Cria uma nova notificação
  /// 
  /// Parâmetros:
  /// - [tipo]: Tipo da notificação (ex: 'curtida_post', 'comentario_post', 'avaliacao_cafeteria')
  /// - [usuarioNotificadoRef]: Firebase UID do usuário que receberá a notificação
  /// - [feedId]: ID do post relacionado (opcional)
  /// - [comentarioId]: ID do comentário relacionado (opcional)
  /// - [cafeteriaId]: ID da cafeteria relacionada (opcional)
  /// - [previaComentario]: Prévia do comentário (opcional)
  static Future<bool> createNotification({
    required String tipo,
    required String usuarioNotificadoRef,
    int? feedId,
    int? comentarioId,
    int? cafeteriaId,
    String? previaComentario,
  }) async {
    try {
      print('📬 Criando notificação do tipo: $tipo');

      // Buscar o user_id do usuário notificado
      final usuarioNotificadoId = await _getUserIdFromFirebaseUid(usuarioNotificadoRef);
      if (usuarioNotificadoId == null) {
        print('❌ Usuário notificado não encontrado no banco');
        return false;
      }

      final notificationData = {
        'tipo': tipo,
        'usuario_notificado_id': usuarioNotificadoId,
        'user_notificado_ref': usuarioNotificadoRef,
        'feed_id': feedId,
        'comentario_id': comentarioId,
        'cafeteria_id': cafeteriaId,
        'previa_comentario': previaComentario,
        'visivel': true, // true = não lida, false = lida
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('notificacao').insert(notificationData);

      print('✅ Notificação criada com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao criar notificação: $e');
      return false;
    }
  }

  /// Cria notificação quando alguém curte um post
  static Future<bool> notifyPostLike({
    required int feedId,
    required String postOwnerFirebaseUid,
  }) async {
    // Não notificar se o usuário curtiu seu próprio post
    final currentUserUid = _getCurrentFirebaseUid();
    if (currentUserUid == postOwnerFirebaseUid) {
      print('⚠️ Usuário curtiu próprio post, não notificar');
      return false;
    }

    return await createNotification(
      tipo: 'curtida_post',
      usuarioNotificadoRef: postOwnerFirebaseUid,
      feedId: feedId,
    );
  }

  /// Cria notificação quando alguém comenta em um post
  static Future<bool> notifyPostComment({
    required int feedId,
    required int comentarioId,
    required String postOwnerFirebaseUid,
    String? comentarioPreview,
  }) async {
    // Não notificar se o usuário comentou no próprio post
    final currentUserUid = _getCurrentFirebaseUid();
    if (currentUserUid == postOwnerFirebaseUid) {
      print('⚠️ Usuário comentou no próprio post, não notificar');
      return false;
    }

    return await createNotification(
      tipo: 'comentario_post',
      usuarioNotificadoRef: postOwnerFirebaseUid,
      feedId: feedId,
      comentarioId: comentarioId,
      previaComentario: comentarioPreview,
    );
  }

  /// Cria notificação quando alguém avalia uma cafeteria
  static Future<bool> notifyCafeReview({
    required int cafeteriaId,
    required String cafeOwnerFirebaseUid,
    int? avaliacaoId,
  }) async {
    // Não notificar se o usuário avaliou sua própria cafeteria
    final currentUserUid = _getCurrentFirebaseUid();
    if (currentUserUid == cafeOwnerFirebaseUid) {
      print('⚠️ Usuário avaliou própria cafeteria, não notificar');
      return false;
    }

    return await createNotification(
      tipo: 'avaliacao_cafeteria',
      usuarioNotificadoRef: cafeOwnerFirebaseUid,
      cafeteriaId: cafeteriaId,
    );
  }
}