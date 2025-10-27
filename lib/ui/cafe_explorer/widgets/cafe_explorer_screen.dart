// lib/ui/cafe_explorer/widgets/cafe_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/side_menu_overlay.dart';
import '../../../services/location_service.dart';
import '../../../data/repositories/cafe_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/services/clustering_service.dart';
import '../viewmodel/cafe_explorer_viewmodel.dart';
import 'search/search_bar.dart';
import 'search/suggestions_list.dart';
import 'shared/view_toggle.dart';
import 'shared/cafe_counter.dart';
import 'shared/cafe_carousel.dart';
import 'map/cafe_map_view.dart';
import 'list/cafe_list_view.dart';

class CafeExplorerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CafeExplorerViewModel(
        cafeRepository: CafeRepositoryImpl(),
        placesRepository: PlacesRepositoryImpl(),
        clusteringService: ClusteringService(),
      ),
      child: _CafeExplorerContent(),
    );
  }
}

class _CafeExplorerContent extends StatefulWidget {
  @override
  _CafeExplorerContentState createState() => _CafeExplorerContentState();
}

class _CafeExplorerContentState extends State<_CafeExplorerContent> {
  GoogleMapController? _mapController;
  PageController? _carouselPageController;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _horizontalScrollController = ScrollController();
  
  bool _hasRequestedLocation = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNativeLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _requestNativeLocation() async {
    if (_hasRequestedLocation) return;
    _hasRequestedLocation = true;

    try {
      debugPrint('📍 Solicitando localização nativa...');
      
      final location = await LocationService.instance.getCurrentLocation();
      
      if (location != null && mounted) {
        final viewModel = context.read<CafeExplorerViewModel>();
        final position = LatLng(location.latitude, location.longitude);
        
        debugPrint('✅ Localização obtida: ${location.latitude}, ${location.longitude}');
        
        await viewModel.saveUserLocation(position);
        
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(position, 15.0),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao obter localização: $e');
    }
  }

  Future<void> _centerOnUserLocation() async {
    try {
      final location = await LocationService.instance.getCurrentLocation();
      
      if (location != null && _mapController != null) {
        final position = LatLng(location.latitude, location.longitude);
        
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(position, 15.0),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao centralizar: $e');
    }
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      final viewModel = context.read<CafeExplorerViewModel>();
      viewModel.clearSuggestions();
    }
  }

  void _performSearch() {
    final viewModel = context.read<CafeExplorerViewModel>();
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      viewModel.searchPlaces.execute(query);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    final viewModel = context.read<CafeExplorerViewModel>();

    if (viewModel.currentPosition.latitude != -23.5505 ||
        viewModel.currentPosition.longitude != -46.6333) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(viewModel.currentPosition, 15.0),
      );
    }

    Future.delayed(Duration(milliseconds: 500), _updateCafesInViewport);
  }

  void _onCameraMove(CameraPosition position) {
    final viewModel = context.read<CafeExplorerViewModel>();
    viewModel.updateMapCenter(position.target);
    viewModel.updateZoom(position.zoom);
  }

  void _onCameraIdle() {
    _updateCafesInViewport();
  }

  Future<void> _updateCafesInViewport() async {
    if (_mapController == null) return;

    try {
      final viewModel = context.read<CafeExplorerViewModel>();
      LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();

      final cafesInView = viewModel.visibleCafes.where((cafe) {
        return cafe.position.latitude >= visibleRegion.southwest.latitude &&
            cafe.position.latitude <= visibleRegion.northeast.latitude &&
            cafe.position.longitude >= visibleRegion.southwest.longitude &&
            cafe.position.longitude <= visibleRegion.northeast.longitude;
      }).toList();

      viewModel.updateCafesInViewport(cafesInView);
    } catch (e) {
      debugPrint('Erro ao obter região visível: $e');
    }
  }

  void _onPinTapped(int index) {
    final viewModel = context.read<CafeExplorerViewModel>();
    final selectedCafe = viewModel.visibleCafes[index];
    
    int viewportIndex = viewModel.cafesInViewport.indexWhere(
      (c) => c.id == selectedCafe.id,
    );

    if (viewportIndex != -1) {
      if (_carouselPageController != null && _carouselPageController!.hasClients) {
        _carouselPageController!.animateToPage(
          viewportIndex,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(selectedCafe.position),
        );
      }
    }
  }

  void _onCarouselCafeTap(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(position, 16.0),
      );
    }
  }

  void _onCarouselPageChanged(int index) {
    final viewModel = context.read<CafeExplorerViewModel>();
    
    if (index < viewModel.cafesInViewport.length) {
      final cafe = viewModel.cafesInViewport[index];
      
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(cafe.position),
        );
      }
    }
  }

  void _handleSuggestionSelected() {
    Future.delayed(Duration(milliseconds: 800), () {
      _updateCafesInViewport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.oatWhite,
        appBar: CustomAppBar(),
        body: Consumer<CafeExplorerViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                // MAPA/LISTA EM TELA CHEIA (atrás de tudo)
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Visibility(
                            visible: viewModel.isMapView,
                            maintainState: true,
                            maintainAnimation: true,
                            maintainSize: false,
                            child: _buildMapView(viewModel),
                          ),
                          Visibility(
                            visible: !viewModel.isMapView,
                            maintainState: true,
                            maintainAnimation: true,
                            maintainSize: false,
                            child: _buildListView(viewModel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // OVERLAY COM SEARCHBAR E CONTROLES (na frente, fora do Positioned)
                SafeArea(
                  child: Column(
                    children: [
                      // SearchBar no topo
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: CafeSearchBar(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          viewModel: viewModel,
                          onSearch: _performSearch,
                        ),
                      ),
                      
                      // Controles (toggle + counter)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            ViewToggle(
                              isMapView: viewModel.isMapView,
                              onToggle: () => viewModel.toggleView(),
                            ),
                            Spacer(),
                            CafeCounter(count: viewModel.cafesInViewport.length),
                          ],
                        ),
                      ),
                      
                      // Espaço flexível restante
                      Spacer(),
                    ],
                  ),
                ),
                
                // SUGGESTIONS em Positioned para sobrepor os controles
                Positioned(
                  top: 74, // Logo abaixo do SearchBar
                  left: 0,
                  right: 0,
                  // Altura máxima: deixa espaço apenas para o bottom navbar
                  bottom: 80, // Espaço apenas para o navbar
                  child: SuggestionsList(
                    viewModel: viewModel,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    mapController: _mapController,
                    onSuggestionSelected: _handleSuggestionSelected,
                  ),
                ),
                
                // Bottom navbar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomBottomNavbar(
                    isInCafeExplorer: true,
                    onMenuPressed: () => showSideMenu(context),
                    onSearchPressed: () {},
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapView(CafeExplorerViewModel viewModel) {
    return Stack(
      children: [
        CafeMapView(
          cafes: viewModel.visibleCafes,
          initialPosition: viewModel.currentPosition,
          initialZoom: 15.0,
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          onPinTap: _onPinTapped,
          onMapTap: () {
            viewModel.clearSuggestions();
            _searchFocusNode.unfocus();
          },
        ),
        Positioned(
          right: 16,
          bottom: 200,
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteWhite,
            child: InkWell(
              onTap: _centerOnUserLocation,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.my_location,
                  size: 20,
                  color: AppColors.grayScale1,
                ),
              ),
            ),
          ),
        ),
        if (viewModel.cafesInViewport.isNotEmpty)
          CafeCarousel(
            cafes: viewModel.cafesInViewport,
            scrollController: _horizontalScrollController,
            onCafeTap: _onCarouselCafeTap,
            onPageChanged: _onCarouselPageChanged,
            onPageControllerCreated: (controller) {
              _carouselPageController = controller;
            },
          ),
      ],
    );
  }

  Widget _buildListView(CafeExplorerViewModel viewModel) {
    return CafeListView(
      cafes: viewModel.cafesInViewport,
      isShowingSearchResults: viewModel.isShowingSearchResults,
      searchAddress: viewModel.searchAddress,
      onClearSearch: () {
        viewModel.clearSearch();
        _searchController.clear();
      },
    );
  }
}