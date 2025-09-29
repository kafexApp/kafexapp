import '../models/domain/notification.dart';
import '../../utils/result.dart';

/// Interface abstrata para repositório de notificações
abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> deleteNotification(String notificationId);
}

/// Implementação mock do repositório de notificações
class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    try {
      // Simular delay de rede
      await Future.delayed(Duration(milliseconds: 500));

      // Mock data
      final notifications = [
        AppNotification(
          id: '1',
          type: NotificationType.newPlace,
          title: 'Nova cafeteria descoberta!',
          message: 'Encontramos "Café do Centro" perto de você. Que tal dar uma conferida?',
          time: DateTime.now().subtract(Duration(minutes: 30)),
          isRead: false,
        ),
        AppNotification(
          id: '2',
          type: NotificationType.promotion,
          title: 'Desconto especial! ☕️',
          message: 'A "Cafeteria Bourbon" está com 15% de desconto para usuários do Kafex!',
          time: DateTime.now().subtract(Duration(hours: 2)),
          isRead: false,
        ),
        AppNotification(
          id: '3',
          type: NotificationType.review,
          title: 'Sua avaliação foi útil!',
          message: 'Sua avaliação sobre "Coffee Lab" já teve 12 curtidas da comunidade.',
          time: DateTime.now().subtract(Duration(hours: 5)),
          isRead: true,
        ),
        AppNotification(
          id: '4',
          type: NotificationType.appUpdate,
          title: 'Kafex atualizado!',
          message: 'Nova versão disponível com melhorias na busca e novos filtros.',
          time: DateTime.now().subtract(Duration(days: 1)),
          isRead: true,
        ),
        AppNotification(
          id: '5',
          type: NotificationType.community,
          title: 'Novo seguidor',
          message: 'Maria Silva começou a seguir suas avaliações de cafeterias.',
          time: DateTime.now().subtract(Duration(days: 2)),
          isRead: true,
        ),
      ];

      return Result.ok(notifications);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar notificações: $e'));
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      print('✓ Notificação $notificationId marcada como lida');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao marcar notificação: $e'));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      print('✓ Todas as notificações marcadas como lidas');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao marcar todas: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      print('✓ Notificação $notificationId deletada');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao deletar notificação: $e'));
    }
  }
}