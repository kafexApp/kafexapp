import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/custom_boxcafe_minicard.dart';
import '../../../models/cafe_model.dart';
import '../../../data/models/domain/wizard_state.dart';
import '../viewmodel/add_cafe_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddCafeScreen extends StatefulWidget {
  @override
  _AddCafeScreenState createState() => _AddCafeScreenState();
}

class _AddCafeScreenState extends State<AddCafeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

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

    _transitionController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pageController.dispose();
    _progressController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final viewModel = context.read<AddCafeViewModel>();
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      viewModel.searchPlaces.execute(query);
    } else {
      viewModel.clearSearch();
    }
  }

  void _onFocusChanged() {
    // Mantém sugestões visíveis quando campo tem foco
  }

  void _nextStep() {
    final viewModel = context.read<AddCafeViewModel>();
    viewModel.nextStep();
    _updateProgress();
    _animateTransition();
    _pageController.animateToPage(
      viewModel.wizardState.currentStepIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousStep() {
    final viewModel = context.read<AddCafeViewModel>();
    viewModel.previousStep();
    _updateProgress();
    _animateTransition();
    _pageController.animateToPage(
      viewModel.wizardState.currentStepIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _updateProgress() {
    final viewModel = context.read<AddCafeViewModel>();
    _progressController.animateTo(viewModel.wizardState.progress);
  }

  void _animateTransition() {
    _transitionController.reset();
    _transitionController.forward();
  }

  Future<void> _selectImageFromSource(ImageSource source) async {
    try {
      Permission permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;

      final status = await permission.request();
      if (!status.isGranted) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final viewModel = context.read<AddCafeViewModel>();
        viewModel.setCustomPhoto(File(pickedFile.path));

        CustomToast.showSuccess(
          context,
          message: source == ImageSource.camera
              ? 'Foto capturada com sucesso!'
              : 'Foto selecionada com sucesso!',
        );
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      CustomToast.showError(
        context,
        message: 'Erro ao selecionar foto. Tente novamente.',
      );
    }
  }

  void _submitCafe() async {
    final viewModel = context.read<AddCafeViewModel>();

    if (!viewModel.canProceedFromCurrentStep()) {
      CustomToast.showError(
        context,
        message: 'Por favor, complete o cadastro primeiro.',
      );
      return;
    }

    viewModel.submitCafe.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(
        showBackButton: true,
        onBackPressed: () {
          final viewModel = context.read<AddCafeViewModel>();
          if (viewModel.wizardState.canGoBack) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Consumer<AddCafeViewModel>(
        builder: (context, viewModel, _) {
          // Listener para submit
          if (viewModel.submitCafe.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomToast.showSuccess(
                context,
                message: 'Cafeteria enviada com sucesso!',
              );
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            });
          }

          if (viewModel.submitCafe.error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomToast.showError(
                context,
                message: 'Erro ao enviar cafeteria. Tente novamente.',
              );
            });
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildProgressBar(viewModel),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildSearchStep(viewModel),
                        _buildPhotoStep(viewModel),
                        _buildDetailsStep(viewModel),
                        _buildSubmitStep(viewModel),
                      ],
                    ),
                  ),
                  _buildWizardNavigation(viewModel),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavbar(
                  isInCafeExplorer: true,
                  onSearchPressed: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(AddCafeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.whiteWhite,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Passo ${viewModel.wizardState.currentStepIndex + 1} de ${viewModel.wizardState.totalSteps}',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: AppColors.grayScale2,
                ),
              ),
              Spacer(),
              Text(
                '${(viewModel.wizardState.progress * 100).round()}%',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
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

  Widget _buildSearchStep(AddCafeViewModel viewModel) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildBanner(
                'Conhece lugares legais para tomar bons cafés?',
                'Adicione em nosso explorador de cafeterias',
              ),
              SizedBox(height: 30),
              _buildSearchField(viewModel),
              if (viewModel.showSuggestions) _buildSuggestionsDropdown(viewModel),
              if (viewModel.selectedPlace != null)
                _buildSelectedPlaceCard(viewModel),
              SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStep(AddCafeViewModel viewModel) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 10),
              _buildBanner(
                'Adicione uma foto (opcional)',
                'Ao incluir uma foto você ajuda nossos usuários a reconhecerem o local com mais facilidade.',
                height: 160,
              ),
              SizedBox(height: 20),
              _buildPhotoPreview(viewModel),
              SizedBox(height: 20),
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
              if (viewModel.customPhoto != null) ...[
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => viewModel.removeCustomPhoto(),
                    icon: Icon(AppIcons.delete, size: 18, color: Colors.red),
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
              SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep(AddCafeViewModel viewModel) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildInfoBox(
                icon: AppIcons.heart,
                title: 'Ajude outros coffee lovers!',
                description:
                    'Essas informações são opcionais, mas ajudam muito a comunidade a saber o que esperar do local.',
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildFacilitySwitch(
                      title: 'Permite animais de estimação?',
                      value: viewModel.isPetFriendly,
                      onChanged: (value) => viewModel.setPetFriendly(value),
                      icon: 'assets/images/icon-pet-friendly.svg',
                    ),
                    Divider(height: 1, color: AppColors.moonAsh),
                    _buildFacilitySwitch(
                      title: 'Oferece opções veganas?',
                      value: viewModel.isVegFriendly,
                      onChanged: (value) => viewModel.setVegFriendly(value),
                      icon: 'assets/images/icon-veg-friendly.svg',
                    ),
                    Divider(height: 1, color: AppColors.moonAsh),
                    _buildFacilitySwitch(
                      title: 'Bom para trabalhar?',
                      value: viewModel.isOfficeFriendly,
                      onChanged: (value) => viewModel.setOfficeFriendly(value),
                      icon: 'assets/images/icon-office-friendly.svg',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitStep(AddCafeViewModel viewModel) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
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
                    _buildSummaryItem(
                      icon: AppIcons.storefront,
                      title: 'Cafeteria',
                      value: viewModel.selectedPlace?.name ?? 'Não selecionada',
                    ),
                    SizedBox(height: 16),
                    _buildSummaryItem(
                      icon: AppIcons.location,
                      title: 'Endereço',
                      value:
                          viewModel.selectedPlace?.address ?? 'Não informado',
                    ),
                    SizedBox(height: 16),
                    _buildSummaryItem(
                      icon: AppIcons.image,
                      title: 'Foto',
                      value: viewModel.customPhoto != null
                          ? 'Adicionada'
                          : 'Não adicionada',
                    ),
                    SizedBox(height: 16),
                    _buildSummaryItem(
                      icon: AppIcons.star,
                      title: 'Facilidades',
                      value: viewModel.getFacilitiesText(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              _buildInfoBox(
                icon: AppIcons.heart,
                title: 'Obrigado por contribuir!',
                description:
                    'Vamos analisar as informações e adicionar a cafeteria ao nosso mapa. Isso pode levar até 24 horas.',
                color: AppColors.cyberLime,
              ),
              SizedBox(height: 180),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(String title, String subtitle, {double height = 200}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage('assets/images/coffeeshop_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(height == 200 ? 24 : 20),
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
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: height == 200 ? 24 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteWhite,
                height: 1.3,
              ),
            ),
            SizedBox(height: height == 200 ? 12 : 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: height == 200 ? 16 : 14,
                color: AppColors.papayaSensorial,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AddCafeViewModel viewModel) {
    return Container(
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

  Widget _buildSuggestionsDropdown(AddCafeViewModel viewModel) {
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
        itemCount: viewModel.placeSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.moonAsh,
        ),
        itemBuilder: (context, index) {
          final suggestion = viewModel.placeSuggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                viewModel.selectPlace.execute(suggestion);
                _searchController.text = suggestion.name;
                _searchFocusNode.unfocus();
              },
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
                            suggestion.name,
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.carbon,
                            ),
                          ),
                          Text(
                            suggestion.address,
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

  Widget _buildSelectedPlaceCard(AddCafeViewModel viewModel) {
    final place = viewModel.selectedPlace!;

    final CafeModel cafeModel = CafeModel(
      id: 'preview_${place.name}',
      name: place.name,
      address: place.address,
      rating: 4.5,
      imageUrl: place.photoUrl ??
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      isOpen: true,
      position: LatLng(place.latitude ?? -23.5505, place.longitude ?? -46.6333),
      distance: '0.1 km',
      price: 'R\$ 15,00',
      specialties: ['Espresso', 'Cappuccino'],
    );

    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          CustomBoxcafeMinicard(
            cafe: cafeModel,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(AddCafeViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: viewModel.customPhoto != null
            ? null
            : AppColors.moonAsh.withOpacity(0.3),
        image: viewModel.customPhoto != null
            ? DecorationImage(
                image: FileImage(viewModel.customPhoto!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: viewModel.customPhoto == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.image,
                    size: 40,
                    color: AppColors.grayScale2,
                  ),
                  SizedBox(height: 8),
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

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String description,
    Color color = AppColors.papayaSensorial,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildWizardNavigation(AddCafeViewModel viewModel) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 110),
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
          if (viewModel.wizardState.canGoBack)
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
          if (viewModel.wizardState.canGoBack) SizedBox(width: 12),
          Expanded(
            flex: viewModel.wizardState.canGoBack ? 2 : 1,
            child: Container(
              height: 48,
              child: ListenableBuilder(
                listenable: viewModel.submitCafe,
                builder: (context, _) {
                  return ElevatedButton(
                    onPressed: viewModel.submitCafe.running
                        ? null
                        : (viewModel.wizardState.isLastStep
                            ? _submitCafe
                            : (viewModel.canProceedFromCurrentStep()
                                ? _nextStep
                                : null)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.papayaSensorial,
                      foregroundColor: AppColors.velvetMerlot,
                      disabledBackgroundColor: AppColors.grayScale2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.submitCafe.running
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteWhite,
                              ),
                            ),
                          )
                        : Text(
                            viewModel.wizardState.isLastStep
                                ? 'Enviar cadastro'
                                : 'Continuar',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: viewModel.canProceedFromCurrentStep()
                                  ? AppColors.velvetMerlot
                                  : AppColors.whiteWhite,
                            ),
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
}