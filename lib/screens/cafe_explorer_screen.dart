import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_mappin.dart';
import '../widgets/custom_boxcafe_minicard.dart';

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
  
  TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isMapView = true; // true = mapa, false = lista
  int _selectedCafeIndex = 0;
  
  PageController _pageController = PageController();

  // Variáveis para controlar os pins customizados
  List<Widget> _customPins = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadMockCafes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
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

  void _loadMockCafes() {
    setState(() {
      _isLoading = true;
    });

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
    ];

    setState(() {
      _visibleCafes = List.from(_allCafes);
      _isLoading = false;
    });
    
    _updateCustomPins();
  }

  void _updateVisibleCafes() {
    setState(() {
      _visibleCafes = List.from(_allCafes);
    });
    _updateCustomPins();
  }

  // Função para converter coordenadas do mapa em posição na tela
  Future<Offset?> _getScreenPosition(LatLng latLng) async {
    if (_mapController == null) return null;
    
    try {
      final ScreenCoordinate screenCoordinate = await _mapController!.getScreenCoordinate(latLng);
      return Offset(screenCoordinate.x.toDouble(), screenCoordinate.y.toDouble());
    } catch (e) {
      return null;
    }
  }

  // Atualizar pins customizados
  void _updateCustomPins() async {
    if (_mapController == null) return;
    
    List<Widget> newPins = [];
    
    for (int i = 0; i < _visibleCafes.length; i++) {
      final cafe = _visibleCafes[i];
      final screenPosition = await _getScreenPosition(cafe.position);
      
      if (screenPosition != null) {
        newPins.add(
          Positioned(
            left: screenPosition.dx - 50, // Centralizar o pin
            top: screenPosition.dy - 16, // Ajustar altura
            child: CustomMapPin(
              cafeName: cafe.name,
              onTap: () => _onPinTapped(i),
            ),
          ),
        );
      }
    }
    
    setState(() {
      _customPins = newPins;
    });
  }

  void _onPinTapped(int index) {
    setState(() {
      _selectedCafeIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Aguardar um pouco antes de criar os pins customizados
    Future.delayed(Duration(milliseconds: 500), () {
      _updateCustomPins();
    });
  }

  void _onCameraMove(CameraPosition position) {
    _mapCenter = position.target;
  }

  void _onCameraIdle() {
    _updateVisibleCafes();
    // Atualizar posições dos pins após movimento da câmera
    Future.delayed(Duration(milliseconds: 100), () {
      _updateCustomPins();
    });
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
      _updateCustomPins();
    });
  }

  Widget _buildOverlaySearchBar() {
    return Container(
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
                decoration: InputDecoration(
                  hintText: 'Busque um cafeteria',
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
                onSubmitted: (value) => _performSearch(value),
              ),
            ),
          ),
          // Botão de busca
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
                  _performSearch(_searchController.text);
                },
                child: Center(
                  child: Icon(
                    Icons.search,
                    color: AppColors.whiteWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                // Número de cafeterias
                Text(
                  '${_visibleCafes.length}',
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
            markers: {}, // Sem marcadores padrão
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Pins customizados sobrepostos
          ..._customPins,

          // Barra de busca sobreposta no topo
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildOverlaySearchBar(),
          ),

          // Botões de toggle sobrepostos
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: _buildToggleButtons(),
          ),
          
          // Card de cafeteria na parte inferior
          if (_visibleCafes.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 141, // Altura atualizada para corresponder ao novo card
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedCafeIndex = index;
                    });
                    // Centralizar o mapa no café selecionado
                    if (_mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLng(_visibleCafes[index].position),
                      );
                    }
                  },
                  itemCount: _visibleCafes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: CustomBoxcafeMinicard(
                        cafe: _visibleCafes[index],
                        onTap: () {
                          print('Abrir detalhes da cafeteria: ${_visibleCafes[index].name}');
                          // TODO: Navegar para tela de detalhes
                        },
                      ),
                    );
                  },
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
            // Lista de cafeterias - seguindo exatamente a referência
            ListView.builder(
              padding: EdgeInsets.fromLTRB(20, 140, 20, 120), // Top padding para barra de busca e botões
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
              top: 80,
              left: 0,
              right: 0,
              child: _buildToggleButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCafeCard(CafeModel cafe) {
    return Container(
      height: 141, // Mesma altura do card da lista (109 + 32 de padding)
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(14), // 14px de radius igual ao da lista
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagem da cafeteria com radius de 8px
            Container(
              width: 109,
              height: 109,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // 8px de radius na foto
                image: DecorationImage(
                  image: NetworkImage(cafe.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Informações principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nome da cafeteria na cor velvet merlot
                  Text(
                    cafe.name,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.velvetMerlot, // Cor velvet merlot
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  
                  // Rating com ícone grain_note.svg
                  Row(
                    children: [
                      Text(
                        '${cafe.rating}',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayScale2,
                        ),
                      ),
                      SizedBox(width: 6),
                      // Usando o ícone grain_note.svg
                      ...List.generate(5, (starIndex) {
                        return Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: SvgPicture.asset(
                            'assets/images/grain_note.svg',
                            width: 12,
                            height: 12,
                            color: starIndex < cafe.rating.floor() 
                                ? AppColors.sunsetBlaze 
                                : AppColors.grayScale2.withOpacity(0.3),
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Endereço na cor Gray Scale 2
                  Text(
                    cafe.address,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: AppColors.grayScale2, // Cor Gray Scale 2
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Seta
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayScale2,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Card específico para ListView - seguindo exatamente a referência de design
  Widget _buildListCafeCard(CafeModel cafe) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(14), // 14px de radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagem da cafeteria com radius de 8px
            Container(
              width: 109,
              height: 109,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // 8px de radius na foto
                image: DecorationImage(
                  image: NetworkImage(cafe.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Informações principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nome da cafeteria na cor velvet merlot
                  Text(
                    cafe.name,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.velvetMerlot, // Cor velvet merlot
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  
                  // Rating com ícones de estrela
                  Row(
                    children: [
                      Text(
                        '${cafe.rating}',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayScale2,
                        ),
                      ),
                      SizedBox(width: 6),
                      // Usando estrelas normais do Material Icons
                      ...List.generate(5, (starIndex) {
                        return Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            starIndex < cafe.rating.floor() 
                                ? Icons.star 
                                : Icons.star_border,
                            size: 12,
                            color: starIndex < cafe.rating.floor() 
                                ? AppColors.sunsetBlaze 
                                : AppColors.grayScale2.withOpacity(0.3),
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Endereço na cor Gray Scale 2
                  Text(
                    cafe.address,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: AppColors.grayScale2, // Cor Gray Scale 2
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Seta
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayScale2,
              size: 16,
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
          
          // Navbar na parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                print('Abrir menu sidebar');
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