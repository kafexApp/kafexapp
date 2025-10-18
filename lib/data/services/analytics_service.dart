// ============================================
// KAFEX ANALYTICS - Interface do Service
// Caminho: lib/data/services/analytics_service.dart
// Data: 18/10/2025
// ============================================

/// Interface abstrata para serviços de analytics.
/// 
/// Define o contrato que qualquer implementação de analytics deve seguir.
/// Permite trocar facilmente entre Firebase Analytics, Mixpanel, etc.
/// 
/// Arquitetura: MVVM - Camada de Service
abstract class AnalyticsService {
  
  // ==================== LIFECYCLE ====================
  
  /// Inicializa o serviço de analytics.
  /// Deve ser chamado no início do app (main.dart).
  Future<void> initialize();
  
  /// Define o ID do usuário para tracking.
  /// 
  /// [userId] - ID único do usuário (pode ser Firebase UID ou Supabase ID)
  Future<void> setUserId(String? userId);
  
  /// Define propriedades do usuário que persistem entre sessões.
  /// 
  /// Exemplos:
  /// - user_type: 'free', 'premium'
  /// - registration_date: '2025-01-15'
  /// - favorite_cafes_count: 5
  /// 
  /// [properties] - Mapa de propriedades do usuário
  Future<void> setUserProperties(Map<String, dynamic> properties);
  
  // ==================== SCREEN TRACKING ====================
  
  /// Registra visualização de uma tela.
  /// 
  /// [screenName] - Nome da tela (ex: 'home', 'cafe_detail')
  /// [screenClass] - Classe do Widget (opcional)
  /// [parameters] - Parâmetros adicionais (opcional)
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  });
  
  // ==================== CUSTOM EVENTS ====================
  
  /// Registra um evento customizado.
  /// 
  /// [eventName] - Nome do evento (ex: 'post_like', 'cafe_favorite')
  /// [parameters] - Parâmetros do evento (opcional)
  /// 
  /// Importante: Firebase tem limite de 500 parâmetros distintos.
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  });
  
  // ==================== FEED EVENTS ====================
  
  /// Usuário visualizou um post no feed.
  Future<void> logPostView({
    required int postId,
    required String postType,
  });
  
  /// Usuário curtiu um post.
  Future<void> logPostLike({
    required int postId,
    required String postType,
  });
  
  /// Usuário descurtiu um post.
  Future<void> logPostUnlike({
    required int postId,
    required String postType,
  });
  
  /// Usuário comentou em um post.
  Future<void> logPostComment({
    required int postId,
    required String postType,
  });
  
  /// Usuário compartilhou um post.
  Future<void> logPostShare({
    required int postId,
    required String postType,
    required String shareMethod, // 'whatsapp', 'instagram', 'link', etc
  });
  
  /// Usuário atualizou o feed (pull-to-refresh).
  Future<void> logFeedRefresh();
  
  // ==================== CAFETERIA EVENTS ====================
  
  /// Usuário buscou uma cafeteria.
  Future<void> logCafeSearch({
    required String searchTerm,
    int? resultsCount,
  });
  
  /// Usuário visualizou detalhes de uma cafeteria.
  Future<void> logCafeView({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário adicionou cafeteria aos favoritos.
  Future<void> logCafeFavoriteAdd({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário removeu cafeteria dos favoritos.
  Future<void> logCafeFavoriteRemove({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário adicionou cafeteria à lista "Quero Visitar".
  Future<void> logCafeWantVisitAdd({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário removeu cafeteria da lista "Quero Visitar".
  Future<void> logCafeWantVisitRemove({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário avaliou uma cafeteria.
  Future<void> logCafeRate({
    required int cafeId,
    required String cafeName,
    required double rating,
  });
  
  /// Usuário solicitou direções para a cafeteria.
  Future<void> logCafeDirections({
    required int cafeId,
    required String cafeName,
  });
  
  // ==================== MAP EVENTS ====================
  
  /// Usuário abriu o mapa.
  Future<void> logMapView();
  
  /// Usuário clicou em um marcador no mapa.
  Future<void> logMapMarkerClick({
    required int cafeId,
    required String cafeName,
  });
  
  /// Usuário buscou no mapa.
  Future<void> logMapSearch({
    required String searchTerm,
  });
  
  /// Usuário aplicou filtros no mapa.
  Future<void> logMapFilterApply({
    required List<String> filters,
  });
  
  // ==================== PROFILE EVENTS ====================
  
  /// Usuário visualizou um perfil.
  Future<void> logProfileView({
    required String userId,
    bool isSelfProfile = false,
  });
  
  /// Usuário editou o próprio perfil.
  Future<void> logProfileEdit();
  
  /// Usuário atualizou foto de perfil.
  Future<void> logProfilePhotoUpdate();
  
  /// Usuário fez logout.
  Future<void> logLogout();
  
  // ==================== ERROR TRACKING ====================
  
  /// Registra um erro para analytics.
  /// 
  /// Útil para entender onde os usuários encontram problemas.
  Future<void> logError({
    required String errorMessage,
    String? errorCode,
    String? screenName,
    Map<String, dynamic>? additionalInfo,
  });
}