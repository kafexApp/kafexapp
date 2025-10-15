import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../../../models/cafe_model.dart';
import '../../../../widgets/custom_boxcafe_minicard.dart';
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
      widget.viewModel.searchPlaces.execute(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 20),
          InfoBanner(
            title: 'Conhece lugares legais para tomar bons cafés?',
            subtitle: 'Adicione em nosso explorador de cafeterias',
          ),
          SizedBox(height: 30),
          _buildSearchField(),
          if (widget.viewModel.showSuggestions) ...[
            SizedBox(height: 16),
            _buildSuggestionsDropdown(),
          ],
          if (widget.viewModel.selectedPlace != null) ...[
            SizedBox(height: 16),
            _buildSelectedPlaceCard(),
          ],
          SizedBox(height: 180),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
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
      child: ListenableBuilder(
        listenable: widget.viewModel.searchPlaces,
        builder: (context, _) {
          final isSearching = widget.viewModel.searchPlaces.running;

          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: GoogleFonts.albertSans(
              fontSize: 16,
              color: AppColors.carbon,
            ),
            decoration: InputDecoration(
              hintText: 'Digite o nome da cafeteria',
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
              suffixIcon: isSearching
                  ? Container(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.papayaSensorial,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: _performSearch,
                      icon: Icon(
                        AppIcons.search,
                        size: 20,
                        color: AppColors.papayaSensorial,
                      ),
                      tooltip: 'Buscar',
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
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
          );
        },
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
                  onTap: () {
                    widget.viewModel.selectPlace.execute(suggestion);
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
        ],
      ),
    );
  }

  Widget _buildSelectedPlaceCard() {
    final place = widget.viewModel.selectedPlace!;

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
                  'Local selecionado!',
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
}