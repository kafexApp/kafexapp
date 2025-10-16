// lib/ui/cafe_explorer/widgets/search/suggestions_list.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/app_colors.dart';
import '../../viewmodel/cafe_explorer_viewmodel.dart';

class SuggestionsList extends StatelessWidget {
  final CafeExplorerViewModel viewModel;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GoogleMapController? mapController;
  final VoidCallback? onSuggestionSelected;

  const SuggestionsList({
    Key? key,
    required this.viewModel,
    required this.searchController,
    required this.searchFocusNode,
    this.mapController,
    this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!viewModel.hasSuggestions) {
      return SizedBox.shrink();
    }

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
                        searchController.text = suggestion.description;
                        searchFocusNode.unfocus();

                        await viewModel.selectPlace.execute(suggestion);

                        if (viewModel.isMapView && mapController != null) {
                          await mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              viewModel.currentPosition,
                              16.0,
                            ),
                          );
                        }

                        onSuggestionSelected?.call();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                  color: AppColors.papayaSensorial
                                      .withOpacity(0.1),
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
}