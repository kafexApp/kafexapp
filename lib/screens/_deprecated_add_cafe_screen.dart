import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_toast.dart';
import '../widgets/custom_boxcafe_minicard.dart';
import '../screens/cafe_explorer_screen.dart';

// Modelo para sugestões de lugares
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

// Enum para os passos do wizard
enum WizardStep {
  search,    // Passo 1: Buscar cafeteria
  photo,     // Passo 2: Adicionar foto
  details,   // Passo 3: Informações extras
  submit,    // Passo 4: Finalizar
}

class AddCafeScreen extends StatefulWidget {
  @override
  _AddCafeScreenState createState() => _AddCafeScreenState();
}

class _AddCafeScreenState extends State<AddCafeScreen> with TickerProviderStateMixin {
  // Controllers de busca
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageController _pageController = PageController();

  // Estados da busca
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingPlaces = false;
  String _lastSearchQuery = '';
  Timer? _searchTimer;

  // Estado do wizard
  WizardStep _currentStep = WizardStep.search;
  int _currentStepIndex = 0;
  final int _totalSteps = 4;
  
  // Animação do progresso
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  // Animação das transições
  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Dados do wizard
  GooglePlaceDetails? _selectedPlace;
  bool _isLoadingPlaceDetails = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Facilidades
  bool _isOfficeFriendly = false;
  bool _isPetFriendly = false;
  bool _isVegFriendly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    
    // Inicializar animações
    _progressController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _transitionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeIn,
    ));
    
    // Iniciar primeira animação
    _transitionController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    _searchTimer?.cancel();
    _progressController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  // Navegação entre passos
  void _nextStep() {
    if (_currentStepIndex < _totalSteps - 1) {
      setState(() {
        _currentStepIndex++;
        _currentStep = WizardStep.values[_currentStepIndex];
      });
      
      _updateProgress();
      _animateTransition();
      
      // Auto-scroll para o topo
      _pageController.animateToPage(
        _currentStepIndex,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _currentStep = WizardStep.values[_currentStepIndex];
      });
      
      _updateProgress();
      _animateTransition();
      
      _pageController.animateToPage(
        _currentStepIndex,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _updateProgress() {
    double progress = (_currentStepIndex + 1) / _totalSteps;
    _progressController.animateTo(progress);
  }

  void _animateTransition() {
    _transitionController.reset();
    _transitionController.forward();
  }

  // Validações por passo
  bool _canProceedFromCurrentStep() {
    switch (_currentStep) {
      case WizardStep.search:
        return _selectedPlace != null;
      case WizardStep.photo:
        return true; // Foto é opcional
      case WizardStep.details:
        return true; // Detalhes são opcionais
      case WizardStep.submit:
        return true;
    }
  }

  // Busca de lugares
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

  Future<void> _searchPlaces(String query) async {
    _lastSearchQuery = query;
    
    setState(() {
      _isLoadingPlaces = true;
    });

    try {
      await Future.delayed(Duration(milliseconds: 800));
      
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

  Future<void> _selectPlace(PlaceSuggestion suggestion) async {
    setState(() {
      _showSuggestions = false; // Fechar dropdown imediatamente
      _searchController.text = suggestion.description;
      _isLoadingPlaceDetails = true;
    });

    _searchFocusNode.unfocus();

    try {
      await Future.delayed(Duration(milliseconds: 1000));
      
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
        _placeSuggestions = []; // Limpar sugestões
      });
      
      // Auto-avançar para próximo passo após um delay
      Future.delayed(Duration(milliseconds: 1200), () {
        if (_canProceedFromCurrentStep()) {
          _nextStep();
        }
      });
      
    } catch (e) {
      print('Erro ao obter detalhes do lugar: $e');
      setState(() {
        _isLoadingPlaceDetails = false;
      });
    }
  }

  // Upload de foto
  Future<void> _selectImageFromSource(ImageSource source) async {
    try {
      Permission permission = source == ImageSource.camera 
          ? Permission.camera 
          : Permission.photos;
      
      final status = await permission.request();
      if (!status.isGranted) return;
      
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
      }
      
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      CustomToast.showError(context, message: 'Erro ao selecionar foto. Tente novamente.');
    }
  }

  // Finalizar cadastro
  void _submitCafe() {
    if (_selectedPlace == null) {
      CustomToast.showError(context, message: 'Por favor, complete o cadastro primeiro.');
      return;
    }

    print('Enviando cafeteria:');
    print('Nome: ${_selectedPlace!.name}');
    print('Endereço: ${_selectedPlace!.address}');
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
      appBar: CustomAppBar(
        showBackButton: true,
        onBackPressed: () {
          if (_currentStepIndex > 0) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress Bar no topo
              _buildProgressBar(),
              
              // Conteúdo dos passos
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(), // Previne swipe manual
                  children: [
                    _buildSearchStep(),
                    _buildPhotoStep(),
                    _buildDetailsStep(),
                    _buildSubmitStep(),
                  ],
                ),
              ),
              
              // Bottom navigation com botões do wizard
              _buildWizardNavigation(),
            ],
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

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.whiteWhite, // Background branco de lado a lado
      child: Column(
        children: [
          // Barra de progresso
          Row(
            children: [
              Text(
                'Passo ${_currentStepIndex + 1} de $_totalSteps',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: AppColors.grayScale2,
                ),
              ),
              
              Spacer(),
              
              Text(
                '${((_currentStepIndex + 1) / _totalSteps * 100).round()}%',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          
          // Barra visual
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.moonAsh,
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.papayaSensorial,
                      borderRadius: BorderRadius.circular(3),
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

  String _getStepTitle() {
    switch (_currentStep) {
      case WizardStep.search:
        return 'Encontre a cafeteria';
      case WizardStep.photo:
        return 'Adicione uma foto';
      case WizardStep.details:
        return 'Informações extras';
      case WizardStep.submit:
        return 'Finalize o cadastro';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case WizardStep.search:
        return 'Digite o nome da cafeteria para encontrarmos as informações para você.';
      case WizardStep.photo:
        return 'Tire uma foto ou escolha da galeria (opcional)';
      case WizardStep.details:
        return 'Adicione mais detalhes sobre o local (opcional)';
      case WizardStep.submit:
        return 'Revise as informações e envie para análise';
    }
  }

  Widget _buildSearchStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Banner do topo com títulos
              Container(
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
              ),
              
              SizedBox(height: 30),
              
              // Campo de busca
              Container(
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
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    color: AppColors.carbon,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite aqui o nome da cafeteria',
                    hintStyle: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.grayScale2,
                    ),
                    prefixIcon: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        AppIcons.location,
                        size: 20,
                        color: AppColors.papayaSensorial,
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
              ),
              
              // Dropdown de sugestões
              if (_showSuggestions) _buildSuggestionsDropdown(),
              
              // Estado de lugar selecionado
              if (_selectedPlace != null) _buildSelectedPlaceCard(),
              
              SizedBox(height: 180), // Espaço para wizard navigation + navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 10), // Reduzido de 20 para 10
              
              // Banner do passo 2 - Foto (mesmo design do passo 1)
              Container(
                width: double.infinity,
                height: 160, // Reduzido de 200 para 160
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/images/coffeeshop_banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(20), // Reduzido de 24 para 20
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
                        'Adicione uma foto (opcional)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          fontSize: 22, // Reduzido de 24 para 22
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteWhite,
                          height: 1.3,
                        ),
                      ),
                      
                      SizedBox(height: 8), // Reduzido de 12 para 8
                      
                      Text(
                        'Ao incluir uma foto você ajuda nossos usuários a reconhecerem o local com mais facilidade. A foto é opcional, mas ajuda outros usuários a reconhecerem o local!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          fontSize: 14, // Reduzido de 16 para 14
                          color: AppColors.papayaSensorial,
                          height: 1.3, // Reduzido de 1.4 para 1.3
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20), // Reduzido de 30 para 20
              
              // Preview da foto selecionada ou placeholder
              Container(
                width: double.infinity,
                height: 160, // Reduzido de 200 para 160
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _selectedImage != null ? null : AppColors.moonAsh.withOpacity(0.3),
                  image: _selectedImage != null 
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.image,
                              size: 40, // Reduzido de 48 para 40
                              color: AppColors.grayScale2,
                            ),
                            SizedBox(height: 8), // Reduzido de 12 para 8
                            Text(
                              'Nenhuma foto selecionada',
                              style: GoogleFonts.albertSans(
                                fontSize: 14,
                                color: AppColors.grayScale1,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
              
              SizedBox(height: 20), // Reduzido de 30 para 20
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoActionButton(
                      icon: AppIcons.camera,
                      title: 'Tirar foto',
                      onTap: () => _selectImageFromSource(ImageSource.camera),
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  Expanded(
                    child: _buildPhotoActionButton(
                      icon: AppIcons.image,
                      title: 'Galeria',
                      onTap: () => _selectImageFromSource(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              
              if (_selectedImage != null) ...[
                SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    icon: Icon(
                      AppIcons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Remover foto',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 110), // Espaço mínimo apenas para wizard navigation + navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Texto explicativo
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.papayaSensorial.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.papayaSensorial.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.heart,
                      size: 32,
                      color: AppColors.papayaSensorial,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Ajude outros coffee lovers!',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Essas informações são opcionais, mas ajudam muito a comunidade a saber o que esperar do local.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.grayScale1,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Switches de facilidades
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildFacilitySwitch(
                      title: 'Permite animais de estimação?',
                      value: _isPetFriendly,
                      onChanged: (value) => setState(() => _isPetFriendly = value),
                      icon: 'assets/images/icon-pet-friendly.svg',
                    ),
                    
                    Divider(height: 1, color: AppColors.moonAsh),
                    
                    _buildFacilitySwitch(
                      title: 'Oferece opções veganas?',
                      value: _isVegFriendly,
                      onChanged: (value) => setState(() => _isVegFriendly = value),
                      icon: 'assets/images/icon-veg-friendly.svg',
                    ),
                    
                    Divider(height: 1, color: AppColors.moonAsh),
                    
                    _buildFacilitySwitch(
                      title: 'Bom para trabalhar?',
                      value: _isOfficeFriendly,
                      onChanged: (value) => setState(() => _isOfficeFriendly = value),
                      icon: 'assets/images/icon-office-friendly.svg',
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 180), // Espaço para wizard navigation + navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Resumo do cadastro
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.checkCircle,
                          size: 24,
                          color: AppColors.cyberLime,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Resumo do cadastro',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.carbon,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Nome da cafeteria
                    _buildSummaryItem(
                      icon: AppIcons.storefront,
                      title: 'Cafeteria',
                      value: _selectedPlace?.name ?? 'Não selecionada',
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Endereço
                    _buildSummaryItem(
                      icon: AppIcons.location,
                      title: 'Endereço',
                      value: _selectedPlace?.address ?? 'Não informado',
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Foto
                    _buildSummaryItem(
                      icon: AppIcons.image,
                      title: 'Foto',
                      value: _selectedImage != null ? 'Adicionada' : 'Não adicionada',
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Facilidades
                    _buildSummaryItem(
                      icon: AppIcons.star,
                      title: 'Facilidades',
                      value: _getFacilitiesText(),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Mensagem final
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cyberLime.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cyberLime.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.heart,
                      size: 32,
                      color: AppColors.cyberLime,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Obrigado por contribuir!',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vamos analisar as informações e adicionar a cafeteria ao nosso mapa. Isso pode levar até 24 horas.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.grayScale1,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 180), // Espaço para wizard navigation + navbar
            ],
          ),
        ),
      ),
    );
  }

  String _getFacilitiesText() {
    List<String> facilities = [];
    if (_isPetFriendly) facilities.add('Pet-friendly');
    if (_isVegFriendly) facilities.add('Opções veganas');
    if (_isOfficeFriendly) facilities.add('Office-friendly');
    
    if (facilities.isEmpty) return 'Nenhuma informada';
    return facilities.join(', ');
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.papayaSensorial.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: AppColors.papayaSensorial,
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: AppColors.grayScale2,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.carbon,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.papayaSensorial.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPlaceCard() {
    if (_selectedPlace == null) return SizedBox.shrink();
    
    // Converter GooglePlaceDetails para CafeModel para usar com CustomBoxcafeMinicard
    final CafeModel cafeModel = CafeModel(
      id: 'preview_${_selectedPlace!.name}',
      name: _selectedPlace!.name,
      address: _selectedPlace!.address,
      rating: 4.5, // Rating padrão para preview
      imageUrl: _selectedPlace!.photoUrl ?? 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      isOpen: true,
      position: LatLng(_selectedPlace!.latitude ?? -23.5505, _selectedPlace!.longitude ?? -46.6333),
      distance: '0.1 km', // Distância padrão para preview como String
      price: 'R\$ 15,00', // Preço padrão para preview
      specialties: ['Espresso', 'Cappuccino'], // Especialidades padrão para preview
    );
    
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do preview
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  AppIcons.checkCircle,
                  size: 20,
                  color: AppColors.cyberLime,
                ),
                SizedBox(width: 8),
                Text(
                  'Local encontrado!',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ],
            ),
          ),
          
          // Preview usando CustomBoxcafeMinicard
          CustomBoxcafeMinicard(
            cafe: cafeModel,
            onTap: null, // Desabilitar tap no preview
          ),
        ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
                    Icon(
                      AppIcons.storefront,
                      size: 20,
                      color: AppColors.papayaSensorial,
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

  Widget _buildFacilitySwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
                height: 1.3,
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

  Widget _buildWizardNavigation() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 110), // Bottom padding para navbar
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão voltar
          if (_currentStepIndex > 0)
            Expanded(
              flex: 1,
              child: Container(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: Icon(
                    AppIcons.back,
                    size: 18,
                    color: AppColors.grayScale1,
                  ),
                  label: Text(
                    'Voltar',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayScale1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.moonAsh),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          
          if (_currentStepIndex > 0) SizedBox(width: 12),
          
          // Botão próximo/finalizar
          Expanded(
            flex: _currentStepIndex > 0 ? 2 : 1,
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _currentStep == WizardStep.submit 
                    ? _submitCafe 
                    : (_canProceedFromCurrentStep() ? _nextStep : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.papayaSensorial,
                  foregroundColor: AppColors.velvetMerlot,
                  disabledBackgroundColor: AppColors.grayScale2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == WizardStep.submit 
                      ? 'Enviar cadastro' 
                      : 'Continuar',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _canProceedFromCurrentStep() 
                        ? AppColors.velvetMerlot 
                        : AppColors.whiteWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}