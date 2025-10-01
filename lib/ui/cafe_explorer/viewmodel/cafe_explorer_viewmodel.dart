import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../data/repositories/cafe_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/services/clustering_service.dart';
import '../../../data/models/domain/cafe.dart';
import '../../../data/models/domain/place_suggestion.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class CafeExplorerViewModel extends ChangeNotifier {
  final CafeRepository _cafeRepository;
  final PlacesRepository _placesRepository;
  final ClusteringService _clusteringService;

  CafeExplorerViewModel({
    required CafeRepository cafeRepository,
    required PlacesRepository placesRepository,
    required ClusteringService clusteringService,
  })  : _cafeRepository = cafeRepository,
        _placesRepository = placesRepository,
        _clusteringService = clusteringService {
    loadCafes = Command0(_loadCafes);
    searchPlaces = Command1(_searchPlaces);
    selectPlace = Command1(_selectPlace);
    
    // Carregar cafés automaticamente
    loadCafes.execute();
  }

  // === Estado ===
  List<Cafe> _allCafes = [];
  List<Cafe> _visibleCafes = [];
  List<Cafe> _cafesInViewport = [];
  List<PlaceSuggestion> _suggestions = [];
  
  bool _isMapView = true;
  double _currentZoom = 15.0;
  LatLng _currentPosition = LatLng(-23.5505, -46.6333); // São Paulo default
  
  LatLng? _searchLocation;
  String _searchAddress = '';
  bool _isShowingSearchResults = false;
  
  String _lastSearchQuery = '';
  Timer? _searchTimer;

  // Raio de filtro em km para o modo lista
  static const double _filterRadiusKm = 5.0;

  // === Getters ===
  List<Cafe> get allCafes => List.unmodifiable(_allCafes);
  List<Cafe> get visibleCafes => List.unmodifiable(_visibleCafes);
  List<Cafe> get cafesInViewport => List.unmodifiable(_cafesInViewport);
  List<PlaceSuggestion> get suggestions => List.unmodifiable(_suggestions);
  
  bool get isMapView => _isMapView;
  double get currentZoom => _currentZoom;
  LatLng get currentPosition => _currentPosition;
  LatLng? get searchLocation => _searchLocation;
  String get searchAddress => _searchAddress;
  bool get isShowingSearchResults => _isShowingSearchResults;
  
  bool get hasSuggestions => _suggestions.isNotEmpty;
  bool get isLoading => loadCafes.running;

  // === Commands ===
  late final Command0<List<Cafe>> loadCafes;
  late final Command1<List<PlaceSuggestion>, String> searchPlaces;
  late final Command1<void, PlaceSuggestion> selectPlace;

  /// Carregar todas as cafeterias do banco de dados
  Future<Result<List<Cafe>>> _loadCafes() async {
    try {
      final cafes = await _cafeRepository.getAllCafes();
      _allCafes = cafes;
      _visibleCafes = List.from(_allCafes);
      notifyListeners();
      return Result.ok(cafes);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar cafeterias: $e'));
    }
  }

  /// Buscar lugares (cafeterias + Google Places)
  Future<Result<List<PlaceSuggestion>>> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return Result.ok([]);
    }

    // Debounce
    if (_lastSearchQuery == query) {
      return Result.ok(_suggestions);
    }

    try {
      // Aguardar 500ms antes de buscar (debounce)
      await Future.delayed(Duration(milliseconds: 500));

      _lastSearchQuery = query;
      
      // Busca híbrida: cafeterias cadastradas + lugares do Google
      final cafeSuggestions = _searchCafeteriasByName(query);
      final placeSuggestions = await _placesRepository.searchPlaces(query);
      
      // Combinar resultados (cafeterias primeiro)
      _suggestions = [...cafeSuggestions, ...placeSuggestions];
      
      notifyListeners();
      return Result.ok(_suggestions);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar lugares: $e'));
    }
  }

  /// Buscar cafeterias por nome (localmente)
  List<PlaceSuggestion> _searchCafeteriasByName(String query) {
    final lowerQuery = query.toLowerCase();
    
    return _allCafes
        .where((cafe) =>
            cafe.name.toLowerCase().contains(lowerQuery) ||
            cafe.address.toLowerCase().contains(lowerQuery))
        .map((cafe) => PlaceSuggestion(
              placeId: 'cafe_${cafe.id}',
              description: cafe.name,
              mainText: cafe.name,
              secondaryText: cafe.address,
            ))
        .take(5)
        .toList();
  }

  /// Selecionar lugar da lista de sugestões
  Future<Result<void>> _selectPlace(PlaceSuggestion suggestion) async {
    try {
      _suggestions = [];
      notifyListeners();

      // Verificar se é uma cafeteria cadastrada
      if (suggestion.placeId.startsWith('cafe_')) {
        final cafeId = suggestion.placeId.replaceFirst('cafe_', '');
        final cafe = _allCafes.firstWhere((c) => c.id == cafeId);
        
        if (_isMapView) {
          // Modo mapa: atualizar posição central
          _currentPosition = cafe.position;
          notifyListeners();
        } else {
          // Modo lista: filtrar para mostrar apenas essa cafeteria
          _visibleCafes = [cafe];
          _isShowingSearchResults = true;
          notifyListeners();
        }
      } else {
        // Lugar do Google Places
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
    
    // Ao alternar para modo lista, aplicar filtro de raio
    if (!_isMapView) {
      _filterCafesByMapRadius();
    }
    
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
    
    // Se estiver no modo lista, atualizar filtro de raio
    if (!_isMapView && !_isShowingSearchResults) {
      _filterCafesByMapRadius();
    }
    
    notifyListeners();
  }

  /// Filtrar cafeterias por raio do centro do mapa (5km)
  void _filterCafesByMapRadius() {
    _visibleCafes = _allCafes.where((cafe) {
      final distance = _calculateDistanceKm(_currentPosition, cafe.position);
      return distance <= _filterRadiusKm;
    }).toList();
  }

  /// Calcular distância entre dois pontos em km (fórmula Haversine)
  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    final dLng = _degreesToRadians(pos2.longitude - pos1.longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  /// Converter graus para radianos
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
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