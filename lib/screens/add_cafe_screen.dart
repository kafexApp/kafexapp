import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../utils/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navbar.dart';

// Modelo para sugestões de lugares (reutilizando do cafe_explorer)
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

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
}

// Modelo para dados do lugar do Google Maps
class GooglePlaceDetails {
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;

  GooglePlaceDetails({
    required this.name,
    required this.address,
    this.phone,
    this.website,
    this.photoUrl,
    this.latitude,
    this.longitude,
  });
}

class AddCafeScreen extends StatefulWidget {
  @override
  _AddCafeScreenState createState() => _AddCafeScreenState();
}

class _AddCafeScreenState extends State<AddCafeScreen> {
  // Controller para o campo de busca
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Estados da busca
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingPlaces = false;
  String _lastSearchQuery = '';
  Timer? _searchTimer;

  // Dados do lugar selecionado
  GooglePlaceDetails? _selectedPlace;
  bool _isLoadingPlaceDetails = false;

  // Upload de foto personalizada
  String? _customPhotoPath;

  // Accordion "Mais informações"
  bool _showMoreInfo = false;

  // Estados dos switches para facilidades
  bool _isOfficeFriendly = false;
  bool _isPetFriendly = false;
  bool _isVegFriendly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text.trim();
    
    if (currentQuery == _lastSearchQuery) return;
    
    _searchTimer?.cancel();
    
    if (currentQuery.isNotEmpty) {
      _searchTimer = Timer(Duration(milliseconds: 500), () {
        _searchPlaces(currentQuery);
      });
    } else {
      setState(() {
        _placeSuggestions = [];
        _showSuggestions = false;
        _lastSearchQuery = '';
        _selectedPlace = null;
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

  // Buscar lugares usando Google Places API (mesma lógica do cafe_explorer)
  Future<void> _searchPlaces(String query) async {
    _lastSearchQuery = query;
    
    setState(() {
      _isLoadingPlaces = true;
    });

    try {
      // Simular busca - em produção usar a mesma API do cafe_explorer
      await Future.delayed(Duration(milliseconds: 800));
      
      // Mock de resultados
      List<PlaceSuggestion> suggestions = [
        PlaceSuggestion(
          placeId: 'mock_1',
          description: 'Starbucks - Rua Augusta, São Paulo - SP',
          mainText: 'Starbucks',
          secondaryText: 'Rua Augusta, São Paulo - SP',
          types: ['cafe', 'establishment'],
        ),
        PlaceSuggestion(
          placeId: 'mock_2',
          description: 'Coffee Lab - Vila Madalena, São Paulo - SP',
          mainText: 'Coffee Lab',
          secondaryText: 'Vila Madalena, São Paulo - SP',
          types: ['cafe', 'establishment'],
        ),
      ];
      
      if (_lastSearchQuery == query) {
        setState(() {
          _placeSuggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      print('Erro na busca de lugares: $e');
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
    setState(() {
      _showSuggestions = false; // Fechar dropdown
      _searchController.text = suggestion.description;
      _isLoadingPlaceDetails = true;
    });

    _searchFocusNode.unfocus();

    try {
      // Simular busca de detalhes do lugar - em produção usar Google Places Details API
      await Future.delayed(Duration(milliseconds: 1000));
      
      // Mock de dados detalhados
      GooglePlaceDetails placeDetails = GooglePlaceDetails(
        name: suggestion.mainText,
        address: suggestion.description,
        phone: '(11) 99999-9999',
        website: 'https://instagram.com/${suggestion.mainText.toLowerCase().replaceAll(' ', '')}',
        photoUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        latitude: -23.5505,
        longitude: -46.6333,
      );
      
      setState(() {
        _selectedPlace = placeDetails;
        _isLoadingPlaceDetails = false;
      });
      
      print('Lugar selecionado: ${placeDetails.name}');
      
    } catch (e) {
      print('Erro ao obter detalhes do lugar: $e');
      setState(() {
        _isLoadingPlaceDetails = false;
      });
    }
  }

  // Função para adicionar foto personalizada
  void _addCustomPhoto() async {
    // TODO: Implementar seleção de foto da galeria/câmera
    try {
      // Simulação de seleção de foto - em produção usar image_picker
      print('Abrindo galeria de fotos...');
      
      // Mock - simular seleção de foto após delay
      await Future.delayed(Duration(milliseconds: 800));
      
      setState(() {
        _customPhotoPath = 'mock_selected_photo.jpg';
      });
      
      print('Foto selecionada: $_customPhotoPath');
      
    } catch (e) {
      print('Erro ao selecionar foto: $e');
      _showErrorSnackBar('Erro ao selecionar foto. Tente novamente.');
    }
  }

  // Função para enviar cafeteria
  void _submitCafe() {
    if (_selectedPlace == null) {
      _showErrorSnackBar('Por favor, selecione uma cafeteria primeiro.');
      return;
    }

    print('Enviando cafeteria:');
    print('Nome: ${_selectedPlace!.name}');
    print('Endereço: ${_selectedPlace!.address}');
    print('Telefone: ${_selectedPlace!.phone}');
    print('Website: ${_selectedPlace!.website}');
    print('Foto personalizada: $_customPhotoPath');
    print('Office Friendly: $_isOfficeFriendly');
    print('Pet Friendly: $_isPetFriendly');
    print('Veg Friendly: $_isVegFriendly');

    _showSuccessSnackBar('Cafeteria enviada com sucesso!');
    
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.albertSans(color: AppColors.whiteWhite),
        ),
        backgroundColor: AppColors.spiced,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.albertSans(color: AppColors.whiteWhite),
        ),
        backgroundColor: AppColors.forestInk,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: Stack(
        children: [
          // Background com imagem e overlay
          _buildBackground(),
          
          // Conteúdo principal
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60), // Espaço para o título sobrepor a imagem
                  
                  // Títulos
                  _buildTitles(),
                  SizedBox(height: 40),
                  
                  // Campo de busca
                  _buildSearchField(),
                  
                  // Dropdown de sugestões
                  if (_showSuggestions) _buildSuggestionsDropdown(),
                  
                  SizedBox(height: 20),
                  
                  // Seção de foto
                  _buildPhotoSection(),
                  
                  SizedBox(height: 20),
                  
                  // Accordion "Mais informações"
                  _buildMoreInfoAccordion(),
                  
                  SizedBox(height: 40),
                  
                  // Botão enviar
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          
          // Navbar fixada na parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              isInCafeExplorer: true,
              onSearchPressed: () {
                print('Já estamos na tela de cadastro');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.velvetMerlot,
            AppColors.velvetMerlot.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Imagem de fundo (silhueta do homem com café)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.velvetMerlot.withOpacity(0.7),
                    BlendMode.multiply,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Conhece lugares legais para tomar bons cafés?',
          textAlign: TextAlign.center,
          style: GoogleFonts.albertSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteWhite,
            height: 1.3,
          ),
        ),
        
        SizedBox(height: 12),
        
        Text(
          'Adicione cafeterias em nosso explorador de cafeterias.',
          textAlign: TextAlign.center,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.papayaSensorial,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.carbon,
        ),
        decoration: InputDecoration(
          hintText: 'Digite o nome da cafeteria aqui',
          hintStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale2,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/images/map-marker.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppColors.papayaSensorial,
                BlendMode.srcIn,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.papayaSensorial,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.whiteWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cursorColor: AppColors.papayaSensorial,
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _placeSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.moonAsh,
        ),
        itemBuilder: (context, index) {
          final suggestion = _placeSuggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectPlace(suggestion),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/search-store.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        AppColors.papayaSensorial,
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _addCustomPhoto, // Adicionar clique no container inteiro
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da foto (usando coffeeshop.svg)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.pear,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/coffeshop.svg', // Ícone coffeeshop
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    AppColors.carbon,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 20),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inclua uma foto da cafeteria',
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.papayaSensorial,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clique ao lado para fazer upload de uma foto da cafeteria',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.grayScale1,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreInfoAccordion() {
    return Column(
      children: [
        // Header do accordion
        GestureDetector(
          onTap: () {
            setState(() {
              _showMoreInfo = !_showMoreInfo;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mais informações?',
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                    ),
                  ),
                ),
                Icon(
                  _showMoreInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.grayScale1,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12),
        
        // Box explicativo (mostrar apenas se accordion estiver fechado)
        if (!_showMoreInfo)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.papayaSensorial.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              'Quer adicionar mais detalhes sobre a cafeteria? É só clicar aqui e preencher. Mas se não quiser, relaxa: a gente faz isso por você depois! ♥️',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
                height: 1.4,
              ),
            ),
          ),
        
        // Switches (mostrar apenas se accordion estiver aberto)
        if (_showMoreInfo) ...[
          SizedBox(height: 16),
          _buildFacilitiesSwitches(),
        ],
      ],
    );
  }

  Widget _buildFacilitiesSwitches() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFacilitySwitch(
            title: 'Este local permite a entrada de animais de estimação?',
            value: _isPetFriendly,
            onChanged: (value) => setState(() => _isPetFriendly = value),
            icon: 'assets/images/icon-pet-friendly.svg',
          ),
          
          SizedBox(height: 16),
          
          _buildFacilitySwitch(
            title: 'Oferece opções veganas ou vegetarianas?',
            value: _isVegFriendly,
            onChanged: (value) => setState(() => _isVegFriendly = value),
            icon: 'assets/images/icon-veg-friendly.svg',
          ),
          
          SizedBox(height: 16),
          
          _buildFacilitySwitch(
            title: 'Está autorizado trabalhar nesse local?',
            value: _isOfficeFriendly,
            onChanged: (value) => setState(() => _isOfficeFriendly = value),
            icon: 'assets/images/icon-office-friendly.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.moonAsh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.papayaSensorial.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.velvetMerlot,
              BlendMode.srcIn,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
                height: 1.4,
              ),
            ),
          ),
          
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.pear,
            activeTrackColor: AppColors.pear.withOpacity(0.3),
            inactiveThumbColor: AppColors.grayScale2,
            inactiveTrackColor: AppColors.moonAsh,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedPlace != null ? _submitCafe : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.papayaSensorial,
          foregroundColor: AppColors.velvetMerlot,
          disabledBackgroundColor: AppColors.grayScale2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          'Enviar cafeteria',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _selectedPlace != null ? AppColors.velvetMerlot : AppColors.whiteWhite,
          ),
        ),
      ),
    );
  }
}