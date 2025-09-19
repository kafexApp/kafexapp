import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navbar.dart';

// Modelo de dados para cafeterias
class CafeData {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final LatLng position;

  CafeData({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.position,
  });
}

class CafeExplorerScreen extends StatefulWidget {
  @override
  _CafeExplorerScreenState createState() => _CafeExplorerScreenState();
}

class _CafeExplorerScreenState extends State<CafeExplorerScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  
  // Posição inicial (São Paulo)
  static const LatLng _initialPosition = LatLng(-23.5505, -46.6333);
  
  // Lista de cafeterias mock
  List<CafeData> _cafes = [
    CafeData(
      id: '1',
      name: 'Coffeelab',
      address: 'R. Fradique Coutinho, 1340 - Vila Madalena, São Paulo - SP, 05416-001',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      position: LatLng(-23.5505, -46.6333),
    ),
    CafeData(
      id: '2',
      name: 'Coffee Plus',
      address: 'Av. Paulista, 1500 - Bela Vista, São Paulo - SP, 01310-100',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      position: LatLng(-23.5611, -46.6564),
    ),
    CafeData(
      id: '3',
      name: 'Café Girondino',
      address: 'R. Girassol, 67 - Vila Madalena, São Paulo - SP, 05433-000',
      rating: 4.2,
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      position: LatLng(-23.5489, -46.6388),
    ),
  ];

  Set<Marker> _markers = {};
  int _selectedCafeIndex = 0;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    setState(() {
      _markers = _cafes.asMap().entries.map((entry) {
        int index = entry.key;
        CafeData cafe = entry.value;
        
        return Marker(
          markerId: MarkerId(cafe.id),
          position: cafe.position,
          onTap: () {
            _onMarkerTapped(index);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        );
      }).toSet();
    });
  }

  void _onMarkerTapped(int index) {
    setState(() {
      _selectedCafeIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedCafeIndex = index;
    });
    
    // Move o mapa para a posição da cafeteria selecionada
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_cafes[index].position),
    );
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
              // Barra de busca
              _buildSearchBar(),
              
              // Mapa
              Expanded(
                child: _buildMap(),
              ),
            ],
          ),
          
          // Lista de cafeterias na parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 110, // Espaço para a navbar
            child: _buildCafesList(),
          ),
          
          // Navbar sobreposta
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                print('Abrir menu sidebar');
                // TODO: Implementar menu lateral
              },
              onSearchPressed: () {
                print('Já estamos na tela de busca');
                // Já estamos na tela de exploração
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Busque um cafeteria',
          hintStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale2,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/images/pin_kafex.svg',
              width: 20,
              height: 20,
            ),
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 14.0,
      ),
      markers: _markers,
      onCameraMove: (CameraPosition position) {
        // TODO: Implementar atualização das cafeterias baseada na posição do mapa
      },
      style: '''
        [
          {
            "featureType": "all",
            "elementType": "geometry.fill",
            "stylers": [
              {
                "color": "#f5f5f0"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#ffffff"
              }
            ]
          }
        ]
      ''',
    );
  }

  Widget _buildCafesList() {
    return Container(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _cafes.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildCafeCard(_cafes[index]),
          );
        },
      ),
    );
  }

  Widget _buildCafeCard(CafeData cafe) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem da cafeteria
          Container(
            width: 120,
            height: 120,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(cafe.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Informações da cafeteria
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nome da cafeteria
                  Text(
                    cafe.name,
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  // Rating com grãos de café
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Container(
                          margin: EdgeInsets.only(right: 4),
                          child: SvgPicture.asset(
                            'assets/images/grain_note.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              index < cafe.rating.floor() 
                                  ? AppColors.papayaSensorial 
                                  : AppColors.grayScale2,
                              BlendMode.srcIn,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  
                  // Endereço
                  Text(
                    cafe.address,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Seta para mais detalhes
          Container(
            padding: EdgeInsets.all(16),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayScale2,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}