// lib/ui/cafe_explorer/widgets/search/suggestions_list.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';
import '../../viewmodel/cafe_explorer_viewmodel.dart';

class SuggestionsList extends StatelessWidget {
  final CafeExplorerViewModel viewModel;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GoogleMapController? mapController;
  final VoidCallback onSuggestionSelected;

  const SuggestionsList({
    Key? key,
    required this.viewModel,
    required this.searchController,
    required this.searchFocusNode,
    required this.mapController,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!viewModel.hasSuggestions) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header do dropdown
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Resultados encontrados (${viewModel.suggestions.length})',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    Spacer(),
                    // Botão fechar
                    GestureDetector(
                      onTap: () {
                        viewModel.clearSuggestions();
                        searchFocusNode.unfocus();
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.grayScale2,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.moonAsh),
              
              // Lista com scroll
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: viewModel.suggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.moonAsh,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = viewModel.suggestions[index];
                    final isLast = index == viewModel.suggestions.length - 1;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: isLast 
                            ? BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              )
                            : BorderRadius.zero,
                        onTap: () async {
                          searchController.text = suggestion.description;
                          searchFocusNode.unfocus();

                          await viewModel.selectPlace.execute(suggestion);

                          if (viewModel.isMapView && mapController != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                viewModel.currentPosition,
                                15.0,
                              ),
                            );
                          }

                          onSuggestionSelected();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Ícone
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
                              
                              // Texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            suggestion.mainText,
                                            style: GoogleFonts.albertSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.carbon,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (suggestion.isEstablishment)
                                          Container(
                                            margin: EdgeInsets.only(left: 8),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.papayaSensorial
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Local',
                                              style: GoogleFonts.albertSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.papayaSensorial,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      suggestion.secondaryText,
                                      style: GoogleFonts.albertSans(
                                        fontSize: 14,
                                        color: AppColors.grayScale1,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}