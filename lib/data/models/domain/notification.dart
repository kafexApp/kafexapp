import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Tipos de notificação
enum NotificationType {
  newPlace,
  promotion,
  review,
  appUpdate,
  community,
}

/// Modelo de domínio para notificações
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    required DateTime time,
    @Default(false) bool isRead,
    String? icon,
    String? actionUrl,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

/// Estado da lista de notificações
@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default([]) List<AppNotification> notifications,
    @Default(0) int unreadCount,
  }) = _NotificationsState;

  const NotificationsState._();

  /// Pega apenas notificações não lidas
  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  /// Pega apenas notificações lidas
  List<AppNotification> get readNotifications =>
      notifications.where((n) => n.isRead).toList();
}