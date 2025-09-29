import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_boxcafe_minicard.dart';
import '../../../widgets/side_menu_overlay.dart';
import '../../../models/cafe_model.dart';
import '../../../data/services/clustering_service.dart';
import '../../../data/models/domain/cafe.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCustomPin();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/pin_kafex.svg',
    );
    _updateMarkers();
  }

  void _onSearchChanged() {
    final viewModel = context.read<CafeExplorerViewModel>();
    final query = _searchController.text.trim();
    
    if (query.isNotEmpty) {
      viewModel.searchPlaces.execute(query);
    } else {
      viewModel.clearSuggestions();
    }
  }

  void _onFocusChanged() {
    // Mantém sugestões visíveis quando campo tem foco
  }

  void _updateMarkers() async {
    if (_customPin == null) return;

    final viewModel = context.read<CafeExplorerViewModel>();
    final groups = viewModel.getPinGroups();
    Set<Marker> newMarkers = {};

    for (int i = 0; i < groups.length; i++) {
      PinGroup group = groups[i];
      
      if (group.isCluster) {
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
        final cafe = group.cafes.first;
        int cafeIndex = viewModel.visibleCafes.indexWhere((c) => c.id == cafe.id);
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

    _updatePinLabels();
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
    
    canvas.drawCircle(Offset(30, 30), 30, outerCirclePaint);
    canvas.drawCircle(Offset(30, 30), 18, innerCirclePaint);
    
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

  void _updatePinLabels() async {
    if (_mapController == null) return;

    final viewModel = context.read<CafeExplorerViewModel>();
    final groups = viewModel.getPinGroups();
    List<Widget> newLabels = [];
    
    for (PinGroup group in groups) {
      if (!group.isCluster) {
        final cafe = group.cafes.first;
        
        try {
          ScreenCoordinate screenCoord = await _mapController!.getScreenCoordinate(cafe.position);
          
          String displayName = cafe.name.length > 14 
              ? '${cafe.name.substring(0, 14)}...' 
              : cafe.name;
          
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
        } catch (e) {
          continue;
        }
      }
    }

    setState(() {
      _pinLabels = newLabels;
    });
  }

  void _onClusterTapped(PinGroup cluster) {
    // Implementar zoom para o cluster
  }

  void _onPinTapped(int index) {
    final viewModel = context.read<CafeExplorerViewModel>();
    final selectedCafe = viewModel.visibleCafes[index];
    int viewportIndex = viewModel.cafesInViewport.indexWhere((c) => c.id == selectedCafe.id);
    
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
    Future.delayed(Duration(milliseconds: 500), _updateCafesInViewport);
  }

  void _onCameraMove(CameraPosition position) {
    final viewModel = context.read<CafeExplorerViewModel>();
    viewModel.updateMapCenter(position.target);
    viewModel.updateZoom(position.zoom);
  }

  void _onCameraIdle() {
    _updateMarkers();
    _updateCafesInViewport();
    Future.delayed(Duration(milliseconds: 100), _updatePinLabels);
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
          if (viewModel.cafesInViewport.isNotEmpty)
            _buildCarousel(viewModel),
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
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: AppColors.carbon,
                ),
                cursorColor: AppColors.papayaSensorial,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListenableBuilder(
              listenable: viewModel.searchPlaces,
              builder: (context, _) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: viewModel.searchPlaces.running 
                        ? null 
                        : () {
                            if (viewModel.suggestions.isNotEmpty) {
                              viewModel.selectPlace.execute(viewModel.suggestions.first);
                            }
                          },
                    child: Center(
                      child: viewModel.searchPlaces.running
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
                );
              },
            ),
          ),
        ],
      ),
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
                _buildToggleButton('Mapa', viewModel.isMapView, () => viewModel.toggleView()),
                SizedBox(width: 4),
                _buildToggleButton('Lista', !viewModel.isMapView, () => viewModel.toggleView()),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: viewModel.suggestions.length > 5 ? 5 : viewModel.suggestions.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.moonAsh),
            itemBuilder: (context, index) {
              final suggestion = viewModel.suggestions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    viewModel.selectPlace.execute(suggestion);
                    _searchController.text = suggestion.description;
                    _searchFocusNode.unfocus();
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

  // Adapter temporário: converte Cafe (novo) → CafeModel (antigo)
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
}