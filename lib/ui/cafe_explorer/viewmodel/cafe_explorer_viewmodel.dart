import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../data/models/domain/cafe.dart';
import '../../../data/models/domain/place_suggestion.dart';
import '../../../data/repositories/cafe_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/services/clustering_service.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class CafeExplorerViewModel extends ChangeNotifier {
  final CafeRepository _cafeRepository;
  final PlacesRepository _placesRepository;
  final ClusteringService _clusteringService;

  CafeExplorerViewModel({
    required CafeRepository cafeRepository,
    required PlacesRepository placesRepository,
    ClusteringService? clusteringService,
  })  : _cafeRepository = cafeRepository,
        _placesRepository = placesRepository,
        _clusteringService = clusteringService ?? ClusteringService() {
    loadCafes.execute();
  }

  // ==================== ESTADO ====================

  // Dados
  List<Cafe> _allCafes = [];
  List<Cafe> _visibleCafes = [];
  List<Cafe> _cafesInViewport = [];
  List<PlaceSuggestion> _suggestions = [];

  // UI State
  bool _isMapView = true;
  double _currentZoom = 15.0;
  LatLng _currentPosition = LatLng(-23.5505, -46.6333);
  LatLng? _searchLocation;
  String _searchAddress = '';
  bool _isShowingSearchResults = false;

  // Busca
  String _lastSearchQuery = '';
  Timer? _searchTimer;

  // Getters
  List<Cafe> get allCafes => _allCafes;
  List<Cafe> get visibleCafes => _visibleCafes;
  List<Cafe> get cafesInViewport => _cafesInViewport;
  List<PlaceSuggestion> get suggestions => _suggestions;
  bool get isMapView => _isMapView;
  double get currentZoom => _currentZoom;
  LatLng get currentPosition => _currentPosition;
  LatLng? get searchLocation => _searchLocation;
  String get searchAddress => _searchAddress;
  bool get isShowingSearchResults => _isShowingSearchResults;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  // ==================== COMMANDS ====================

  late final Command0<void> loadCafes = Command0(_loadCafes);
  
  late final Command1<List<PlaceSuggestion>, String> searchPlaces = 
      Command1(_searchPlaces);
  
  late final Command1<void, PlaceSuggestion> selectPlace = 
      Command1(_selectPlace);

  // ==================== LÓGICA DE NEGÓCIO ====================

  /// Carregar todas as cafeterias
  Future<Result<void>> _loadCafes() async {
    try {
      _allCafes = await _cafeRepository.getAllCafes();
      _visibleCafes = List.from(_allCafes);
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar cafeterias: $e'));
    }
  }

  /// Buscar lugares (com debounce)
  Future<Result<List<PlaceSuggestion>>> _searchPlaces(String query) async {
    try {
      if (query.trim().isEmpty) {
        _suggestions = [];
        _lastSearchQuery = '';
        notifyListeners();
        return Result.ok([]);
      }

      // Evitar buscas duplicadas
      if (query == _lastSearchQuery) {
        return Result.ok(_suggestions);
      }

      // Cancelar timer anterior
      _searchTimer?.cancel();

      // Aguardar 500ms antes de buscar (debounce)
      await Future.delayed(Duration(milliseconds: 500));

      _lastSearchQuery = query;
      _suggestions = await _placesRepository.searchPlaces(query);
      notifyListeners();
      return Result.ok(_suggestions);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar lugares: $e'));
    }
  }

  /// Selecionar lugar da lista de sugestões
  Future<Result<void>> _selectPlace(PlaceSuggestion suggestion) async {
    try {
      _suggestions = [];
      notifyListeners();

      final coordinates = await _placesRepository.getCoordinatesFromPlaceId(
        suggestion.placeId,
      );

      if (coordinates != null) {
        if (_isMapView) {
          // Modo mapa: apenas atualizar posição (o widget move a câmera)
          _currentPosition = coordinates;
          notifyListeners();
        } else {
          // Modo lista: filtrar cafés próximos
          await _filterCafesByLocation(coordinates, suggestion.description);
        }
      }
      
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao selecionar lugar: $e'));
    }
  }

  /// Filtrar cafeterias por localização
  Future<void> _filterCafesByLocation(LatLng location, String address) async {
    final nearbyCafes = await _cafeRepository.getCafesNearLocation(location);

    _visibleCafes = nearbyCafes;
    _searchLocation = location;
    _searchAddress = address;
    _isShowingSearchResults = true;
    notifyListeners();
  }

  /// Limpar busca
  void clearSearch() {
    _visibleCafes = List.from(_allCafes);
    _searchLocation = null;
    _searchAddress = '';
    _isShowingSearchResults = false;
    _suggestions = [];
    _lastSearchQuery = '';
    notifyListeners();
  }

  /// Alternar entre mapa e lista
  void toggleView() {
    _isMapView = !_isMapView;
    
    // Limpar busca ao voltar para o mapa
    if (_isMapView && _isShowingSearchResults) {
      clearSearch();
    }
    
    notifyListeners();
  }

  /// Atualizar zoom do mapa
  void updateZoom(double zoom) {
    _currentZoom = zoom;
    notifyListeners();
  }

  /// Atualizar posição central do mapa
  void updateMapCenter(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  /// Atualizar cafés visíveis no viewport do mapa
  void updateCafesInViewport(List<Cafe> cafes) {
    _cafesInViewport = cafes;
    notifyListeners();
  }

  /// Obter grupos de pins (com clustering)
  List<PinGroup> getPinGroups() {
    return _clusteringService.groupCafes(_visibleCafes, _currentZoom);
  }

  /// Limpar sugestões
  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    loadCafes.dispose();
    searchPlaces.dispose();
    selectPlace.dispose();
    super.dispose();
  }
}