// lib/ui/cafe_explorer/viewmodel/cafe_explorer_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  }) : _cafeRepository = cafeRepository,
       _placesRepository = placesRepository,
       _clusteringService = clusteringService {
    debugPrint('🟢 CafeExplorerViewModel construído');

    loadCafes = Command0(_loadCafes);
    searchPlaces = Command1(_searchPlaces);
    selectPlace = Command1(_selectPlace);

    // Carregar localização salva
    _loadSavedLocation();

    // Carregar cafés automaticamente
    debugPrint('🟢 Carregando cafés');
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

  // === Chaves do SharedPreferences ===
  static const String _savedLatitudeKey = 'saved_latitude';
  static const String _savedLongitudeKey = 'saved_longitude';

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

  // === Commands ===
  late Command0<void> loadCafes;
  late Command1<void, String> searchPlaces;
  late Command1<void, PlaceSuggestion> selectPlace;

  // === Carregar localização salva ===
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble(_savedLatitudeKey);
      final savedLng = prefs.getDouble(_savedLongitudeKey);

      if (savedLat != null && savedLng != null) {
        _currentPosition = LatLng(savedLat, savedLng);
        debugPrint('📍 Localização carregada: $savedLat, $savedLng');
        notifyListeners();
      } else {
        debugPrint('⚠️ Nenhuma localização salva encontrada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar localização: $e');
    }
  }

  // === Salvar localização do usuário ===
  Future<void> saveUserLocation(LatLng location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_savedLatitudeKey, location.latitude);
      await prefs.setDouble(_savedLongitudeKey, location.longitude);

      _currentPosition = location;
      notifyListeners();

      debugPrint(
        '✅ Localização salva: ${location.latitude}, ${location.longitude}',
      );
    } catch (e) {
      debugPrint('❌ Erro ao salvar localização: $e');
    }
  }

  /// Carregar todas as cafeterias
  Future<Result<void>> _loadCafes() async {
    try {
      debugPrint('🔄 Iniciando carregamento de cafeterias...');

      final cafes = await _cafeRepository.getAllCafes();

      _allCafes = cafes;
      _visibleCafes = List.from(_allCafes);

      debugPrint('✅ ${cafes.length} cafeterias carregadas com sucesso');

      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      debugPrint('❌ Erro ao carregar cafeterias: $e');
      return Result.error(Exception('Erro ao carregar cafeterias: $e'));
    }
  }

  /// Buscar lugares (híbrido: cafeterias + Google Places)
  Future<Result<void>> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      clearSuggestions();
      return Result.ok(null);
    }

    // Debounce: aguardar 500ms entre buscas
    if (query == _lastSearchQuery) {
      return Result.ok(null);
    }
    _lastSearchQuery = query;

    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () async {
      try {
        debugPrint('🔍 Buscando: "$query"');

        // Buscar em paralelo: cafeterias cadastradas + Google Places
        final results = await Future.wait([
          _searchCafeteriasByName(query),
          _placesRepository.searchPlaces(query),
        ]);

        final cafeSuggestions = results[0] as List<PlaceSuggestion>;
        final placeSuggestions = results[1] as List<PlaceSuggestion>;

        // Combinar resultados (cafeterias primeiro)
        _suggestions = [...cafeSuggestions, ...placeSuggestions];

        debugPrint('✅ ${_suggestions.length} sugestões encontradas');

        notifyListeners();
      } catch (e) {
        debugPrint('❌ Erro na busca: $e');
      }
    });

    return Result.ok(null);
  }

  /// Buscar cafeterias por nome (local)
  Future<List<PlaceSuggestion>> _searchCafeteriasByName(String query) async {
    final lowerQuery = query.toLowerCase().trim();

    final matchingCafes = _allCafes.where((cafe) {
      return cafe.name.toLowerCase().contains(lowerQuery) ||
          cafe.address.toLowerCase().contains(lowerQuery);
    }).toList();

    return matchingCafes.map((cafe) {
      return PlaceSuggestion(
        placeId: 'cafe_${cafe.id}',
        description: cafe.name,
        mainText: cafe.name,
        secondaryText: cafe.address,
        types: ['cafe', 'establishment'],
      );
    }).toList();
  }

  /// Selecionar um lugar da busca
  Future<Result<void>> _selectPlace(PlaceSuggestion suggestion) async {
    try {
      debugPrint('📍 Selecionado: ${suggestion.description}');

      clearSuggestions();

      // Verificar se é uma cafeteria cadastrada (placeId com prefixo "cafe_")
      if (suggestion.placeId.startsWith('cafe_')) {
        final cafeId = suggestion.placeId.replaceFirst('cafe_', '');
        final cafe = _allCafes.firstWhere((c) => c.id == cafeId);

        if (_isMapView) {
          // Modo mapa: apenas atualizar posição (o widget move a câmera)
          _currentPosition = cafe.position;
          notifyListeners();
        } else {
          // Modo lista: filtrar para mostrar apenas este café
          _visibleCafes = [cafe];
          _searchLocation = cafe.position;
          _searchAddress = cafe.address;
          _isShowingSearchResults = true;
          notifyListeners();
        }
      } else {
        // É um lugar do Google Places: buscar coordenadas
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

  /// Limpar sugestões
  void clearSuggestions() {
    _suggestions = [];
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

  /// Atualizar cafés no viewport
  void updateCafesInViewport(List<Cafe> cafes) {
    _cafesInViewport = cafes;
    notifyListeners();
  }

  /// Filtrar cafés dentro do raio do centro do mapa (modo lista)
  void _filterCafesByMapRadius() {
    _visibleCafes = _allCafes.where((cafe) {
      final distance = _calculateDistance(_currentPosition, cafe.position);
      return distance <= _filterRadiusKm;
    }).toList();

    notifyListeners();
  }

  /// Calcular distância entre dois pontos (em km)
  double _calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371;

    double dLat = _degreesToRadians(to.latitude - from.latitude);
    double dLng = _degreesToRadians(to.longitude - from.longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(from.latitude)) *
            math.cos(_degreesToRadians(to.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}