// lib/ui/cafe_detail/view_model/cafe_detail_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cafe_detail_model.dart';
import '../services/cafe_actions_service.dart';
import '../widgets/cafe_reviews_modal.dart';
import '../../../widgets/cafe_evaluation_modal.dart';

class CafeDetailViewModel extends ChangeNotifier {
  CafeDetailModel _cafe;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFavorited = false;
  bool _wantToVisit = false;

  CafeDetailViewModel({required CafeDetailModel cafe}) : _cafe = cafe;

  // Getters
  CafeDetailModel get cafe => _cafe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasReviews => _cafe.reviews.isNotEmpty;
  bool get isFavorited => _isFavorited;
  bool get wantToVisit => _wantToVisit;

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
      await CafeActionsService.openInstagram(_cafe.instagramHandle);
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
      await CafeActionsService.openInMaps(_cafe.latitude, _cafe.longitude);
    } catch (e) {
      _setError('Erro ao abrir mapa');
      print('Erro ao abrir mapa: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Compartilha a cafeteria
  Future<void> shareCafe() async {
    try {
      _setLoading(true);
      final shareText = CafeActionsService.generateShareText(_cafe);
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
    showCafeEvaluationModal(
      context,
      cafeName: _cafe.name,
      cafeId: _cafe.id,
    );
  }

  /// Mostra todas as avaliações
  void showAllReviews(BuildContext context) {
    showCafeReviewsModal(context, _cafe.name, _cafe.reviews);
  }

  /// Reporta alteração na cafeteria
  void reportCafeChange(BuildContext context) {
    print('Reportar alteração na cafeteria: ${_cafe.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pelo aviso! Vamos verificar as informações da cafeteria.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Curte uma avaliação
  Future<void> likeReview(String reviewId) async {
    try {
      _setLoading(true);
      // TODO: Implementar lógica de curtir avaliação
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