import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_toast.dart';

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
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

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

  // Função para verificar e solicitar permissões
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Mostrar dialog para ir para configurações
      _showPermissionDialog();
      return false;
    }
    
    return false;
  }

  // Dialog para permissões negadas permanentemente
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permissão necessária',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          content: Text(
            'Para selecionar fotos, é necessário permitir o acesso à câmera e galeria. Vá para as configurações do app e habilite as permissões.',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.papayaSensorial,
                foregroundColor: AppColors.velvetMerlot,
              ),
              child: Text(
                'Configurações',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Bottom sheet para selecionar fonte da imagem
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arraste
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayScale2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Título
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Selecionar foto',
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                    ),
                  ),
                ),
                
                // Opções
                Column(
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      title: 'Tirar foto',
                      subtitle: 'Usar a câmera',
                      onTap: () => _selectImageFromSource(ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      title: 'Escolher da galeria',
                      subtitle: 'Selecionar uma foto salva',
                      onTap: () => _selectImageFromSource(ImageSource.gallery),
                    ),
                    // Opção para remover foto (se já tiver uma selecionada)
                    if (_selectedImage != null)
                      _buildImageSourceOption(
                        icon: Icons.delete_outline,
                        title: 'Remover foto',
                        subtitle: 'Excluir foto selecionada',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        isDestructive: true,
                      ),
                  ],
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.papayaSensorial.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive 
                      ? Colors.red
                      : AppColors.papayaSensorial,
                  size: 24,
                ),
              ),
              
              SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive 
                            ? Colors.red
                            : AppColors.carbon,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grayScale2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Selecionar imagem da câmera ou galeria
  Future<void> _selectImageFromSource(ImageSource source) async {
    Navigator.pop(context); // Fechar bottom sheet
    
    try {
      // Verificar permissões
      Permission permission = source == ImageSource.camera 
          ? Permission.camera 
          : Permission.photos;
      
      bool hasPermission = await _requestPermission(permission);
      
      if (!hasPermission) {
        return;
      }
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        CustomToast.showSuccess(
          context, 
          message: source == ImageSource.camera 
              ? 'Foto capturada com sucesso!' 
              : 'Foto selecionada com sucesso!'
        );
        
        print('Imagem selecionada: ${pickedFile.path}');
      }
      
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      
      String errorMessage = source == ImageSource.camera 
          ? 'Erro ao tirar foto. Tente novamente.'
          : 'Erro ao selecionar foto. Tente novamente.';
      
      CustomToast.showError(context, message: errorMessage);
    }
  }

  // Função para enviar cafeteria
  void _submitCafe() {
    if (_selectedPlace == null) {
      CustomToast.showError(context, message: 'Por favor, selecione uma cafeteria primeiro.');
      return;
    }

    print('Enviando cafeteria:');
    print('Nome: ${_selectedPlace!.name}');
    print('Endereço: ${_selectedPlace!.address}');
    print('Telefone: ${_selectedPlace!.phone}');
    print('Website: ${_selectedPlace!.website}');
    print('Foto personalizada: ${_selectedImage?.path ?? 'Nenhuma'}');
    print('Office Friendly: $_isOfficeFriendly');
    print('Pet Friendly: $_isPetFriendly');
    print('Veg Friendly: $_isVegFriendly');

    CustomToast.showSuccess(context, message: 'Cafeteria enviada com sucesso!');
    
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Conteúdo principal com scroll
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 110), // Espaço para navbar
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner do topo com títulos
                  _buildTopBanner(),
                  
                  SizedBox(height: 30),
                  
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
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Navbar sempre fixada na parte inferior
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

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage('assets/images/coffeeshop_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Adicione em nosso explorador de cafeterias',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                color: AppColors.papayaSensorial,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Foto da cafeteria',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ),
          
          // Preview da imagem selecionada (se houver)
          if (_selectedImage != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          if (_selectedImage != null) SizedBox(height: 16),
          
          // Campo de upload
          GestureDetector(
            onTap: _showImageSourceBottomSheet,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedImage != null 
                    ? AppColors.cyberLime.withOpacity(0.1)
                    : AppColors.moonAsh.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedImage != null 
                      ? AppColors.cyberLime
                      : AppColors.grayScale2.withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  // Ícone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selectedImage != null 
                          ? AppColors.cyberLime
                          : AppColors.grayScale2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _selectedImage != null 
                            ? Icons.edit
                            : Icons.add_photo_alternate,
                        size: 24,
                        color: AppColors.whiteWhite,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedImage != null 
                              ? 'Foto selecionada!'
                              : 'Selecionar foto',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedImage != null 
                                ? AppColors.cyberLime
                                : AppColors.carbon,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _selectedImage != null 
                              ? 'Toque para trocar ou remover'
                              : 'Câmera ou galeria',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: AppColors.grayScale1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Seta
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.grayScale2,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMoreInfoAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
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
          
          // Box explicativo (visível apenas quando fechado)
          if (!_showMoreInfo) 
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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
          
          // Conteúdo expandível do accordion
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showMoreInfo ? null : 0,
            child: _showMoreInfo 
              ? Column(
                  children: [
                    SizedBox(height: 8),
                    
                    // Switches de facilidades
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.moonAsh.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildFacilitySwitch(
                            title: 'Este local permite a entrada de animais de estimação?',
                            value: _isPetFriendly,
                            onChanged: (value) => setState(() => _isPetFriendly = value),
                            icon: 'assets/images/icon-pet-friendly.svg',
                          ),
                          
                          SizedBox(height: 12),
                          
                          _buildFacilitySwitch(
                            title: 'Oferece opções veganas ou vegetarianas?',
                            value: _isVegFriendly,
                            onChanged: (value) => setState(() => _isVegFriendly = value),
                            icon: 'assets/images/icon-veg-friendly.svg',
                          ),
                          
                          SizedBox(height: 12),
                          
                          _buildFacilitySwitch(
                            title: 'Está autorizado trabalhar nesse local?',
                            value: _isOfficeFriendly,
                            onChanged: (value) => setState(() => _isOfficeFriendly = value),
                            icon: 'assets/images/icon-office-friendly.svg',
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                )
              : SizedBox.shrink(),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.papayaSensorial.withOpacity(0.2),
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
          
          SizedBox(width: 16), // Aumentado de 12 para 16
          
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 13,
                color: AppColors.carbon,
                height: 1.3,
              ),
            ),
          ),
          
          SizedBox(width: 20), // Aumentado de implícito para 20
          
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