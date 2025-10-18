// ============================================
// KAFEX ANALYTICS - Implementação Firebase
// Caminho: lib/data/services/firebase_analytics_service.dart
// Data: 18/10/2025
// ============================================

import 'package:firebase_analytics/firebase_analytics.dart';
import 'analytics_service.dart';

/// Implementação do AnalyticsService usando Firebase Analytics.
/// 
/// O Firebase Analytics automaticamente:
/// - Gerencia batch de eventos (não envia 1 por 1)
/// - Funciona offline (envia quando volta a conexão)
/// - Coleta eventos automáticos (first_open, session_start, etc)
/// - Exporta para BigQuery (se habilitado no console)
/// 
/// Arquitetura: MVVM - Camada de Service
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Singleton pattern
  static final FirebaseAnalyticsService _instance = 
      FirebaseAnalyticsService._internal();
  
  factory FirebaseAnalyticsService() => _instance;
  
  FirebaseAnalyticsService._internal();
  
  /// Getter para o observer de navegação.
  /// Use no MaterialApp: navigatorObservers: [analyticsObserver]
  FirebaseAnalyticsObserver get observer => 
      FirebaseAnalyticsObserver(analytics: _analytics);
  
  // ==================== LIFECYCLE ====================
  
  @override
  Future<void> initialize() async {
    try {
      // Firebase Analytics é inicializado automaticamente com Firebase Core
      // Aqui podemos configurar opções adicionais se necessário
      
      // Habilita coleta de dados (padrão: true)
      await _analytics.setAnalyticsCollectionEnabled(true);
      
      print('✅ Firebase Analytics inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar Firebase Analytics: $e');
    }
  }
  
  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      print('📊 Analytics: User ID definido');
    } catch (e) {
      print('❌ Erro ao definir User ID: $e');
    }
  }
  
  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      for (var entry in properties.entries) {
        // Firebase Analytics aceita apenas String, int, double como valores
        final value = _sanitizeValue(entry.value);
        await _analytics.setUserProperty(
          name: entry.key,
          value: value,
        );
      }
      print('📊 Analytics: ${properties.length} propriedades de usuário definidas');
    } catch (e) {
      print('❌ Erro ao definir propriedades do usuário: $e');
    }
  }
  
  // ==================== SCREEN TRACKING ====================
  
  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      
      // Se houver parâmetros adicionais, loga como evento separado
      if (parameters != null && parameters.isNotEmpty) {
        await logEvent(
          eventName: 'screen_view_custom',
          parameters: {
            'screen_name': screenName,
            ...parameters,
          },
        );
      }
    } catch (e) {
      print('❌ Erro ao logar screen view: $e');
    }
  }
  
  // ==================== CUSTOM EVENTS ====================
  
  @override
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Sanitizar parâmetros (Firebase só aceita tipos primitivos)
      final sanitizedParams = parameters != null
          ? _sanitizeParameters(parameters)
          : null;
      
      await _analytics.logEvent(
        name: eventName,
        parameters: sanitizedParams,
      );
    } catch (e) {
      print('❌ Erro ao logar evento $eventName: $e');
    }
  }
  
  // ==================== FEED EVENTS ====================
  
  @override
  Future<void> logPostView({
    required int postId,
    required String postType,
  }) async {
    await logEvent(
      eventName: 'post_view',
      parameters: {
        'post_id': postId,
        'post_type': postType,
      },
    );
  }
  
  @override
  Future<void> logPostLike({
    required int postId,
    required String postType,
  }) async {
    await logEvent(
      eventName: 'post_like',
      parameters: {
        'post_id': postId,
        'post_type': postType,
      },
    );
  }
  
  @override
  Future<void> logPostUnlike({
    required int postId,
    required String postType,
  }) async {
    await logEvent(
      eventName: 'post_unlike',
      parameters: {
        'post_id': postId,
        'post_type': postType,
      },
    );
  }
  
  @override
  Future<void> logPostComment({
    required int postId,
    required String postType,
  }) async {
    await logEvent(
      eventName: 'post_comment',
      parameters: {
        'post_id': postId,
        'post_type': postType,
      },
    );
  }
  
  @override
  Future<void> logPostShare({
    required int postId,
    required String postType,
    required String shareMethod,
  }) async {
    await logEvent(
      eventName: 'post_share',
      parameters: {
        'post_id': postId,
        'post_type': postType,
        'share_method': shareMethod,
      },
    );
  }
  
  @override
  Future<void> logFeedRefresh() async {
    await logEvent(eventName: 'feed_refresh');
  }
  
  // ==================== CAFETERIA EVENTS ====================
  
  @override
  Future<void> logCafeSearch({
    required String searchTerm,
    int? resultsCount,
  }) async {
    await logEvent(
      eventName: 'cafe_search',
      parameters: {
        'search_term': searchTerm,
        if (resultsCount != null) 'results_count': resultsCount,
      },
    );
  }
  
  @override
  Future<void> logCafeView({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_view',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logCafeFavoriteAdd({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_favorite_add',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logCafeFavoriteRemove({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_favorite_remove',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logCafeWantVisitAdd({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_want_visit_add',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logCafeWantVisitRemove({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_want_visit_remove',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logCafeRate({
    required int cafeId,
    required String cafeName,
    required double rating,
  }) async {
    await logEvent(
      eventName: 'cafe_rate',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
        'rating': rating,
      },
    );
  }
  
  @override
  Future<void> logCafeDirections({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'cafe_directions',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  // ==================== MAP EVENTS ====================
  
  @override
  Future<void> logMapView() async {
    await logEvent(eventName: 'map_view');
  }
  
  @override
  Future<void> logMapMarkerClick({
    required int cafeId,
    required String cafeName,
  }) async {
    await logEvent(
      eventName: 'map_marker_click',
      parameters: {
        'cafe_id': cafeId,
        'cafe_name': cafeName,
      },
    );
  }
  
  @override
  Future<void> logMapSearch({
    required String searchTerm,
  }) async {
    await logEvent(
      eventName: 'map_search',
      parameters: {
        'search_term': searchTerm,
      },
    );
  }
  
  @override
  Future<void> logMapFilterApply({
    required List<String> filters,
  }) async {
    await logEvent(
      eventName: 'map_filter_apply',
      parameters: {
        'filters': filters.join(','),
        'filter_count': filters.length,
      },
    );
  }
  
  // ==================== PROFILE EVENTS ====================
  
  @override
  Future<void> logProfileView({
    required String userId,
    bool isSelfProfile = false,
  }) async {
    await logEvent(
      eventName: 'profile_view',
      parameters: {
        'user_id': userId,
        'is_self_profile': isSelfProfile,
      },
    );
  }
  
  @override
  Future<void> logProfileEdit() async {
    await logEvent(eventName: 'profile_edit');
  }
  
  @override
  Future<void> logProfilePhotoUpdate() async {
    await logEvent(eventName: 'profile_photo_update');
  }
  
  @override
  Future<void> logLogout() async {
    await logEvent(eventName: 'logout');
  }
  
  // ==================== ERROR TRACKING ====================
  
  @override
  Future<void> logError({
    required String errorMessage,
    String? errorCode,
    String? screenName,
    Map<String, dynamic>? additionalInfo,
  }) async {
    await logEvent(
      eventName: 'app_error',
      parameters: {
        'error_message': errorMessage,
        if (errorCode != null) 'error_code': errorCode,
        if (screenName != null) 'screen_name': screenName,
        ...?additionalInfo,
      },
    );
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Sanitiza os parâmetros para serem aceitos pelo Firebase Analytics.
  /// 
  /// Firebase aceita apenas: String, int, double
  /// Converte bool para int (0/1) e listas para String separada por vírgula.
  Map<String, Object> _sanitizeParameters(Map<String, dynamic> parameters) {
    final sanitized = <String, Object>{};
    
    for (var entry in parameters.entries) {
      final value = _sanitizeValue(entry.value);
      if (value != null) {
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }
  
  /// Sanitiza um valor individual.
  String? _sanitizeValue(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      return value;
    }
    
    if (value is int || value is double) {
      return value.toString();
    }
    
    if (value is bool) {
      return value ? '1' : '0';
    }
    
    if (value is List) {
      return value.join(',');
    }
    
    // Para outros tipos, converte para String
    return value.toString();
  }
}