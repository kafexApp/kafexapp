// ============================================
// KAFEX ANALYTICS - Navigation Observer
// Caminho: lib/utils/analytics_navigation_observer.dart
// Data: 18/10/2025
// ============================================

import 'package:flutter/material.dart';
import '../data/repositories/analytics_repository.dart';

/// Observer customizado para rastrear navegação entre telas.
/// 
/// Automaticamente loga screen_view quando o usuário navega.
/// Usa o nome da rota ou o nome da classe do Widget.
/// 
/// Como usar:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     AnalyticsNavigationObserver(analyticsRepository: analyticsRepo),
///   ],
/// )
/// ```
class AnalyticsNavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsRepository analyticsRepository;
  
  AnalyticsNavigationObserver({
    required this.analyticsRepository,
  });
  
  /// Extrai o nome da tela a partir da rota.
  String _getScreenName(Route<dynamic>? route) {
    if (route == null) return 'unknown';
    
    // Tenta pegar o nome da rota
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      // Remove a barra inicial se existir
      String screenName = route.settings.name!;
      if (screenName.startsWith('/')) {
        screenName = screenName.substring(1);
      }
      return screenName.isEmpty ? 'home' : screenName;
    }
    
    // Se não tem nome, usa o tipo da rota
    return route.runtimeType.toString();
  }
  
  /// Loga a visualização da tela.
  void _logScreenView(Route<dynamic>? route) {
    if (route is PageRoute) {
      final screenName = _getScreenName(route);
      
      analyticsRepository.logScreenView(
        screenName: screenName,
        screenClass: route.runtimeType.toString(),
      );
    }
  }
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreenView(route);
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logScreenView(newRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logScreenView(previousRoute);
  }
}