// lib/ui/cafe_detail/view_model/cafe_detail_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cafe_detail_model.dart';
import '../models/user_review_model.dart';
import '../services/cafe_actions_service.dart';
import '../widgets/cafe_reviews_modal.dart';
import '../../../widgets/cafe_evaluation_modal.dart';
import '../../../data/repositories/cafe_repository.dart';
import '../../../services/avaliacao_service.dart';

class CafeDetailViewModel extends ChangeNotifier {
  final CafeRepository _cafeRepository;

  CafeDetailModel _cafe;
  bool _isLoading = false;
  bool _isLoadingReviews = false;
  String? _errorMessage;
  bool _isFavorited = false;
  bool _wantToVisit = false;

  CafeDetailViewModel({
    required CafeDetailModel cafe,
    CafeRepository? cafeRepository,
  }) : _cafe = cafe,
       _cafeRepository = cafeRepository ?? CafeRepositoryImpl();

  // Getters
  CafeDetailModel get cafe => _cafe;
  bool get isLoading => _isLoading;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  bool get hasReviews => _cafe.reviews.isNotEmpty;
  bool get isFavorited => _isFavorited;
  bool get wantToVisit => _wantToVisit;

  /// Carrega dados completos da cafeteria do Supabase
  Future<void> loadCafeData(String cafeId) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Carregando dados da cafeteria: $cafeId');

      // Tentar converter ID para int
      final cafeIdInt = int.tryParse(cafeId);
      if (cafeIdInt == null) {
        _setError('ID da cafeteria inválido');
        return;
      }

      // Buscar dados do repository
      final cafeData = await _cafeRepository.getCafeById(cafeIdInt);

      if (cafeData == null) {
        _setError('Cafeteria não encontrada');
        return;
      }

      // Carregar avaliações da cafeteria
      await _loadReviews(cafeIdInt);

      // Converter dados do Supabase para o modelo (com as reviews carregadas)
      _cafe = CafeDetailModel.fromSupabase(
        cafeData,
        reviews: _cafe.reviews, // Usar as reviews já carregadas
      );

      print('✅ Dados da cafeteria carregados com sucesso');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar dados da cafeteria');
      print('❌ Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega as avaliações reais da cafeteria do Supabase
  Future<void> _loadReviews(int cafeteriaId) async {
    try {
      _isLoadingReviews = true;
      notifyListeners();

      print('🔄 Carregando avaliações da cafeteria ID: $cafeteriaId');

      // Buscar avaliações do serviço
      final avaliacoesSupabase =
          await AvaliacaoService.getAvaliacoesByCafeteria(cafeteriaId);

      // Converter para modelo UserReview
      final reviews = avaliacoesSupabase
          .map((avaliacao) => UserReview.fromSupabase(avaliacao))
          .toList();

      // Atualizar o modelo da cafeteria com as reviews reais
      _cafe = _cafe.copyWith(reviews: reviews, reviewCount: reviews.length);

      print('✅ ${reviews.length} avaliações carregadas');
    } catch (e) {
      print('❌ Erro ao carregar avaliações: $e');
      // Em caso de erro, manter as reviews vazias ao invés de usar mock
      _cafe = _cafe.copyWith(reviews: []);
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  /// Recarrega apenas as avaliações
  Future<void> reloadReviews() async {
    final cafeIdInt = int.tryParse(_cafe.id);
    if (cafeIdInt == null) {
      print('❌ ID da cafeteria inválido para recarregar reviews');
      return;
    }

    await _loadReviews(cafeIdInt);
  }

  /// Atualiza os dados da cafeteria
  void updateCafe(CafeDetailModel newCafe) {
    _cafe = newCafe;
    notifyListeners();
  }

  /// Define estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define mensagem de erro
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Abre o Instagram da cafeteria
  Future<void> openInstagram() async {
    try {
      _setLoading(true);
      await CafeActionsService.openInstagram(cafe.instagramHandle);
    } catch (e) {
      _setError('Erro ao abrir Instagram');
      print('Erro ao abrir Instagram: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Abre o mapa com a localização
  Future<void> openInMaps() async {
    try {
      _setLoading(true);
      await CafeActionsService.openInMaps(cafe.latitude, cafe.longitude);
    } catch (e) {
      _setError('Erro ao abrir mapa');
      print('Erro ao abrir mapa: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Compartilha informações da cafeteria
  Future<void> shareCafe() async {
    try {
      _setLoading(true);
      final shareText = CafeActionsService.generateShareText(cafe);
      await Share.share(shareText);
    } catch (e) {
      _setError('Erro ao compartilhar');
      print('Erro ao compartilhar: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Abre modal de avaliação
  void openEvaluationModal(BuildContext context) {
    showCafeEvaluationModal(context, cafeName: cafe.name, cafeId: cafe.id);
  }

  /// Abre modal com todas as avaliações
  void showAllReviews(BuildContext context) {
    showCafeReviewsModal(context, cafe.name, cafe.reviews);
  }

  /// Reporta alteração na cafeteria
  void reportCafeChange(BuildContext context) {
    print('Reportar alteração na cafeteria: ${cafe.name}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pelo aviso! Vamos verificar as informações da cafeteria.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Reporta um problema com a cafeteria
  void reportIssue(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado por reportar! Vamos verificar as informações da cafeteria.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Curte uma avaliação
  Future<void> likeReview(String reviewId) async {
    try {
      _setLoading(true);
      // TODO: Implementar lógica de curtir avaliação no backend
      print('Curtir avaliação: $reviewId');
    } catch (e) {
      _setError('Erro ao curtir avaliação');
      print('Erro ao curtir avaliação: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Alterna favorito da cafeteria
  Future<void> toggleFavorite() async {
    try {
      _setLoading(true);
      _isFavorited = !_isFavorited;
      // TODO: Implementar lógica de favoritos no backend
      print('Favorito alterado para: $_isFavorited');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao alterar favorito');
      print('Erro ao alterar favorito: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Alterna "quero visitar" da cafeteria
  Future<void> toggleWantToVisit() async {
    try {
      _setLoading(true);
      _wantToVisit = !_wantToVisit;
      // TODO: Implementar lógica de "quero visitar" no backend
      print('Quero visitar alterado para: $_wantToVisit');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao alterar lista de desejados');
      print('Erro ao alterar lista de desejados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _setError(null);
  }
}
