// lib/data/repositories/notifications_repository.dart

import '../models/domain/notification.dart';
import '../../utils/result.dart';
import '../../services/notifications_service.dart';

/// Interface abstrata para repositório de notificações
abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> deleteNotification(String notificationId);
}

/// Implementação real do repositório de notificações
/// Conecta com o NotificationsService que acessa o Supabase
class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      print('🔄 Repository: Buscando notificações...');
      
      final notificacoesSupabase = await NotificationsService.getNotifications();

      final notifications = notificacoesSupabase.map((notifData) {
        return _convertToAppNotification(notifData);
      }).toList();

      print('✅ Repository: ${notifications.length} notificações convertidas');
      return Result.ok(notifications);
    } catch (e) {
      print('❌ Repository: Erro ao buscar notificações - $e');
      return Result.error(Exception('Erro ao buscar notificações: $e'));
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      print('🔄 Repository: Marcando notificação $notificationId como lida...');
      
      final success = await NotificationsService.markAsRead(
        int.parse(notificationId),
      );

      if (success) {
        print('✅ Repository: Notificação marcada como lida');
        return Result.ok(null);
      } else {
        return Result.error(Exception('Falha ao marcar notificação como lida'));
      }
    } catch (e) {
      print('❌ Repository: Erro ao marcar como lida - $e');
      return Result.error(Exception('Erro ao marcar notificação: $e'));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      print('🔄 Repository: Marcando todas as notificações como lidas...');
      
      final success = await NotificationsService.markAllAsRead();

      if (success) {
        print('✅ Repository: Todas marcadas como lidas');
        return Result.ok(null);
      } else {
        return Result.error(Exception('Falha ao marcar todas como lidas'));
      }
    } catch (e) {
      print('❌ Repository: Erro ao marcar todas - $e');
      return Result.error(Exception('Erro ao marcar todas: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      print('🔄 Repository: Deletando notificação $notificationId...');
      
      final success = await NotificationsService.deleteNotification(
        int.parse(notificationId),
      );

      if (success) {
        print('✅ Repository: Notificação deletada');
        return Result.ok(null);
      } else {
        return Result.error(Exception('Falha ao deletar notificação'));
      }
    } catch (e) {
      print('❌ Repository: Erro ao deletar - $e');
      return Result.error(Exception('Erro ao deletar notificação: $e'));
    }
  }

  /// Converte dados do Supabase para o modelo de domínio AppNotification
  AppNotification _convertToAppNotification(Map<String, dynamic> data) {
    NotificationType type = _mapTipoToNotificationType(data['tipo']);

    bool isRead = !(data['visivel'] ?? true);

    final titleAndMessage = _generateTitleAndMessage(data);

    DateTime notificationTime;
    try {
      final createdAt = data['created_at'];
      if (createdAt is String) {
        notificationTime = DateTime.parse(createdAt).toLocal();
      } else {
        notificationTime = DateTime.now();
      }
    } catch (e) {
      print('⚠️ Erro ao parsear data da notificação: $e');
      notificationTime = DateTime.now();
    }

    // 🔔 NOVO: Construir actionUrl baseado no tipo de notificação
    String? actionUrl = _buildActionUrl(data);

    return AppNotification(
      id: data['id'].toString(),
      type: type,
      title: titleAndMessage['title']!,
      message: titleAndMessage['message']!,
      time: notificationTime,
      isRead: isRead,
      icon: null,
      actionUrl: actionUrl, // URL para navegação
    );
  }

  /// 🔔 NOVO: Constrói a URL de ação baseada no tipo de notificação
  String? _buildActionUrl(Map<String, dynamic> data) {
    final tipo = data['tipo'] as String?;
    
    switch (tipo) {
      case 'curtida_post':
      case 'comentario_post':
        // Para curtidas e comentários, navegar para o post
        final feedId = data['feed_id'];
        final comentarioId = data['comentario_id'];
        
        if (feedId != null) {
          // Formato: /post/{postId}?commentId={commentId}
          String url = '/post/$feedId';
          if (comentarioId != null) {
            url += '?commentId=$comentarioId';
          }
          return url;
        }
        break;
      
      case 'avaliacao_cafeteria':
        // Para avaliações, navegar para a cafeteria
        final cafeteriaId = data['cafeteria_id'];
        if (cafeteriaId != null) {
          return '/cafeteria/$cafeteriaId';
        }
        break;
      
      default:
        return null;
    }
    
    return null;
  }

  NotificationType _mapTipoToNotificationType(String? tipo) {
    switch (tipo) {
      case 'curtida_post':
        return NotificationType.review;
      case 'comentario_post':
        return NotificationType.community;
      case 'avaliacao_cafeteria':
        return NotificationType.newPlace;
      case 'teste':
        return NotificationType.appUpdate;
      default:
        return NotificationType.community;
    }
  }

  Map<String, String> _generateTitleAndMessage(Map<String, dynamic> data) {
    final tipo = data['tipo'] as String?;
    final previaComentario = data['previa_comentario'] as String?;

    // SEMPRE usar previa_comentario se existir
    if (previaComentario != null && previaComentario.isNotEmpty) {
      return {
        'title': _getTitleForType(tipo),
        'message': previaComentario,
      };
    }

    // Fallback caso não tenha previa_comentario
    switch (tipo) {
      case 'curtida_post':
        return {
          'title': 'Curtida no seu post! ❤️',
          'message': 'Alguém curtiu seu post.',
        };
      
      case 'comentario_post':
        return {
          'title': 'Novo comentário 💬',
          'message': 'Alguém comentou no seu post.',
        };
      
      case 'avaliacao_cafeteria':
        return {
          'title': 'Nova avaliação ⭐',
          'message': 'Sua cafeteria recebeu uma nova avaliação!',
        };
      
      case 'teste':
        return {
          'title': 'Notificação de Teste',
          'message': 'Esta é uma notificação de teste.',
        };
      
      default:
        return {
          'title': 'Nova notificação',
          'message': 'Você tem uma nova notificação.',
        };
    }
  }

  String _getTitleForType(String? tipo) {
    switch (tipo) {
      case 'curtida_post':
        return 'Curtida no seu post! ❤️';
      case 'comentario_post':
        return 'Novo comentário 💬';
      case 'avaliacao_cafeteria':
        return 'Nova avaliação ⭐';
      case 'teste':
        return 'Notificação de Teste';
      default:
        return 'Nova notificação';
    }
  }
}