import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_boxcafe_minicard.dart';
import '../widgets/side_menu_overlay.dart'; // LINHA ADICIONADA

// Modelo para sugestões de lugares
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types; // Adicionar tipos para identificar estabelecimentos

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    this.types = const [],
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  // Verificar se é um estabelecimento (café, restaurante, loja, etc.)
  bool get isEstablishment {
    return types.any((type) => [
      'establishment',
      'food',
      'restaurant',
      'cafe',
      'meal_takeaway',
      'meal_delivery',
      'store',
      'point_of_interest'
    ].contains(type));
  }

  // Ícone baseado no tipo
  Widget get iconWidget {
    if (isEstablishment) {
      // SVG para estabelecimentos (cafés, restaurantes, etc.)
      return SvgPicture.asset(
        'assets/images/search-store.svg',
        width: 20,
        height: 20,
      );
    } else {
      // SVG para endereços/localizações
      return SvgPicture.asset(
        'assets/images/search_location.svg',
        width: 20,
        height: 20,
      );
    }
  }
}

class CafeModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String imageUrl;
  final bool isOpen;
  final LatLng position;
  final String price;
  final List<String> specialties;

  CafeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.isOpen,
    required this.position,
    required this.price,
    required this.specialties,
  });
}

// Classe para gerenciar grupos de pins (cluster ou individual)
class PinGroup {
  final List<CafeModel> cafes;
  final LatLng position;
  final bool isCluster;

  PinGroup.single(CafeModel cafe)
      : cafes = [cafe],
        position = cafe.position,
        isCluster = false;

  PinGroup.cluster(this.cafes)
      : position = _calculateCenterPosition(cafes),
        isCluster = true;

  static LatLng _calculateCenterPosition(List<CafeModel> cafes) {
    double lat = cafes.map((c) => c.position.latitude).reduce((a, b) => a + b) / cafes.length;
    double lng = cafes.map((c) => c.position.longitude).reduce((a, b) => a + b) / cafes.length;
    return LatLng(lat, lng);
  }

  int get count => cafes.length;
}

// Gerenciador de clustering simples e otimizado
class SmartClusterManager {
  static const double CLUSTER_DISTANCE_KM = 0.2; // 200 metros
  static const double MIN_ZOOM_FOR_CLUSTERING = 18.0; // Clustering aparece bem tarde

  static List<PinGroup> groupPins(List<CafeModel> cafes, double currentZoom) {
    // Se zoom alto, mostrar pins individuais
    if (currentZoom >= MIN_ZOOM_FOR_CLUSTERING) {
      return cafes.map((cafe) => PinGroup.single(cafe)).toList();
    }

    // Fazer clustering
    List<PinGroup> groups = [];
    List<CafeModel> remaining = List.from(cafes);

    while (remaining.isNotEmpty) {
      CafeModel center = remaining.removeAt(0);
      List<CafeModel> nearby = [center];

      // Encontrar cafés próximos
      remaining.removeWhere((cafe) {
        double distance = _calculateDistanceKm(center.position, cafe.position);
        if (distance <= CLUSTER_DISTANCE_KM) {
          nearby.add(cafe);
          return true;
        }
        return false;
      });

      // Criar grupo
      if (nearby.length > 1) {
        groups.add(PinGroup.cluster(nearby));
      } else {
        groups.add(PinGroup.single(center));
      }
    }

    return groups;
  }

  static double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

// Serviço para Google Places API
class GooglePlacesService {
  static const String apiKey = 'AIzaSyB3s5D0-HxAGvqK9UlVfYeooYUsjbIZcJM';
  static const String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // Proxy CORS para desenvolvimento web
  static const String corsProxy = 'https://api.allorigins.win/raw?url=';

  // Buscar sugestões de endereços
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(String input) async {
    print('🔍 Buscando sugestões para: "$input"');
    
    if (input.trim().isEmpty) return [];

    final String originalUrl = '$baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&types=establishment|geocode'  // Inclui estabelecimentos E endereços
        '&components=country:br'
        '&language=pt-BR'
        '&key=$apiKey';
    
    // Use proxy apenas para web, URL original para mobile
    final String url = kIsWeb ? '$corsProxy${Uri.encodeComponent(originalUrl)}' : originalUrl;

    try {
      print('📡 Fazendo request para: ${kIsWeb ? "PROXY" : "DIRETO"}');
      final response = await http.get(Uri.parse(url));
      
      print('📥 Status da resposta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 Dados da resposta: ${data['status']}');
        
        if (data['status'] == 'OK') {
          List<PlaceSuggestion> suggestions = [];
          for (var prediction in data['predictions']) {
            suggestions.add(PlaceSuggestion.fromJson(prediction));
          }
          print('✅ Encontradas ${suggestions.length} sugestões');
          return suggestions;
        } else {
          print('❌ Erro na API: ${data['status']} - ${data['error_message'] ?? 'Sem detalhes'}');
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao buscar sugestões: $e');
    }
    
    return [];
  }

  // Obter coordenadas de um place_id
  static Future<LatLng?> getPlaceCoordinates(String placeId) async {
    print('📍 Obtendo coordenadas para placeId: $placeId');
    
    final String originalUrl = '$baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey';
    
    // Use proxy apenas para web, URL original para mobile
    final String url = kIsWeb ? '$corsProxy${Uri.encodeComponent(originalUrl)}' : originalUrl;

    try {
      print('📡 Fazendo request para coordenadas...');
      final response = await http.get(Uri.parse(url));
      
      print('📥 Status da resposta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📋 Status da API: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          LatLng coordinates = LatLng(location['lat'], location['lng']);
          print('✅ Coordenadas encontradas: ${coordinates.latitude}, ${coordinates.longitude}');
          return coordinates;
        } else {
          print('❌ Erro na API: ${data['status']} - ${data['error_message'] ?? 'Sem detalhes'}');
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao obter coordenadas: $e');
    }
    
    return null;
  }
}

class CafeExplorerScreen extends StatefulWidget {
  @override
  _CafeExplorerScreenState createState() => _CafeExplorerScreenState();
}

class _CafeExplorerScreenState extends State<CafeExplorerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(-23.5505, -46.6333); // São Paulo default
  LatLng _mapCenter = LatLng(-23.5505, -46.6333);
  Set<Marker> _markers = {};
  
  List<CafeModel> _allCafes = [];
  List<CafeModel> _visibleCafes = [];
  List<CafeModel> _cafesInViewport = []; // Cafés visíveis na tela
  
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isMapView = true; // true = mapa, false = lista
  int _selectedCafeIndex = 0;
  
  PageController _pageController = PageController();

  // Para clustering
  double _currentZoom = 15.0;
  BitmapDescriptor? _customPin;
  List<Widget> _pinLabels = []; // Labels dos pins

  // Para Place Picker
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingPlaces = false;
  String _lastSearchQuery = ''; // Para evitar buscas duplicadas
  Timer? _searchTimer; // Para debounce
  
  // Para busca por localização na lista
  LatLng? _lastSearchLocation;
  String _lastSearchAddress = '';
  bool _isShowingSearchResults = false;

  // Para sincronização mapa-carrossel
  ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadMockCafes();
    
    // Listener para busca de lugares
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    _horizontalScrollController.dispose(); // Adicionar dispose do novo controller
    _searchTimer?.cancel(); // Cancelar timer pendente
    super.dispose();
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text.trim();
    
    // Evitar buscas duplicadas
    if (currentQuery == _lastSearchQuery) return;
    
    // Cancelar timer anterior se existir
    _searchTimer?.cancel();
    
    if (currentQuery.isNotEmpty) {
      // Debounce: aguardar 500ms antes de fazer a busca
      _searchTimer = Timer(Duration(milliseconds: 500), () {
        _searchPlaces(currentQuery);
      });
    } else {
      setState(() {
        _placeSuggestions = [];
        _showSuggestions = false;
        _lastSearchQuery = '';
      });
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.trim().isNotEmpty) {
      setState(() {
        _showSuggestions = true;
      });
    }
  }

  // Buscar lugares usando Google Places API
  Future<void> _searchPlaces(String query) async {
    // Atualizar último termo buscado
    _lastSearchQuery = query;
    
    setState(() {
      _isLoadingPlaces = true;
    });

    try {
      List<PlaceSuggestion> suggestions = await GooglePlacesService.getPlaceSuggestions(query);
      
      // Verificar se ainda é a busca mais recente
      if (_lastSearchQuery == query) {
        setState(() {
          _placeSuggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      print('❌ Erro na busca de lugares: $e');
      if (_lastSearchQuery == query) {
        setState(() {
          _isLoadingPlaces = false;
          _showSuggestions = false;
        });
      }
    }
  }

  // Selecionar um lugar da lista de sugestões
  Future<void> _selectPlace(PlaceSuggestion suggestion) async {
    print('📍 Lugar selecionado: ${suggestion.description}');
    
    setState(() {
      _showSuggestions = false;
      _searchController.text = suggestion.description;
      _isLoadingPlaces = true;
    });

    // Remover foco do campo de busca
    _searchFocusNode.unfocus();

    try {
      // Obter coordenadas do lugar selecionado
      LatLng? coordinates = await GooglePlacesService.getPlaceCoordinates(suggestion.placeId);
      
      if (coordinates != null) {
        print('🗺️ Coordenadas encontradas: ${coordinates.latitude}, ${coordinates.longitude}');
        
        if (_isMapView) {
          // **MODO MAPA**: Navegar para o local no mapa
          if (_mapController != null) {
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(coordinates, 16.0),
            );
            
            setState(() {
              _mapCenter = coordinates;
            });
            
            // Atualizar cafés visíveis baseado na nova localização
            _updateVisibleCafes();
            print('✅ Navegação no mapa concluída!');
          }
        } else {
          // **MODO LISTA**: Filtrar cafeterias próximas ao endereço
          _filterCafesByLocation(coordinates, suggestion.description);
        }
      } else {
        print('❌ Não foi possível obter coordenadas para este local');
      }
    } catch (e) {
      print('❌ Erro ao processar lugar selecionado: $e');
    }

    setState(() {
      _isLoadingPlaces = false;
    });
  }

  // Filtrar cafeterias por localização (para modo lista)
  void _filterCafesByLocation(LatLng searchLocation, String searchAddress) {
    print('📍 Filtrando cafeterias próximas a: $searchAddress');
    
    const double maxDistanceKm = 2.0; // Raio de 2km para busca
    
    List<CafeModel> nearbyCafes = _allCafes.where((cafe) {
      double distance = SmartClusterManager._calculateDistanceKm(
        searchLocation, 
        cafe.position
      );
      return distance <= maxDistanceKm;
    }).toList();

    // Ordenar por distância (mais próximos primeiro)
    nearbyCafes.sort((a, b) {
      double distanceA = SmartClusterManager._calculateDistanceKm(searchLocation, a.position);
      double distanceB = SmartClusterManager._calculateDistanceKm(searchLocation, b.position);
      return distanceA.compareTo(distanceB);
    });

    print('✅ Encontradas ${nearbyCafes.length} cafeterias próximas');

    setState(() {
      _visibleCafes = nearbyCafes;
      _lastSearchLocation = searchLocation;
      _lastSearchAddress = searchAddress;
      _isShowingSearchResults = true; // Indica que estamos mostrando resultados de busca
    });
  }

  // Limpar busca e voltar ao estado inicial
  void _clearSearch() {
    setState(() {
      _visibleCafes = List.from(_allCafes);
      _lastSearchLocation = null;
      _lastSearchAddress = '';
      _isShowingSearchResults = false;
      _searchController.clear();
    });
  }

  Future<void> _initializeLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _mapCenter = _currentPosition;
        });
        _updateVisibleCafes();
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  void _loadMockCafes() async {
    setState(() {
      _isLoading = true;
    });

    // Carregar o pin customizado
    _customPin = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/pin_kafex.svg',
    );

    // Dados mock baseados na referência
    _allCafes = [
      CafeModel(
        id: '1',
        name: 'Coffeelab',
        address: 'R. Fradique Coutinho, 1340 - Vila Madalena, São Paulo - SP, 05416-001',
        rating: 4.8,
        distance: '200m',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        isOpen: true,
        position: LatLng(-23.5505, -46.6333),
        price: 'R\$ 15-25',
        specialties: ['Espresso', 'Latte Art', 'Doces'],
      ),
      CafeModel(
        id: '2',
        name: 'Santo Grão',
        address: 'Av. Rebouças, 456 - Pinheiros, São Paulo',
        rating: 4.6,
        distance: '350m',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        isOpen: true,
        position: LatLng(-23.5515, -46.6343),
        price: 'R\$ 12-20',
        specialties: ['Café Gelado', 'Filtrado', 'Tortas'],
      ),
      CafeModel(
        id: '3',
        name: 'Café do Centro',
        address: 'Rua Augusta, 789 - Consolação, São Paulo',
        rating: 4.4,
        distance: '500m',
        imageUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400',
        isOpen: false,
        position: LatLng(-23.5495, -46.6323),
        price: 'R\$ 10-18',
        specialties: ['Cappuccino', 'Prensado', 'Lanches'],
      ),
      CafeModel(
        id: '4',
        name: 'Blend Coffee',
        address: 'Rua dos Pinheiros, 321 - Pinheiros, São Paulo',
        rating: 4.9,
        distance: '1.2km',
        imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400',
        isOpen: true,
        position: LatLng(-23.5525, -46.6353),
        price: 'R\$ 18-30',
        specialties: ['Grãos Especiais', 'V60', 'Chemex'],
      ),
      CafeModel(
        id: '5',
        name: 'The Coffee',
        address: 'Rua Harmonia, 123 - Vila Madalena, São Paulo',
        rating: 4.7,
        distance: '800m',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
        isOpen: true,
        position: LatLng(-23.5485, -46.6313),
        price: 'R\$ 14-22',
        specialties: ['Cappuccino', 'Croissant', 'WiFi'],
      ),
      // Adicionando mais cafés para demonstrar clustering
      CafeModel(
        id: '6',
        name: 'Café Próximo 1',
        address: 'Rua Próxima, 100',
        rating: 4.3,
        distance: '150m',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        isOpen: true,
        position: LatLng(-23.5508, -46.6330), // Próximo ao Coffeelab
        price: 'R\$ 12-18',
        specialties: ['Cappuccino'],
      ),
      CafeModel(
        id: '7',
        name: 'Café Próximo 2',
        address: 'Rua Próxima, 200',
        rating: 4.1,
        distance: '180m',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        isOpen: true,
        position: LatLng(-23.5502, -46.6336), // Próximo ao Coffeelab
        price: 'R\$ 10-16',
        specialties: ['Expresso'],
      ),
    ];

    setState(() {
      _visibleCafes = List.from(_allCafes);
      _isLoading = false;
    });
    
    _updateMarkers();
  }

  void _updateVisibleCafes() {
    setState(() {
      _visibleCafes = List.from(_allCafes);
    });
    _updateMarkers();
  }

  // Criar marcadores com clustering inteligente
  void _updateMarkers() async {
    if (_customPin == null) return;

    List<PinGroup> groups = SmartClusterManager.groupPins(_visibleCafes, _currentZoom);
    Set<Marker> newMarkers = {};

    for (int i = 0; i < groups.length; i++) {
      PinGroup group = groups[i];
      
      if (group.isCluster) {
        // Criar marker de cluster
        BitmapDescriptor clusterIcon = await _createClusterIcon(group.count);
        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_$i'),
            position: group.position,
            icon: clusterIcon,
            onTap: () => _onClusterTapped(group),
          ),
        );
      } else {
        // Criar marker individual
        CafeModel cafe = group.cafes.first;
        int cafeIndex = _visibleCafes.indexOf(cafe);
        newMarkers.add(
          Marker(
            markerId: MarkerId(cafe.id),
            position: cafe.position,
            icon: _customPin!,
            onTap: () => _onPinTapped(cafeIndex),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
    });

    // Atualizar labels dos pins
    _updatePinLabels();
  }

  // Atualizar labels dos pins
  void _updatePinLabels() async {
    if (_mapController == null) return;

    List<Widget> newLabels = [];

    // Apenas mostrar labels para pins individuais (não clusters)
    List<PinGroup> groups = SmartClusterManager.groupPins(_visibleCafes, _currentZoom);
    
    for (PinGroup group in groups) {
      if (!group.isCluster) {
        CafeModel cafe = group.cafes.first;
        
        try {
          // Converter posição do mapa para coordenadas da tela
          ScreenCoordinate screenCoord = await _mapController!.getScreenCoordinate(cafe.position);
          
          // Truncar nome para 14 caracteres
          String displayName = cafe.name.length > 14 
              ? '${cafe.name.substring(0, 14)}...' 
              : cafe.name;
          
          newLabels.add(
            Positioned(
              left: screenCoord.x.toDouble(),
              top: screenCoord.y.toDouble() - 60, // Posicionar acima do pin
              child: FractionalTranslation(
                translation: Offset(-0.5, 0), // Centralizar perfeitamente (move 50% para a esquerda)
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.velvetMerlot,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteWhite,
                    ),
                  ),
                ),
              ),
            ),
          );
        } catch (e) {
          // Se falhar ao obter coordenadas, pular este label
          continue;
        }
      }
    }

    setState(() {
      _pinLabels = newLabels;
    });
  }

  // Criar ícone de cluster customizado
  Future<BitmapDescriptor> _createClusterIcon(int count) async {
    final String clusterText = count > 99 ? "99+" : count.toString();
    
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    
    // Círculo externo (papaya sensorial com 20% de opacidade)
    final Paint outerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Círculo interno (papaya sensorial)
    final Paint innerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial
      ..style = PaintingStyle.fill;
    
    // Desenhar círculo externo maior
    canvas.drawCircle(Offset(30, 30), 30, outerCirclePaint);
    
    // Desenhar círculo interno menor
    canvas.drawCircle(Offset(30, 30), 18, innerCirclePaint);
    
    // Desenhar texto
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: clusterText,
        style: TextStyle(
          fontSize: count > 99 ? 12 : 14,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteWhite,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(30 - textPainter.width / 2, 30 - textPainter.height / 2),
    );
    
    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image img = await picture.toImage(60, 60);
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _onClusterTapped(PinGroup cluster) {
    // Calcular bounds para mostrar todos os cafés do cluster
    double minLat = cluster.cafes.first.position.latitude;
    double maxLat = cluster.cafes.first.position.latitude;
    double minLng = cluster.cafes.first.position.longitude;
    double maxLng = cluster.cafes.first.position.longitude;
    
    for (CafeModel cafe in cluster.cafes) {
      minLat = math.min(minLat, cafe.position.latitude);
      maxLat = math.max(maxLat, cafe.position.latitude);
      minLng = math.min(minLng, cafe.position.longitude);
      maxLng = math.max(maxLng, cafe.position.longitude);
    }
    
    // Dar zoom para mostrar todos os pins do cluster
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _onPinTapped(int index) {
    // Encontrar o índice da cafeteria no viewport atual
    CafeModel selectedCafe = _visibleCafes[index];
    int viewportIndex = _cafesInViewport.indexWhere((cafe) => cafe.id == selectedCafe.id);
    
    if (viewportIndex != -1) {
      setState(() {
        _selectedCafeIndex = viewportIndex;
      });
      
      // Rolar o carrossel para a cafeteria selecionada
      _scrollToSelectedCafe(viewportIndex);
    }
  }

  // Método para rolar o carrossel para a cafeteria selecionada
  void _scrollToSelectedCafe(int index) {
    if (_horizontalScrollController.hasClients) {
      double screenWidth = MediaQuery.of(context).size.width;
      double cardWidth = screenWidth * 0.9; // 90% da largura da tela
      double spacing = 12.0; // Espaçamento entre cards
      double totalCardWidth = cardWidth + spacing;
      
      double targetOffset = index * totalCardWidth;
      
      _horizontalScrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkers();
    // Aguardar um pouco e depois atualizar viewport inicial
    Future.delayed(Duration(milliseconds: 500), () {
      _updateCafesInViewport();
    });
  }

  void _onCameraMove(CameraPosition position) {
    _mapCenter = position.target;
    _currentZoom = position.zoom;
  }

  void _onCameraIdle() {
    _updateVisibleCafes();
    _updateCafesInViewport(); // Atualizar cafés no viewport
    _updateMarkers();
    // Atualizar labels após movimento da câmera
    Future.delayed(Duration(milliseconds: 100), () {
      _updatePinLabels();
    });
  }

  // Atualizar cafés visíveis no viewport atual
  void _updateCafesInViewport() async {
    if (_mapController == null) return;

    try {
      // Obter bounds visíveis do mapa
      LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
      
      // Filtrar cafés que estão dentro dos bounds
      List<CafeModel> cafesInView = _visibleCafes.where((cafe) {
        return _isLocationInBounds(cafe.position, visibleRegion);
      }).toList();

      setState(() {
        _cafesInViewport = cafesInView;
      });
    } catch (e) {
      print('Erro ao obter região visível: $e');
      // Fallback: usar todos os cafés visíveis
      setState(() {
        _cafesInViewport = _visibleCafes;
      });
    }
  }

  // Verificar se uma localização está dentro dos bounds
  bool _isLocationInBounds(LatLng location, LatLngBounds bounds) {
    return location.latitude >= bounds.southwest.latitude &&
           location.latitude <= bounds.northeast.latitude &&
           location.longitude >= bounds.southwest.longitude &&
           location.longitude <= bounds.northeast.longitude;
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simular busca com delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _visibleCafes = _allCafes.where((cafe) =>
          cafe.name.toLowerCase().contains(query.toLowerCase()) ||
          cafe.address.toLowerCase().contains(query.toLowerCase()) ||
          cafe.specialties.any((specialty) =>
            specialty.toLowerCase().contains(query.toLowerCase()))
        ).toList();
        _isSearching = false;
      });
      _updateMarkers();
    });
  }

  // ⭐ NOVA BARRA DE BUSCA COM PLACE PICKER
  Widget _buildOverlaySearchBar() {
    return Container(
      child: Column(
        children: [
          // Barra de busca principal
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Campo de texto
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Busque endereços, cafés ou estabelecimentos',
                        hintStyle: GoogleFonts.albertSans(
                          color: AppColors.grayScale2,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.carbon,
                      ),
                      cursorColor: AppColors.papayaSensorial,
                      onSubmitted: (value) {
                        // Se for busca de endereço, usar o primeiro resultado
                        if (_placeSuggestions.isNotEmpty) {
                          _selectPlace(_placeSuggestions.first);
                        }
                      },
                    ),
                  ),
                ),
                // Botão de busca com loading
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: AppColors.papayaSensorial,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (_placeSuggestions.isNotEmpty) {
                          _selectPlace(_placeSuggestions.first);
                        }
                      },
                      child: Center(
                        child: _isLoadingPlaces
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.whiteWhite,
                                  ),
                                ),
                              )
                            : SvgPicture.asset(
                                'assets/images/search.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  AppColors.whiteWhite,
                                  BlendMode.srcIn,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget separado para o dropdown de sugestões com z-index alto
  Widget _buildSuggestionsDropdown() {
    if (!_showSuggestions || _placeSuggestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Positioned(
      top: 74, // Logo abaixo da barra de busca (16 + 50 + 8)
      left: 16,
      right: 16,
      child: Material( // Material widget garante que fique na frente
        elevation: 8, // Sombra mais alta
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Sombra mais forte
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: math.min(_placeSuggestions.length, 5), // Máximo 5 sugestões
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.moonAsh,
            ),
            itemBuilder: (context, index) {
              final suggestion = _placeSuggestions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectPlace(suggestion),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Usar o widget SVG customizado com cores
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            suggestion.isEstablishment 
                                ? AppColors.papayaSensorial  // Laranja para estabelecimentos
                                : AppColors.grayScale1,       // Cinza para endereços
                            BlendMode.srcIn,
                          ),
                          child: suggestion.iconWidget,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.mainText,
                                style: GoogleFonts.albertSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.carbon,
                                ),
                              ),
                              if (suggestion.secondaryText.isNotEmpty)
                                Text(
                                  suggestion.secondaryText,
                                  style: GoogleFonts.albertSans(
                                    fontSize: 12,
                                    color: AppColors.grayScale1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Badge para estabelecimentos
                        if (suggestion.isEstablishment)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.papayaSensorial.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Local',
                              style: GoogleFonts.albertSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Container do switch com background
          Container(
            padding: EdgeInsets.all(4), // 4px de distância entre os botões
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botão Mapa
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMapView = true;
                    });
                    // Limpar busca ao mudar para modo mapa se estivermos mostrando resultados de busca
                    if (_isShowingSearchResults) {
                      _clearSearch();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isMapView ? AppColors.papayaSensorial : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Mapa',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isMapView ? AppColors.whiteWhite : AppColors.grayScale1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4), // 4px de espaço entre os botões
                // Botão Lista
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMapView = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isMapView ? AppColors.papayaSensorial : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Lista',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: !_isMapView ? AppColors.whiteWhite : AppColors.grayScale1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Spacer(),
          
          // Contador de cafeterias - seguindo a referência
          Container(
            height: 48, // Mesma altura dos botões Mapa/Lista
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone do pin do mapa
                SvgPicture.asset(
                  'assets/images/icon-pin-map.svg',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                // Número de cafeterias - dinâmico baseado na view
                Text(
                  '${_isMapView ? _cafesInViewport.length : _visibleCafes.length}',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Expanded(
      child: Stack(
        children: [
          // Mapa em tela cheia
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _markers, // Usando marcadores com clustering
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) {
              // Fechar sugestões ao tocar no mapa
              setState(() {
                _showSuggestions = false;
              });
              _searchFocusNode.unfocus();
            },
          ),

          // Labels dos pins sobrepostos
          ..._pinLabels,

          // Barra de busca sobreposta no topo
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildOverlaySearchBar(),
          ),

          // Botões de toggle sobrepostos
          Positioned(
            top: 80, // Voltando para posição original
            left: 0,
            right: 0,
            child: _buildToggleButtons(),
          ),

          // Dropdown de sugestões com z-index alto (separado)
          _buildSuggestionsDropdown(),
          
          // Lista horizontal de cafeterias na parte inferior
          if (_cafesInViewport.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 141,
                child: Builder(
                  builder: (context) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double cardWidth = screenWidth * 0.9; // 90% da largura da tela
                    
                    return ListView.builder(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% de cada lado
                      itemCount: _cafesInViewport.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: cardWidth,
                          margin: EdgeInsets.only(right: 12), // Espaçamento entre cards
                          child: CustomBoxcafeMinicard(
                            cafe: _cafesInViewport[index],
                            onTap: () {
                              print('Abrir detalhes da cafeteria: ${_cafesInViewport[index].name}');
                              
                              // Atualizar índice selecionado
                              setState(() {
                                _selectedCafeIndex = index;
                              });
                              
                              // Centralizar o mapa na cafeteria selecionada
                              if (_mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    _cafesInViewport[index].position,
                                    16.0, // Zoom mais próximo para destacar a cafeteria
                                  ),
                                );
                              }
                              
                              // TODO: Navegar para tela de detalhes
                            },
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: Container(
        color: AppColors.oatWhite,
        child: Stack(
          children: [
            // Conteúdo da lista
            if (_visibleCafes.isNotEmpty)
              // Lista de cafeterias
              ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 180, 20, 120), // Padding aumentado de 160 para 180
                itemCount: _visibleCafes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: CustomBoxcafeMinicard(
                      cafe: _visibleCafes[index],
                      onTap: () {
                        print('Abrir detalhes da cafeteria: ${_visibleCafes[index].name}');
                        // TODO: Navegar para tela de detalhes
                      },
                    ),
                  );
                },
              )
            else if (_isShowingSearchResults)
              // Mensagem de "nenhum resultado" quando busca não retorna resultados
              _buildNoResultsMessage()
            else
              // Lista vazia (estado inicial)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Text(
                    'Carregando cafeterias...',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.grayScale1,
                    ),
                  ),
                ),
              ),
            
            // Barra de busca sobreposta no topo
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildOverlaySearchBar(),
            ),

            // Botões de toggle sobrepostos
            Positioned(
              top: 80, // Voltando para posição original
              left: 0,
              right: 0,
              child: _buildToggleButtons(),
            ),

            // Dropdown de sugestões com z-index alto (separado)
            _buildSuggestionsDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de busca vazia
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.grayScale2,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Título
            Text(
              'Ops, não encontrei nenhum resultado na sua busca',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: 12),
            
            // Subtítulo com endereço buscado
            if (_lastSearchAddress.isNotEmpty)
              Text(
                'Nenhuma cafeteria encontrada próxima a:\n"${_lastSearchAddress}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),
            
            SizedBox(height: 24),
            
            // Botão para tentar nova busca
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.papayaSensorial,
                  foregroundColor: AppColors.whiteWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Ver todas as cafeterias',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Dica de busca
            Text(
              'Tente buscar por um endereço diferente ou veja todas as cafeterias disponíveis.',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 12,
                color: AppColors.grayScale2,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Conteúdo principal
          Column(
            children: [
              // Conteúdo baseado no modo selecionado
              if (_isMapView) _buildMapView() else _buildListView(),
            ],
          ),
          
          // Navbar na parte inferior - MUDANÇA AQUI
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              isInCafeExplorer: true, // Indica que estamos na tela de exploração
              onMenuPressed: () {
                print('Abrir menu sidebar');
                showSideMenu(context); // LINHA ADICIONADA
              },
              onSearchPressed: () {
                print('Já estamos na tela de busca');
              },
            ),
          ),
        ],
      ),
    );
  }
}