import 'package:flutter/material.dart';
import '../../../data/models/domain/notification.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationsRepository _repository;

  NotificationsViewModel({
    required NotificationsRepository repository,
  }) : _repository = repository;

  // ==================== ESTADO ====================

  NotificationsState _state = NotificationsState();
  NotificationsState get state => _state;

  List<AppNotification> get notifications => _state.notifications;
  int get unreadCount => _state.unreadCount;

  // ==================== COMMANDS ====================

  late final Command0<List<AppNotification>> loadNotifications =
      Command0(_loadNotifications);

  late final Command1<void, String> markAsRead = Command1(_markAsRead);

  late final Command0<void> markAllAsRead = Command0(_markAllAsRead);

  late final Command1<void, String> deleteNotification =
      Command1(_deleteNotification);

  // ==================== LÓGICA ====================

  Future<Result<List<AppNotification>>> _loadNotifications() async {
    try {
      final result = await _repository.getNotifications();

      if (result.isOk) {
        final notifications = result.asOk.value;
        _state = NotificationsState(
          notifications: notifications,
          unreadCount: notifications.where((n) => !n.isRead).length,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Erro ao carregar notificações: $e'));
    }
  }

  Future<Result<void>> _markAsRead(String notificationId) async {
    try {
      final result = await _repository.markAsRead(notificationId);

      if (result.isOk) {
        // Atualizar localmente
        final updatedNotifications = _state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        _state = NotificationsState(
          notifications: updatedNotifications,
          unreadCount: updatedNotifications.where((n) => !n.isRead).length,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Erro ao marcar como lida: $e'));
    }
  }

  Future<Result<void>> _markAllAsRead() async {
    try {
      final result = await _repository.markAllAsRead();

      if (result.isOk) {
        // Marcar todas localmente
        final updatedNotifications = _state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        _state = NotificationsState(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Erro ao marcar todas: $e'));
    }
  }

  Future<Result<void>> _deleteNotification(String notificationId) async {
    try {
      final result = await _repository.deleteNotification(notificationId);

      if (result.isOk) {
        // Remover localmente
        final updatedNotifications = _state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        _state = NotificationsState(
          notifications: updatedNotifications,
          unreadCount: updatedNotifications.where((n) => !n.isRead).length,
        );
        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(Exception('Erro ao deletar notificação: $e'));
    }
  }

  // ==================== HELPERS ====================

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  void dispose() {
    loadNotifications.dispose();
    markAsRead.dispose();
    markAllAsRead.dispose();
    deleteNotification.dispose();
    super.dispose();
  }
}