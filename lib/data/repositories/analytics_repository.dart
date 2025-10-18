// ============================================
// KAFEX ANALYTICS - Repository
// Caminho: lib/data/repositories/analytics_repository.dart
// Data: 18/10/2025
// ============================================

import '../services/analytics_service.dart';

/// Repository para Analytics seguindo o padrão MVVM.
/// 
/// Abstrai a camada de service e adiciona lógica de negócio se necessário.
/// ViewModels devem usar o Repository, não o Service diretamente.
/// 
/// Arquitetura: MVVM - Camada de Repository
class AnalyticsRepository {
  final AnalyticsService _analyticsService;
  
  AnalyticsRepository({
    required AnalyticsService analyticsService,
  }) : _analyticsService = analyticsService;
  
  // ==================== LIFECYCLE ====================
  
  Future<void> initialize() async {
    await _analyticsService.initialize();
  }
  
  Future<void> setUserId(String? userId) async {
    await _analyticsService.setUserId(userId);
  }
  
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    await _analyticsService.setUserProperties(properties);
  }
  
  // ==================== SCREEN TRACKING ====================
  
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    await _analyticsService.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
      parameters: parameters,
    );
  }
  
  // ==================== CUSTOM EVENTS ====================
  
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analyticsService.logEvent(
      eventName: eventName,
      parameters: parameters,
    );
  }
  
  // ==================== FEED EVENTS ====================
  
  Future<void> logPostView({
    required int postId,
    required String postType,
  }) async {
    await _analyticsService.logPostView(
      postId: postId,
      postType: postType,
    );
  }
  
  Future<void> logPostLike({
    required int postId,
    required String postType,
  }) async {
    await _analyticsService.logPostLike(
      postId: postId,
      postType: postType,
    );
  }
  
  Future<void> logPostUnlike({
    required int postId,
    required String postType,
  }) async {
    await _analyticsService.logPostUnlike(
      postId: postId,
      postType: postType,
    );
  }
  
  Future<void> logPostComment({
    required int postId,
    required String postType,
  }) async {
    await _analyticsService.logPostComment(
      postId: postId,
      postType: postType,
    );
  }
  
  Future<void> logPostShare({
    required int postId,
    required String postType,
    required String shareMethod,
  }) async {
    await _analyticsService.logPostShare(
      postId: postId,
      postType: postType,
      shareMethod: shareMethod,
    );
  }
  
  Future<void> logFeedRefresh() async {
    await _analyticsService.logFeedRefresh();
  }
  
  // ==================== CAFETERIA EVENTS ====================
  
  Future<void> logCafeSearch({
    required String searchTerm,
    int? resultsCount,
  }) async {
    await _analyticsService.logCafeSearch(
      searchTerm: searchTerm,
      resultsCount: resultsCount,
    );
  }
  
  Future<void> logCafeView({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeView(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logCafeFavoriteAdd({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeFavoriteAdd(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logCafeFavoriteRemove({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeFavoriteRemove(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logCafeWantVisitAdd({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeWantVisitAdd(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logCafeWantVisitRemove({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeWantVisitRemove(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logCafeRate({
    required int cafeId,
    required String cafeName,
    required double rating,
  }) async {
    await _analyticsService.logCafeRate(
      cafeId: cafeId,
      cafeName: cafeName,
      rating: rating,
    );
  }
  
  Future<void> logCafeDirections({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logCafeDirections(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  // ==================== MAP EVENTS ====================
  
  Future<void> logMapView() async {
    await _analyticsService.logMapView();
  }
  
  Future<void> logMapMarkerClick({
    required int cafeId,
    required String cafeName,
  }) async {
    await _analyticsService.logMapMarkerClick(
      cafeId: cafeId,
      cafeName: cafeName,
    );
  }
  
  Future<void> logMapSearch({
    required String searchTerm,
  }) async {
    await _analyticsService.logMapSearch(
      searchTerm: searchTerm,
    );
  }
  
  Future<void> logMapFilterApply({
    required List<String> filters,
  }) async {
    await _analyticsService.logMapFilterApply(
      filters: filters,
    );
  }
  
  // ==================== PROFILE EVENTS ====================
  
  Future<void> logProfileView({
    required String userId,
    bool isSelfProfile = false,
  }) async {
    await _analyticsService.logProfileView(
      userId: userId,
      isSelfProfile: isSelfProfile,
    );
  }
  
  Future<void> logProfileEdit() async {
    await _analyticsService.logProfileEdit();
  }
  
  Future<void> logProfilePhotoUpdate() async {
    await _analyticsService.logProfilePhotoUpdate();
  }
  
  Future<void> logLogout() async {
    await _analyticsService.logLogout();
  }
  
  // ==================== ERROR TRACKING ====================
  
  Future<void> logError({
    required String errorMessage,
    String? errorCode,
    String? screenName,
    Map<String, dynamic>? additionalInfo,
  }) async {
    await _analyticsService.logError(
      errorMessage: errorMessage,
      errorCode: errorCode,
      screenName: screenName,
      additionalInfo: additionalInfo,
    );
  }
}