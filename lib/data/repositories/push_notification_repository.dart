// lib/data/repositories/push_notification_repository.dart

import '../services/push_notification_service.dart';
import '../../models/push_notification_model.dart';

/// Repository para gerenciar Push Notifications
/// Segue o padrão Repository da arquitetura MVVM
abstract class PushNotificationRepository {
  /// Inicializa o serviço de push notifications
  Future<void> initialize({
    Function(PushNotificationModel)? onNotificationTap,
  });

  /// Obtém o token FCM atual do dispositivo
  String? getToken();

  /// Desativa o token atual (usado no logout)
  Future<void> deactivateToken();

  /// Deleta o token do banco (usado ao desinstalar)
  Future<void> deleteToken();
}

/// Implementação do PushNotificationRepository usando PushNotificationService
class PushNotificationRepositoryImpl implements PushNotificationRepository {
  final PushNotificationService _service;

  PushNotificationRepositoryImpl({
    PushNotificationService? service,
  }) : _service = service ?? PushNotificationService();

  @override
  Future<void> initialize({
    Function(PushNotificationModel)? onNotificationTap,
  }) async {
    await _service.initialize(
      onNotificationTap: onNotificationTap,
    );
  }

  @override
  String? getToken() {
    return _service.fcmToken;
  }

  @override
  Future<void> deactivateToken() async {
    await _service.deactivateToken();
  }

  @override
  Future<void> deleteToken() async {
    await _service.deleteToken();
  }
}