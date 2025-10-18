// lib/utils/push_notification_handler.dart

import 'package:flutter/material.dart';
import '../models/push_notification_model.dart';
import '../data/repositories/push_notification_repository.dart';

/// Handler para gerenciar push notifications e navegação
class PushNotificationHandler {
  final PushNotificationRepository _repository;
  final GlobalKey<NavigatorState> navigatorKey;

  PushNotificationHandler({
    required PushNotificationRepository repository,
    required this.navigatorKey,
  }) : _repository = repository;

  /// Inicializa o handler de push notifications
  Future<void> initialize() async {
    print('🔔 Inicializando PushNotificationHandler...');

    await _repository.initialize(
      onNotificationTap: _handleNotificationTap,
    );

    print('✅ PushNotificationHandler inicializado!');
  }

  /// Callback quando usuário clica em uma push notification
  void _handleNotificationTap(PushNotificationModel notification) {
    print('👆 Processando clique na push notification');
    print('Ação: ${notification.action.type}');
    print('Valor: ${notification.action.value}');

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ Contexto não disponível para navegação');
      return;
    }

    // Executar ação baseada no tipo
    switch (notification.action.type) {
      case PushNotificationActionType.none:
        print('ℹ️ Nenhuma ação definida');
        break;

      case PushNotificationActionType.openPost:
        _navigateToPost(context, notification.action.value);
        break;

      case PushNotificationActionType.openCafeteria:
        _navigateToCafeteria(context, notification.action.value);
        break;

      case PushNotificationActionType.openUrl:
        _openUrl(notification.action.value);
        break;

      case PushNotificationActionType.openScreen:
        _navigateToScreen(context, notification.action.value);
        break;
    }
  }

  /// Navega para um post específico
  void _navigateToPost(BuildContext context, String? postId) {
    if (postId == null) {
      print('❌ ID do post não fornecido');
      return;
    }

    print('📍 Navegando para post: $postId');

    // TODO: Implementar navegação para o post
    // Exemplo: Navigator.pushNamed(context, '/post', arguments: postId);
    
    // Por enquanto, apenas log
    print('⚠️ Navegação para post ainda não implementada');
  }

  /// Navega para detalhes de uma cafeteria
  void _navigateToCafeteria(BuildContext context, String? cafeteriaId) {
    if (cafeteriaId == null) {
      print('❌ ID da cafeteria não fornecido');
      return;
    }

    print('📍 Navegando para cafeteria: $cafeteriaId');

    // TODO: Implementar navegação para cafeteria
    // Exemplo: Navigator.pushNamed(context, '/cafe-detail', arguments: cafeteriaId);
    
    // Por enquanto, apenas log
    print('⚠️ Navegação para cafeteria ainda não implementada');
  }

  /// Abre uma URL externa
  void _openUrl(String? url) {
    if (url == null) {
      print('❌ URL não fornecida');
      return;
    }

    print('🌐 Abrindo URL: $url');

    // TODO: Implementar abertura de URL
    // Exemplo: launchUrl(Uri.parse(url));
    
    // Por enquanto, apenas log
    print('⚠️ Abertura de URL ainda não implementada');
  }

  /// Navega para uma tela específica do app
  void _navigateToScreen(BuildContext context, String? screenName) {
    if (screenName == null) {
      print('❌ Nome da tela não fornecido');
      return;
    }

    print('📍 Navegando para tela: $screenName');

    // TODO: Implementar navegação para telas
    // Exemplo:
    // switch (screenName) {
    //   case 'explorador':
    //     Navigator.pushNamed(context, '/explorador');
    //     break;
    //   case 'perfil':
    //     Navigator.pushNamed(context, '/perfil');
    //     break;
    // }
    
    // Por enquanto, apenas log
    print('⚠️ Navegação para tela ainda não implementada');
  }

  /// Desativa token (usado no logout)
  Future<void> deactivateToken() async {
    await _repository.deactivateToken();
  }

  /// Deleta token (usado ao desinstalar)
  Future<void> deleteToken() async {
    await _repository.deleteToken();
  }
}