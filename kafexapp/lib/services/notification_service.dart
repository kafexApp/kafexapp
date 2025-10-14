import 'package:flutter/material.dart';

// Serviço singleton para gerenciar notificações
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  int _unreadCount = 2; // Exemplo: 2 notificações não lidas inicialmente

  int get unreadCount => _unreadCount;

  // Adicionar nova notificação
  void addNotification() {
    _unreadCount++;
    notifyListeners();
  }

  // Marcar como lida (diminuir contador)
  void markAsRead() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  // Marcar todas como lidas
  void markAllAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  // Definir contador específico
  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }
}

// Widget wrapper para escutar mudanças no serviço
class NotificationConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, int unreadCount) builder;

  const NotificationConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService(),
      builder: (context, _) {
        return builder(context, NotificationService().unreadCount);
      },
    );
  }
}