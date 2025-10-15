// lib/ui/cafe_detail/view_model/cafe_detail_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cafe_detail_model.dart';
import '../models/user_review_model.dart';
import '../services/cafe_actions_service.dart';
import '../widgets/cafe_reviews_modal.dart';
import '../../../widgets/cafe_evaluation_modal.dart';
import '../../../data/repositories/cafe_repository.dart';
import '../../../data/repositories/quero_visitar_repository.dart';
import '../../../data/repositories/favorito_repository.dart';
import '../../../data/repositories/avaliacao_repository.dart';

class CafeDetailViewModel extends ChangeNotifier {
  final CafeRepository _cafeRepository;
  final QueroVisitarRepository _queroVisitarRepository;
  final FavoritoRepository _favoritoRepository;
  final AvaliacaoRepository _avaliacaoRepository;

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
    AvaliacaoRepository? avaliacaoRepository,
  })  : _cafe = cafe,
        _cafeRepository = cafeRepository ?? CafeRepositoryImpl(),
        _queroVisitarRepository =
            queroVisitarRepository ?? QueroVisitarRepositoryImpl(),
        _favoritoRepository = favoritoRepository ?? FavoritoRepositoryImpl(),
        _avaliacaoRepository =
            avaliacaoRepository ?? AvaliacaoRepositoryImpl() {
    // Carrega o status inicial e as avaliações
    _loadQueroVisitarStatus();
    _loadFavoritoStatus();
    _loadReviews();
  }

  // Getters
  CafeDetailModel get cafe => _cafe;
  bool get isLoading => _isLoading;
  bool get isLoadingReviews => _isLoadingReviews;
  String? get errorMessage => _errorMessage;
  bool get hasReviews => _cafe.reviews.isNotEmpty;
  bool get isFavorited => _isFavorited;
  bool get wantToVisit => _wantToVisit;

  /// Carrega as avaliações da cafeteria do Supabase
  Future<void> _loadReviews() async {
    try {
      _isLoadingReviews = true;
      notifyListeners();

      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) {
        print('⚠️ ID da cafeteria inválido: ${_cafe.id}');
        _isLoadingReviews = false;
        notifyListeners();
        return;
      }

      print('🔄 Carregando avaliações da cafeteria $cafeIdInt');

      final result = await _avaliacaoRepository.getAvaliacoesByCafeteria(
        cafeIdInt,
      );

      if (result.isOk) {
        final reviews = result.asOk.value;
        print('✅ ${reviews.length} avaliações carregadas');

        // Atualiza o modelo com as avaliações reais
        _cafe = _cafe.copyWith(reviews: reviews);

        // Atualiza também as estatísticas
        await _loadAvaliacaoStats(cafeIdInt);
      } else {
        print('❌ Erro ao carregar avaliações: ${result.asError.error}');
      }
    } catch (e) {
      print('❌ Erro ao carregar avaliações: $e');
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  /// Carrega estatísticas de avaliação
  Future<void> _loadAvaliacaoStats(int cafeteriaId) async {
    try {
      final result = await _avaliacaoRepository.getAvaliacaoStats(cafeteriaId);

      if (result.isOk) {
        final stats = result.asOk.value;
        final media = stats['media'] as double;

        print('📊 Estatísticas: média $media avaliações');

        // Atualiza apenas o rating (removido totalReviews que não existe)
        _cafe = _cafe.copyWith(rating: media);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao carregar estatísticas: $e');
    }
  }

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

      final result =
          await _queroVisitarRepository.checkIfUserWantsToVisit(cafeIdInt);

      if (result.isOk) {
        _wantToVisit = result.asOk.value;
        notifyListeners();
      } else {
        print(
          '❌ Erro ao carregar status "quero visitar": ${result.asError.error}',
        );
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

      if (result != null) {
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
    print('🔄 Recarregando avaliações...');
    await _loadReviews();
  }

  /// Método chamado após criar uma nova avaliação
  Future<void> onAvaliacaoCreated() async {
    print('✅ Nova avaliação criada, recarregando...');
    await reloadReviews();
  }

  /// Toggle favorito
  /// ✅ CORRIGIDO: Usa toggleFavorito() que já existe no repositório
  Future<void> toggleFavorite() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) return;

      final result = await _favoritoRepository.toggleFavorito(cafeIdInt);
      
      if (result.isOk) {
        // Inverte o estado local
        _isFavorited = !_isFavorited;
        notifyListeners();
        print('✅ Favorito alternado: $_isFavorited');
      } else {
        print('❌ Erro ao alternar favorito: ${result.asError.error}');
      }
    } catch (e) {
      print('❌ Erro ao toggle favorito: $e');
    }
  }

  /// Toggle quero visitar
  /// ✅ CORRIGIDO: Usa toggleQueroVisitar() que já existe no repositório
  Future<void> toggleWantToVisit() async {
    try {
      final cafeIdInt = int.tryParse(_cafe.id);
      if (cafeIdInt == null) return;

      final result = await _queroVisitarRepository.toggleQueroVisitar(cafeIdInt);
      
      if (result.isOk) {
        // Inverte o estado local
        _wantToVisit = !_wantToVisit;
        notifyListeners();
        print('✅ Quero visitar alternado: $_wantToVisit');
      } else {
        print('❌ Erro ao alternar quero visitar: ${result.asError.error}');
      }
    } catch (e) {
      print('❌ Erro ao toggle quero visitar: $e');
    }
  }

  /// Compartilhar cafeteria
  Future<void> shareCafe() async {
    try {
      await Share.share(
        'Confira ${_cafe.name} no Kafex!\n\n${_cafe.address}',
        subject: 'Cafeteria do Kafex',
      );
    } catch (e) {
      print('❌ Erro ao compartilhar: $e');
    }
  }

  /// Abre Instagram da cafeteria
  Future<void> openInstagram() async {
    final instagramHandle = _cafe.instagramHandle;
    if (instagramHandle == null || instagramHandle.isEmpty) {
      print('⚠️ Instagram handle não disponível');
      return;
    }

    try {
      final url = 'https://instagram.com/$instagramHandle';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Erro ao abrir Instagram: $e');
    }
  }

  /// Abre localização no mapa
  Future<void> openInMaps() async {
    final lat = _cafe.latitude;
    final lng = _cafe.longitude;

    if (lat == null || lng == null) {
      print('⚠️ Coordenadas não disponíveis');
      return;
    }

    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Erro ao abrir mapa: $e');
    }
  }

  /// Curte uma review (placeholder - implementar depois)
  void likeReview(String reviewId) {
    print('👍 Curtir review: $reviewId');
    // TODO: Implementar curtir review
  }

  /// Mostra todas as reviews
  void showAllReviews(BuildContext context) {
    showCafeReviewsModal(
      context,
      _cafe.name,
      _cafe.reviews,
    );
  }

  /// Reportar mudança na cafeteria
  void reportCafeChange(BuildContext context) {
    // TODO: Implementar report
    print('📝 Reportar mudança na cafeteria');
  }

  /// Abre o modal de avaliação
  void openEvaluationModal(BuildContext context) {
    final cafeIdInt = int.tryParse(_cafe.id);
    if (cafeIdInt == null) {
      print('⚠️ ID da cafeteria inválido');
      return;
    }

    showCafeEvaluationModal(
      context,
      cafeName: _cafe.name,
      cafeId: cafeIdInt,
      cafeRef: _cafe.id,
      onEvaluationSubmitted: () async {
        // Callback chamado após submeter avaliação
        await onAvaliacaoCreated();
      },
    );
  }

  /// Abre o modal de reviews
  void openReviewsModal(BuildContext context) {
    showCafeReviewsModal(
      context,
      _cafe.name,
      _cafe.reviews,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}