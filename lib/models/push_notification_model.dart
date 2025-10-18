// lib/domain/models/push_notification_model.dart

/// Modelo de dados para Push Notifications (Firebase Cloud Messaging)
/// Este modelo é usado para notificações que chegam via FCM
class PushNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final PushNotificationAction action;
  final DateTime createdAt;

  PushNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.action,
    required this.createdAt,
  });

  /// Cria uma instância a partir de dados do Firebase Messaging
  factory PushNotificationModel.fromFirebaseMessage(
    String messageId,
    Map<String, dynamic> data,
  ) {
    return PushNotificationModel(
      id: messageId,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['image_url'],
      action: PushNotificationAction.fromMap(data),
      createdAt: DateTime.now(),
    );
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'action_type': action.type.toServerString(),
      'action_value': action.value,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Ação a ser executada ao clicar na push notification
class PushNotificationAction {
  final PushNotificationActionType type;
  final String? value;

  PushNotificationAction({
    required this.type,
    this.value,
  });

  factory PushNotificationAction.fromMap(Map<String, dynamic> data) {
    return PushNotificationAction(
      type: PushNotificationActionType.fromString(data['action_type'] ?? 'none'),
      value: data['action_value'],
    );
  }

  /// Ação vazia (não faz nada ao clicar)
  static PushNotificationAction none() {
    return PushNotificationAction(type: PushNotificationActionType.none);
  }

  /// Ação para abrir um post
  static PushNotificationAction openPost(String postId) {
    return PushNotificationAction(
      type: PushNotificationActionType.openPost,
      value: postId,
    );
  }

  /// Ação para abrir uma cafeteria
  static PushNotificationAction openCafeteria(String cafeteriaId) {
    return PushNotificationAction(
      type: PushNotificationActionType.openCafeteria,
      value: cafeteriaId,
    );
  }

  /// Ação para abrir uma URL externa
  static PushNotificationAction openUrl(String url) {
    return PushNotificationAction(
      type: PushNotificationActionType.openUrl,
      value: url,
    );
  }

  /// Ação para abrir uma tela específica do app
  static PushNotificationAction openScreen(String screenName) {
    return PushNotificationAction(
      type: PushNotificationActionType.openScreen,
      value: screenName,
    );
  }
}

/// Tipos de ação disponíveis para push notifications
enum PushNotificationActionType {
  none,           // Não faz nada (apenas mostra a notificação)
  openPost,       // Abre um post específico no feed
  openCafeteria,  // Abre detalhes de uma cafeteria
  openUrl,        // Abre uma URL externa no navegador
  openScreen;     // Abre uma tela específica do app (ex: explorador, perfil)

  static PushNotificationActionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open_post':
        return PushNotificationActionType.openPost;
      case 'open_cafeteria':
        return PushNotificationActionType.openCafeteria;
      case 'open_url':
        return PushNotificationActionType.openUrl;
      case 'open_screen':
        return PushNotificationActionType.openScreen;
      default:
        return PushNotificationActionType.none;
    }
  }

  String toServerString() {
    switch (this) {
      case PushNotificationActionType.openPost:
        return 'open_post';
      case PushNotificationActionType.openCafeteria:
        return 'open_cafeteria';
      case PushNotificationActionType.openUrl:
        return 'open_url';
      case PushNotificationActionType.openScreen:
        return 'open_screen';
      default:
        return 'none';
    }
  }
}