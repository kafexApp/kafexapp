// lib/ui/cafe_explorer/widgets/search/search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';
import '../../viewmodel/cafe_explorer_viewmodel.dart';

class CafeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final CafeExplorerViewModel viewModel;
  final VoidCallback onSearch;

  const CafeSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.viewModel,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        focusNode,
        viewModel.searchPlaces,
        controller,
      ]),
      builder: (context, _) {
        final isFocused = focusNode.hasFocus;
        final isSearching = viewModel.searchPlaces.running;
        final hasText = controller.text.isNotEmpty;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused 
                  ? AppColors.papayaSensorial 
                  : Colors.transparent,
              width: 2,
            ),
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
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Busque endereços, cafés ou estabelecimentos',
                      hintStyle: GoogleFonts.albertSans(
                        color: AppColors.grayScale2,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.transparent,
                      filled: false,
                    ),
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.carbon,
                    ),
                    cursorColor: AppColors.papayaSensorial,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
              ),
              if (hasText)
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        controller.clear();
                        viewModel.clearSuggestions();
                        viewModel.clearSearch();
                        focusNode.unfocus();
                      },
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.grayScale2,
                        ),
                      ),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isSearching ? null : onSearch,
                    child: Center(
                      child: isSearching
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}