// lib/ui/cafe_explorer/widgets/cafe_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_boxcafe_minicard.dart';
import '../../../widgets/side_menu_overlay.dart';
import '../../../models/cafe_model.dart';
import '../../../data/services/clustering_service.dart';
import '../../../data/models/domain/cafe.dart';
import '../../../services/location_service.dart';
import '../viewmodel/cafe_explorer_viewmodel.dart';

class CafeExplorerScreen extends StatefulWidget {
  @override
  _CafeExplorerScreenState createState() => _CafeExplorerScreenState();
}

class _CafeExplorerScreenState extends State<CafeExplorerScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customPin;
  List<Widget> _pinLabels = [];

  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  PageController _pageController = PageController();
  ScrollController _horizontalScrollController = ScrollController();

  Timer? _labelTimer;
  Timer? _clusterIconTimer;
  Map<String, BitmapDescriptor> _clusterIconCache = {};
  bool _isMapMoving = false;
  bool _hasRequestedLocation = false;

  @override
  void initState() {
    super.initState();
    _loadCustomPin();
    _searchFocusNode.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNativeLocation();
    });
  }

  @override
  void dispose() {
    _labelTimer?.cancel();
    _clusterIconTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
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

  Future<void> _loadCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 12.0),
      'assets/images/pin_kafex.png',
    );
    _updateMarkers();
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      // Quando perde o foco, limpar sugestões
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

  void _updateMarkers() async {
    if (_customPin == null) return;

    final viewModel = context.read<CafeExplorerViewModel>();

    final groups = _getOptimizedPinGroups(
      viewModel.visibleCafes,
      viewModel.currentZoom,
    );

    Set<Marker> newMarkers = {};

    for (int i = 0; i < groups.length; i++) {
      PinGroup group = groups[i];

      if (group.isCluster) {
        BitmapDescriptor clusterIcon = await _getClusterIconCached(group.count);

        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_$i'),
            position: group.position,
            icon: clusterIcon,
            onTap: () => _onClusterTapped(group),
          ),
        );
      } else {
        final cafe = group.cafes.first;
        int cafeIndex = viewModel.visibleCafes.indexWhere(
          (c) => c.id == cafe.id,
        );

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

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<BitmapDescriptor> _getClusterIconCached(int count) async {
    String cacheKey = 'cluster_$count';

    if (_clusterIconCache.containsKey(cacheKey)) {
      return _clusterIconCache[cacheKey]!;
    }

    BitmapDescriptor icon = await _createClusterIcon(count);
    _clusterIconCache[cacheKey] = icon;

    return icon;
  }

  Future<BitmapDescriptor> _createClusterIcon(int count) async {
    final String clusterText = count > 99 ? "99+" : count.toString();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint outerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Paint innerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(40, 40), 40, outerCirclePaint);
    canvas.drawCircle(Offset(40, 40), 24, innerCirclePaint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: clusterText,
        style: TextStyle(
          fontSize: count > 99 ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteWhite,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(40 - textPainter.width / 2, 40 - textPainter.height / 2),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image img = await picture.toImage(80, 80);
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  List<PinGroup> _getOptimizedPinGroups(List<Cafe> cafes, double currentZoom) {
    final double clusterDistanceKm = _getClusterDistance(currentZoom);
    const double minZoomForClustering = 17.0;

    if (currentZoom >= minZoomForClustering) {
      return cafes.map((cafe) => PinGroup.single(cafe)).toList();
    }

    return _performSpatialClustering(cafes, clusterDistanceKm);
  }

  double _getClusterDistance(double zoom) {
    if (zoom >= 16) return 0.1;
    if (zoom >= 15) return 0.3;
    if (zoom >= 14) return 0.5;
    if (zoom >= 13) return 1.0;
    if (zoom >= 12) return 2.0;
    return 5.0;
  }

  List<PinGroup> _performSpatialClustering(
    List<Cafe> cafes,
    double clusterDistanceKm,
  ) {
    if (cafes.isEmpty) return [];

    List<PinGroup> groups = [];
    List<bool> processed = List.filled(cafes.length, false);

    for (int i = 0; i < cafes.length; i++) {
      if (processed[i]) continue;

      Cafe center = cafes[i];
      List<Cafe> cluster = [center];
      processed[i] = true;

      for (int j = i + 1; j < cafes.length; j++) {
        if (processed[j]) continue;

        double distance = _calculateDistanceKm(
          center.position,
          cafes[j].position,
        );

        if (distance <= clusterDistanceKm) {
          cluster.add(cafes[j]);
          processed[j] = true;
        }
      }

      if (cluster.length > 1) {
        groups.add(PinGroup.cluster(cluster));
      } else {
        groups.add(PinGroup.single(center));
      }
    }

    return groups;
  }

  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _scheduleLabelUpdate() {
    _labelTimer?.cancel();
    _labelTimer = Timer(Duration(milliseconds: 800), () {
      if (mounted && !_isMapMoving) {
        print('🏷️ Agendando atualização de labels...');
        _updatePinLabels();
      }
    });
  }

  void _updatePinLabels() async {
    if (_mapController == null) return;

    final viewModel = context.read<CafeExplorerViewModel>();

    print('🏷️ _updatePinLabels chamado - Zoom: ${viewModel.currentZoom}');

    if (viewModel.currentZoom < 14.0) {
      print(
        '🏷️ Zoom muito baixo (${viewModel.currentZoom}), não mostrar labels',
      );
      if (_pinLabels.isNotEmpty) {
        setState(() {
          _pinLabels = [];
        });
      }
      return;
    }

    print('🏷️ Zoom OK, processando labels...');
    print('🏷️ Total de cafés visíveis: ${viewModel.visibleCafes.length}');

    List<Widget> newLabels = [];
    int labelCount = 0;
    const int maxLabels = 20;

    for (var cafe in viewModel.visibleCafes) {
      if (labelCount >= maxLabels) break;

      try {
        ScreenCoordinate screenCoord = await _mapController!
            .getScreenCoordinate(cafe.position);

        String displayName = cafe.name.length > 14
            ? '${cafe.name.substring(0, 14)}...'
            : cafe.name;

        print(
          '🏷️ Criando label para: $displayName em (${screenCoord.x}, ${screenCoord.y})',
        );

        newLabels.add(
          Positioned(
            left: screenCoord.x.toDouble(),
            top: screenCoord.y.toDouble() - 60,
            child: FractionalTranslation(
              translation: Offset(-0.5, 0),
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

        labelCount++;
      } catch (e) {
        print('🏷️ Erro ao criar label: $e');
        continue;
      }
    }

    print('🏷️ Total de labels criados: ${newLabels.length}');

    if (mounted) {
      setState(() {
        _pinLabels = newLabels;
      });
      print('🏷️ Labels atualizados no estado!');
    }
  }

  void _onClusterTapped(PinGroup cluster) {
    if (_mapController == null) return;

    if (cluster.cafes.length == 1) {
      return;
    }

    double minLat = cluster.cafes.first.position.latitude;
    double maxLat = cluster.cafes.first.position.latitude;
    double minLng = cluster.cafes.first.position.longitude;
    double maxLng = cluster.cafes.first.position.longitude;

    for (var cafe in cluster.cafes) {
      minLat = math.min(minLat, cafe.position.latitude);
      maxLat = math.max(maxLat, cafe.position.latitude);
      minLng = math.min(minLng, cafe.position.longitude);
      maxLng = math.max(maxLng, cafe.position.longitude);
    }

    double maxDistance = 0;
    for (int i = 0; i < cluster.cafes.length; i++) {
      for (int j = i + 1; j < cluster.cafes.length; j++) {
        double distance = _calculateDistance(
          cluster.cafes[i].position,
          cluster.cafes[j].position,
        );
        maxDistance = math.max(maxDistance, distance);
      }
    }

    if (maxDistance < 50) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 19.0),
      );
      return;
    }

    if (maxDistance < 200) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 18.0),
      );
      return;
    }

    try {
      double latPadding = (maxLat - minLat) * 0.5;
      double lngPadding = (maxLng - minLng) * 0.5;

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - latPadding, minLng - lngPadding),
            northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
          ),
          80.0,
        ),
      );
    } catch (e) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 17.0),
      );
    }
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  void _onPinTapped(int index) {
    final viewModel = context.read<CafeExplorerViewModel>();
    final selectedCafe = viewModel.visibleCafes[index];
    int viewportIndex = viewModel.cafesInViewport.indexWhere(
      (c) => c.id == selectedCafe.id,
    );

    if (viewportIndex != -1 && _horizontalScrollController.hasClients) {
      double screenWidth = MediaQuery.of(context).size.width;
      double cardWidth = screenWidth * 0.9;
      double spacing = 12.0;
      double targetOffset = viewportIndex * (cardWidth + spacing);

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

    final viewModel = context.read<CafeExplorerViewModel>();
    debugPrint('📍 Posição atual do ViewModel: ${viewModel.currentPosition}');

    if (viewModel.currentPosition.latitude != -23.5505 ||
        viewModel.currentPosition.longitude != -46.6333) {
      debugPrint('🗺️ Movendo mapa para posição customizada');
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(viewModel.currentPosition, 15.0),
      );
    }

    Future.delayed(Duration(milliseconds: 500), _updateCafesInViewport);
  }

  void _onCameraMove(CameraPosition position) {
    _isMapMoving = true;
    if (_pinLabels.isNotEmpty) {
      setState(() {
        _pinLabels = [];
      });
    }

    final viewModel = context.read<CafeExplorerViewModel>();
    viewModel.updateMapCenter(position.target);
    viewModel.updateZoom(position.zoom);
  }

  void _onCameraIdle() {
    _isMapMoving = false;
    _updateMarkers();
    _updateCafesInViewport();

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && !_isMapMoving) {
        _updatePinLabels();
      }
    });
  }

  void _updateCafesInViewport() async {
    if (_mapController == null) return;

    try {
      final viewModel = context.read<CafeExplorerViewModel>();
      LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();

      List<Cafe> cafesInView = viewModel.visibleCafes.where((cafe) {
        return cafe.position.latitude >= visibleRegion.southwest.latitude &&
            cafe.position.latitude <= visibleRegion.northeast.latitude &&
            cafe.position.longitude >= visibleRegion.southwest.longitude &&
            cafe.position.longitude <= visibleRegion.northeast.longitude;
      }).toList();

      viewModel.updateCafesInViewport(cafesInView);
    } catch (e) {
      print('Erro ao obter região visível: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Consumer<CafeExplorerViewModel>(
                builder: (context, viewModel, _) {
                  return viewModel.isMapView
                      ? _buildMapView(viewModel)
                      : _buildListView(viewModel);
                },
              ),
            ],
          ),
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
      ),
    );
  }

  Widget _buildMapView(CafeExplorerViewModel viewModel) {
    return Expanded(
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            initialCameraPosition: CameraPosition(
              target: viewModel.currentPosition,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _getMapStyle(),
            onTap: (_) {
              viewModel.clearSuggestions();
              _searchFocusNode.unfocus();
            },
          ),
          ..._pinLabels,
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(viewModel),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: _buildToggleButtons(viewModel),
          ),
          _buildSuggestionsDropdown(viewModel),
          if (viewModel.cafesInViewport.isNotEmpty) _buildCarousel(viewModel),
        ],
      ),
    );
  }

  Widget _buildListView(CafeExplorerViewModel viewModel) {
    return Expanded(
      child: Container(
        color: AppColors.oatWhite,
        child: Stack(
          children: [
            if (viewModel.visibleCafes.isNotEmpty)
              ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 180, 20, 120),
                itemCount: viewModel.visibleCafes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: CustomBoxcafeMinicard(
                      cafe: _convertToOldModel(viewModel.visibleCafes[index]),
                      onTap: () {},
                    ),
                  );
                },
              )
            else if (viewModel.isShowingSearchResults)
              _buildNoResultsMessage(viewModel)
            else
              _buildLoadingMessage(),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildSearchBar(viewModel),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: _buildToggleButtons(viewModel),
            ),
            _buildSuggestionsDropdown(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(CafeExplorerViewModel viewModel) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _searchFocusNode,
        viewModel.searchPlaces,
        _searchController,
      ]),
      builder: (context, _) {
        final isFocused = _searchFocusNode.hasFocus;
        final isSearching = viewModel.searchPlaces.running;
        final hasText = _searchController.text.isNotEmpty;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused 
                  ? AppColors.papayaSensorial 
                  : Colors.transparent,
              width: 2,
            ),
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
                      fillColor: Colors.transparent,
                      filled: false,
                    ),
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.carbon,
                    ),
                    cursorColor: AppColors.papayaSensorial,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ),
              // Botão X (limpar) - aparece quando tem texto
              if (hasText)
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        _searchController.clear();
                        viewModel.clearSuggestions();
                        viewModel.clearSearch();
                        _searchFocusNode.unfocus();
                      },
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.grayScale2,
                        ),
                      ),
                    ),
                  ),
                ),
              // Botão de buscar
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
                    onTap: isSearching ? null : _performSearch,
                    child: Center(
                      child: isSearching
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
        );
      },
    );
  }

  Widget _buildToggleButtons(CafeExplorerViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
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
                _buildToggleButton(
                  'Mapa',
                  viewModel.isMapView,
                  () => viewModel.toggleView(),
                ),
                SizedBox(width: 4),
                _buildToggleButton(
                  'Lista',
                  !viewModel.isMapView,
                  () => viewModel.toggleView(),
                ),
              ],
            ),
          ),
          Spacer(),
          _buildCafeCounter(viewModel),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.papayaSensorial : AppColors.moonAsh,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.whiteWhite : AppColors.grayScale1,
          ),
        ),
      ),
    );
  }

  Widget _buildCafeCounter(CafeExplorerViewModel viewModel) {
    final count = viewModel.isMapView
        ? viewModel.cafesInViewport.length
        : viewModel.visibleCafes.length;

    return Container(
      height: 48,
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
          SvgPicture.asset(
            'assets/images/icon-pin-map.svg',
            width: 24,
            height: 24,
          ),
          SizedBox(width: 8),
          Text(
            '$count',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown(CafeExplorerViewModel viewModel) {
    if (!viewModel.hasSuggestions) return SizedBox.shrink();

    return Positioned(
      top: 74,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Resultados encontrados (${viewModel.suggestions.length > 10 ? 10 : viewModel.suggestions.length})',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.moonAsh),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: viewModel.suggestions.length > 10
                    ? 10
                    : viewModel.suggestions.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: AppColors.moonAsh),
                itemBuilder: (context, index) {
                  final suggestion = viewModel.suggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        _searchController.text = suggestion.description;
                        _searchFocusNode.unfocus();

                        await viewModel.selectPlace.execute(suggestion);

                        if (viewModel.isMapView && _mapController != null) {
                          await _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              viewModel.currentPosition,
                              16.0,
                            ),
                          );
                          
                          // Aguardar mapa estabilizar e atualizar cafés no viewport
                          Future.delayed(Duration(milliseconds: 800), () {
                            _updateCafesInViewport();
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              suggestion.iconPath,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                suggestion.isEstablishment
                                    ? AppColors.papayaSensorial
                                    : AppColors.grayScale1,
                                BlendMode.srcIn,
                              ),
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
                            if (suggestion.isEstablishment)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(CafeExplorerViewModel viewModel) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 141,
        child: Builder(
          builder: (context) {
            double screenWidth = MediaQuery.of(context).size.width;
            double cardWidth = screenWidth * 0.9;

            return ListView.builder(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              itemCount: viewModel.cafesInViewport.length,
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(right: 12),
                  child: CustomBoxcafeMinicard(
                    cafe: _convertToOldModel(viewModel.cafesInViewport[index]),
                    onTap: () {
                      if (_mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            viewModel.cafesInViewport[index].position,
                            16.0,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoResultsMessage(CafeExplorerViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            if (viewModel.searchAddress.isNotEmpty)
              Text(
                'Nenhuma cafeteria encontrada próxima a:\n"${viewModel.searchAddress}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  viewModel.clearSearch();
                  _searchController.clear();
                },
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Center(
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
    );
  }

  CafeModel _convertToOldModel(Cafe cafe) {
    return CafeModel(
      id: cafe.id,
      name: cafe.name,
      address: cafe.address,
      rating: cafe.rating,
      distance: cafe.distance,
      imageUrl: cafe.imageUrl,
      isOpen: cafe.isOpen,
      position: cafe.position,
      price: cafe.price,
      specialties: List<String>.from(cafe.specialties),
    );
  }

  String _getMapStyle() {
    return '''[
      {
        "featureType": "administrative",
        "elementType": "labels.text",
        "stylers": [{"visibility": "simplified"}]
      },
      {
        "featureType": "administrative.country",
        "elementType": "geometry.stroke",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "administrative.province",
        "elementType": "geometry.stroke",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [{"color": "#f8f8f8"}]
      },
      {
        "featureType": "poi",
        "elementType": "all",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "poi.business",
        "elementType": "all",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [{"color": "#e8f5e8"}]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#ffffff"}]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#666666"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"},
          {"weight": 2},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#e6e6e6"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#555555"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"},
          {"weight": 2},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [{"color": "#f0f0f0"}]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#666666"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"},
          {"weight": 2},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [{"color": "#f5f5f5"}]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#777777"},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ffffff"},
          {"weight": 2},
          {"visibility": "on"}
        ]
      },
      {
        "featureType": "transit",
        "elementType": "all",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#d4e7f7"}]
      },
      {
        "featureType": "water",
        "elementType": "labels",
        "stylers": [{"visibility": "off"}]
      }
    ]''';
  }
}

class PinGroup {
  final List<Cafe> cafes;
  final bool isCluster;
  late final LatLng position;

  PinGroup.cluster(this.cafes) : isCluster = true {
    position = _calculateCenterPosition();
  }

  PinGroup.single(Cafe cafe) : cafes = [cafe], isCluster = false {
    position = cafe.position;
  }

  int get count => cafes.length;

  LatLng _calculateCenterPosition() {
    if (cafes.isEmpty) {
      return LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (var cafe in cafes) {
      totalLat += cafe.position.latitude;
      totalLng += cafe.position.longitude;
    }

    return LatLng(totalLat / cafes.length, totalLng / cafes.length);
  }
}