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
import '../../../data/repositories/quero_visitar_repository.dart';
import '../../../data/repositories/favorito_repository.dart';
import '../../../services/avaliacao_service.dart';
import '../../../services/event_bus_service.dart';

class CafeDetailViewModel extends ChangeNotifier {
  final CafeRepository _cafeRepository;
  final QueroVisitarRepository _queroVisitarRepository;
  final FavoritoRepository _favoritoRepository;
  final EventBusService _eventBus = EventBusService();

  CafeDetailModel _cafe;
  bool _isLoading = false;
  bool _isLoadingReviews = false;
  String? _errorMessage;
  bool _isFavorited = false;
  bool _wantToVisit = false;

  CafeDetailViewModel({
    required CafeDetailModel cafe,
    CafeRepository? cafeRepository,
    QueroVisitarRepository? queroVisitarRepository,
    FavoritoRepository? favoritoRepository,
  }) : _cafe = cafe,
       _cafeRepository = cafeRepository ?? CafeRepositoryImpl(),
       _queroVisitarRepository = queroVisitarRepository ?? QueroVisitarRepositoryImpl(),
       _favoritoRepository = favoritoRepository ?? FavoritoRepositoryImpl() {
    // Carrega o status inicial
    _loadQueroVisitarStatus();
    _loadFavoritoStatus();
  }

  // Getters
  CafeDetailModel get cafe => _cafe;
  bool get isLoading => _isLoading;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  bool get hasReviews => _cafe.reviews.isNotEmpty;
  bool get isFavorited => _isFavorited;
  bool get wantToVisit => _wantToVisit;

  /// Carrega o status inicial do favorito
  Future<void> _loadFavoritoStatus() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) return;

      final result = await _favoritoRepository.checkIfUserFavorited(cafeIdInt);
      
      if (result.isOk) {
        _isFavorited = result.asOk.value;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao carregar status favorito: $e');
    }
  }

  /// Carrega o status inicial do "quero visitar"
  Future<void> _loadQueroVisitarStatus() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) return;

      final result = await _queroVisitarRepository.checkIfUserWantsToVisit(cafeIdInt);
      
      if (result.isOk) {
        _wantToVisit = result.asOk.value;
        notifyListeners();
      } else {
        print('❌ Erro ao carregar status "quero visitar": ${result.asError.error}');
      }
    } catch (e) {
      print('❌ Erro ao carregar status "quero visitar": $e');
    }
  }

  /// Carrega dados completos da cafeteria do Supabase
  Future<void> loadCafeData(String cafeId) async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Carregando dados da cafeteria: $cafeId');

      final cafeIdInt = int.tryParse(cafeId);
      if (cafeIdInt == null) {
        _setError('ID da cafeteria inválido');
        return;
      }

      final result = await _cafeRepository.getCafeById(cafeIdInt);

      // O repository retorna Map<String, dynamic>?, não Result
      if (result != null) {
        // Converter para CafeDetailModel (implementar conversão)
        print('✅ Dados da cafeteria carregados com sucesso');
        notifyListeners();
      } else {
        _setError('Erro ao carregar dados da cafeteria');
        print('❌ Erro: cafeteria não encontrada');
      }
    } catch (e) {
      _setError('Erro ao carregar dados');
      print('❌ Erro ao carregar cafeteria: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega avaliações
  Future<void> reloadReviews() async {
    // TODO: Implementar reload de avaliações
    print('Recarregando avaliações...');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void openInstagram() {
    CafeActionsService.openInstagram(_cafe.instagramHandle ?? '');
  }

  void shareLocation() {
    Share.share('Confira esta cafeteria: ${_cafe.name} - ${_cafe.address}');
  }

  Future<void> shareCafe() async {
    try {
      final shareText = CafeActionsService.generateShareText(_cafe);
      await Share.share(shareText);
    } catch (e) {
      _setError('Erro ao compartilhar');
      print('Erro ao compartilhar: $e');
    }
  }

  Future<void> openInMaps() async {
    try {
      await CafeActionsService.openInMaps(_cafe.latitude ?? 0.0, _cafe.longitude ?? 0.0);
    } catch (e) {
      _setError('Erro ao abrir mapa');
      print('Erro ao abrir mapa: $e');
    }
  }

  void showAllReviews(BuildContext context) {
    showCafeReviewsModal(
      context,
      _cafe.name,
      _cafe.reviews,
    );
  }

  void openEvaluationModal(BuildContext context) {
    showCafeEvaluationModal(
      context,
      cafeName: _cafe.name,
      cafeId: _cafe.id,
    );
    
    // Recarregar avaliações após fechar o modal
    reloadReviews();
  }

  void reportCafeChange(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pela sugestão! Vamos verificar as informações da cafeteria.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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

  /// ✅ Alterna favorito da cafeteria COM EVENTBUS
  Future<void> toggleFavorite() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) {
        _setError('ID da cafeteria inválido');
        return;
      }

      // Atualiza localmente
      final previousFavorited = _isFavorited;
      final newFavorited = !previousFavorited;
      _isFavorited = newFavorited;
      notifyListeners();

      // ✅ EMITE EVENTO IMEDIATAMENTE
      _eventBus.emit(FavoriteChangedEvent(_cafe.id, newFavorited));
      print('🚀 Evento FavoriteChangedEvent emitido do modal: coffeeId=${_cafe.id}, isFavorited=$newFavorited');

      // Chama o repository
      final result = await _favoritoRepository.toggleFavorito(cafeIdInt);

      if (result.isOk) {
        print('✅ Favorito alterado com sucesso');
      } else {
        // Se falhar, reverte
        _isFavorited = previousFavorited;
        _setError('Erro ao alterar favorito');
        // Emite evento de reversão
        _eventBus.emit(FavoriteChangedEvent(_cafe.id, previousFavorited));
        print('❌ Erro ao alterar favorito: ${result.asError.error}');
        notifyListeners();
      }
    } catch (e) {
      // Se falhar, reverte
      _isFavorited = !_isFavorited;
      _setError('Erro ao alterar favorito');
      _eventBus.emit(FavoriteChangedEvent(_cafe.id, _isFavorited));
      print('❌ Erro ao alterar favorito: $e');
      notifyListeners();
    }
  }

  /// ✅ Alterna "quero visitar" da cafeteria COM EVENTBUS
  Future<void> toggleWantToVisit() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) {
        _setError('ID da cafeteria inválido');
        return;
      }

      // Atualiza localmente
      final previousWantToVisit = _wantToVisit;
      final newWantToVisit = !previousWantToVisit;
      _wantToVisit = newWantToVisit;
      notifyListeners();

      // ✅ EMITE EVENTO IMEDIATAMENTE
      _eventBus.emit(WantToVisitChangedEvent(_cafe.id, newWantToVisit));
      print('🚀 Evento WantToVisitChangedEvent emitido do modal: coffeeId=${_cafe.id}, wantToVisit=$newWantToVisit');

      // Chama o repository
      final result = await _queroVisitarRepository.toggleQueroVisitar(cafeIdInt);

      if (result.isOk) {
        print('✅ "Quero visitar" alterado com sucesso');
      } else {
        // Se falhar, reverte
        _wantToVisit = previousWantToVisit;
        _setError('Erro ao alterar lista de desejados');
        // Emite evento de reversão
        _eventBus.emit(WantToVisitChangedEvent(_cafe.id, previousWantToVisit));
        print('❌ Erro ao alterar "quero visitar": ${result.asError.error}');
        notifyListeners();
      }
    } catch (e) {
      // Se falhar, reverte
      _wantToVisit = !_wantToVisit;
      _setError('Erro ao alterar lista de desejados');
      _eventBus.emit(WantToVisitChangedEvent(_cafe.id, _wantToVisit));
      print('❌ Erro ao alterar "quero visitar": $e');
      notifyListeners();
    }
  }

  void clearError() {
    _setError(null);
  }
}