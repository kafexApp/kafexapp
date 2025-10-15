import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../../../models/cafe_model.dart';
import '../../../../widgets/custom_boxcafe_minicard.dart';
import '../../../../widgets/custom_toast.dart';
import '../../viewmodel/add_cafe_viewmodel.dart';
import '../components/info_banner.dart';

class SearchStep extends StatefulWidget {
  final AddCafeViewModel viewModel;

  const SearchStep({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<SearchStep> createState() => _SearchStepState();
}

class _SearchStepState extends State<SearchStep> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      
      // Limpar erro anterior antes de nova busca
      widget.viewModel.clearSearch();
      
      widget.viewModel.searchPlaces.execute(query);
    }
  }

  void _handlePlaceSelection(suggestion) async {
    _searchController.text = suggestion.name;
    _searchFocusNode.unfocus();
    
    // Executar seleção e aguardar resultado
    await widget.viewModel.selectPlace.execute(suggestion);
    
    // Se houver erro (duplicata), limpar após 4 segundos
    if (widget.viewModel.selectPlace.error) {
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) {
          _searchController.clear();
          widget.viewModel.resetSelectionError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: ListenableBuilder(
        listenable: widget.viewModel.selectPlace,
        builder: (context, _) {
          final isSelecting = widget.viewModel.selectPlace.running;
          final hasError = widget.viewModel.selectPlace.error;
          final hasSelectedPlace = widget.viewModel.selectedPlace != null;

          return Column(
            children: [
              SizedBox(height: 20),
              InfoBanner(
                title: 'Conhece lugares legais para tomar bons cafés?',
                subtitle: 'Adicione em nosso explorador de cafeterias',
              ),
              SizedBox(height: 30),
              _buildSearchField(),
              
              // Loading ao selecionar lugar
              if (isSelecting) ...[
                SizedBox(height: 16),
                _buildLoadingCard(),
              ],
              
              // Box de erro (duplicata)
              if (hasError && !isSelecting) ...[
                SizedBox(height: 16),
                _buildDuplicateErrorBox(),
              ],
              
              // Sugestões de busca (apenas se não tiver erro)
              if (widget.viewModel.showSuggestions && !isSelecting && !hasError) ...[
                SizedBox(height: 16),
                _buildSuggestionsDropdown(),
              ],
              
              // Card de confirmação (local novo)
              if (hasSelectedPlace && !isSelecting && !hasError) ...[
                SizedBox(height: 16),
                _buildSelectedPlaceCard(),
              ],
              
              SizedBox(height: 180),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _searchFocusNode,
        widget.viewModel.searchPlaces,
      ]),
      builder: (context, _) {
        final isFocused = _searchFocusNode.hasFocus;
        final isSearching = widget.viewModel.searchPlaces.running;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.papayaSensorial
                  : AppColors.moonAsh.withOpacity(0.15),
              width: isFocused ? 2 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.papayaSensorial.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    color: AppColors.carbon,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      AppIcons.location,
                      color: isFocused
                          ? AppColors.papayaSensorial
                          : AppColors.grayScale2,
                      size: 22,
                    ),
                    hintText: 'Digite o nome da cafeteria',
                    hintStyle: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.grayScale2.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                  cursorColor: AppColors.papayaSensorial,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isSearching ? null : _performSearch,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.papayaSensorial,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isSearching
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
                            : Icon(
                                AppIcons.search,
                                size: 20,
                                color: AppColors.whiteWhite,
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

  Widget _buildDuplicateErrorBox() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ops! Essa cafeteria já está no nosso mapa.',
            style: GoogleFonts.albertSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.carbon,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.papayaSensorial,
                width: 1,
              ),
            ),
            child: Text(
              'Se ela ainda não estiver visível, é porque ainda estamos validando. Aguarde!',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.carbon.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.papayaSensorial,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Verificando se este local já está cadastrado...',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Resultados encontrados (${widget.viewModel.placeSuggestions.length})',
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
            itemCount: widget.viewModel.placeSuggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.moonAsh,
            ),
            itemBuilder: (context, index) {
              final suggestion = widget.viewModel.placeSuggestions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: index == widget.viewModel.placeSuggestions.length - 1
                      ? BorderRadius.vertical(bottom: Radius.circular(12))
                      : BorderRadius.zero,
                  onTap: () => _handlePlaceSelection(suggestion),
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
        ],
      ),
    );
  }

  Widget _buildSelectedPlaceCard() {
    final place = widget.viewModel.selectedPlace!;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parece que a ${place.name} ainda não está no nosso mapa de cafeterias. Quer cadastrar agora?',
            style: GoogleFonts.albertSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.carbon,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pear.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pear,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  place.address,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.carbon.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}