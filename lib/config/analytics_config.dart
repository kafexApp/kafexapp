// ============================================
// KAFEX ANALYTICS - Configurações
// Caminho: lib/config/analytics_config.dart
// Data: 18/10/2025
// ============================================

/// Configurações centralizadas para o sistema de analytics.
/// 
/// Todos os nomes de eventos e constantes ficam aqui para facilitar:
/// - Manutenção (alterar em um lugar só)
/// - Evitar typos
/// - Autocomplete no IDE
class AnalyticsConfig {
  
  // ==================== EVENTOS DE TELA ====================
  
  static const String screenHome = 'home';
  static const String screenFeed = 'feed';
  static const String screenExplorador = 'explorador';
  static const String screenCafeDetail = 'cafe_detail';
  static const String screenCafeMap = 'cafe_map';
  static const String screenProfile = 'profile';
  static const String screenProfileEdit = 'profile_edit';
  static const String screenFavorites = 'favorites';
  static const String screenWantToVisit = 'want_to_visit';
  static const String screenSettings = 'settings';
  static const String screenNotifications = 'notifications';
  static const String screenAddCafe = 'add_cafe';
  
  // ==================== EVENTOS DE FEED ====================
  
  static const String eventFeedView = 'feed_view';
  static const String eventFeedRefresh = 'feed_refresh';
  static const String eventPostView = 'post_view';
  static const String eventPostLike = 'post_like';
  static const String eventPostUnlike = 'post_unlike';
  static const String eventPostComment = 'post_comment';
  static const String eventPostShare = 'post_share';
  
  // ==================== EVENTOS DE CAFETERIA ====================
  
  static const String eventCafeSearch = 'cafe_search';
  static const String eventCafeView = 'cafe_view';
  static const String eventCafeFavoriteAdd = 'cafe_favorite_add';
  static const String eventCafeFavoriteRemove = 'cafe_favorite_remove';
  static const String eventCafeWantVisitAdd = 'cafe_want_visit_add';
  static const String eventCafeWantVisitRemove = 'cafe_want_visit_remove';
  static const String eventCafeRate = 'cafe_rate';
  static const String eventCafeDirections = 'cafe_directions';
  static const String eventCafeCall = 'cafe_call';
  static const String eventCafeWebsite = 'cafe_website';
  static const String eventCafeInstagram = 'cafe_instagram';
  
  // ==================== EVENTOS DE MAPA ====================
  
  static const String eventMapView = 'map_view';
  static const String eventMapMarkerClick = 'map_marker_click';
  static const String eventMapSearch = 'map_search';
  static const String eventMapFilterApply = 'map_filter_apply';
  static const String eventMapZoom = 'map_zoom';
  
  // ==================== EVENTOS DE PERFIL ====================
  
  static const String eventProfileView = 'profile_view';
  static const String eventProfileEdit = 'profile_edit';
  static const String eventProfilePhotoUpdate = 'profile_photo_update';
  static const String eventLogout = 'logout';
  
  // ==================== EVENTOS DE AUTH ====================
  
  static const String eventLogin = 'login';
  static const String eventSignup = 'signup';
  static const String eventLoginGoogle = 'login_google';
  static const String eventLoginApple = 'login_apple';
  
  // ==================== EVENTOS DE ERRO ====================
  
  static const String eventAppError = 'app_error';
  static const String eventNetworkError = 'network_error';
  static const String eventImageLoadError = 'image_load_error';
  
  // ==================== PROPRIEDADES DE USUÁRIO ====================
  
  static const String userPropertyType = 'user_type';
  static const String userPropertyRegistrationDate = 'registration_date';
  static const String userPropertyFavoriteCafesCount = 'favorite_cafes_count';
  static const String userPropertyPostsCount = 'posts_count';
  static const String userPropertyCity = 'city';
  static const String userPropertyState = 'state';
  
  // ==================== PARÂMETROS COMUNS ====================
  
  static const String paramPostId = 'post_id';
  static const String paramPostType = 'post_type';
  static const String paramCafeId = 'cafe_id';
  static const String paramCafeName = 'cafe_name';
  static const String paramSearchTerm = 'search_term';
  static const String paramResultsCount = 'results_count';
  static const String paramShareMethod = 'share_method';
  static const String paramRating = 'rating';
  static const String paramFilters = 'filters';
  static const String paramFilterCount = 'filter_count';
  static const String paramUserId = 'user_id';
  static const String paramIsSelfProfile = 'is_self_profile';
  static const String paramErrorMessage = 'error_message';
  static const String paramErrorCode = 'error_code';
  static const String paramScreenName = 'screen_name';
  
  // ==================== VALORES DE POST TYPE ====================
  
  static const String postTypePhoto = 'photo';
  static const String postTypeVideo = 'video';
  static const String postTypeText = 'text';
  static const String postTypeReview = 'review';
  
  // ==================== VALORES DE SHARE METHOD ====================
  
  static const String shareMethodWhatsapp = 'whatsapp';
  static const String shareMethodInstagram = 'instagram';
  static const String shareMethodTwitter = 'twitter';
  static const String shareMethodLink = 'link';
  static const String shareMethodOther = 'other';
  
  // ==================== VALORES DE USER TYPE ====================
  
  static const String userTypeFree = 'free';
  static const String userTypePremium = 'premium';
  static const String userTypeAdmin = 'admin';
  
  // ==================== CONFIGURAÇÕES ====================
  
  /// Habilita/desabilita logs de debug no console
  static const bool debugMode = true;
  
  /// Habilita/desabilita coleta de analytics (útil para testes)
  static const bool analyticsEnabled = true;
  
  /// Tempo mínimo entre eventos duplicados (em segundos)
  /// Evita spam de eventos quando o usuário clica múltiplas vezes
  static const int debounceSeconds = 2;
}