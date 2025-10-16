// lib/ui/cafe_explorer/widgets/list/cafe_list_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../../../data/models/domain/cafe.dart';
import '../../../../models/cafe_model.dart';
import '../../../../widgets/custom_boxcafe_minicard.dart';

class CafeListView extends StatelessWidget {
  final List<Cafe> cafes;
  final bool isShowingSearchResults;
  final String searchAddress;
  final VoidCallback onClearSearch;

  const CafeListView({
    Key? key,
    required this.cafes,
    this.isShowingSearchResults = false,
    this.searchAddress = '',
    required this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cafes.isEmpty && isShowingSearchResults) {
      return _buildNoResultsMessage(context);
    }

    if (cafes.isEmpty) {
      return _buildLoadingMessage();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 180, 20, 120),
      itemCount: cafes.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          child: CustomBoxcafeMinicard(
            cafe: _convertToOldModel(cafes[index]),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildNoResultsMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppColors.grayScale2,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Ops, não encontrei nenhum resultado na sua busca',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            if (searchAddress.isNotEmpty)
              Text(
                'Nenhuma cafeteria encontrada próxima a:\n"$searchAddress"',
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.papayaSensorial,
                  foregroundColor: AppColors.whiteWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Ver todas as cafeterias',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 200),
        child: Text(
          'Carregando cafeterias...',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale1,
          ),
        ),
      ),
    );
  }

  CafeModel _convertToOldModel(Cafe cafe) {
    return CafeModel(
      id: cafe.id,
      name: cafe.name,
      address: cafe.address,
      rating: cafe.rating,
      distance: cafe.distance,
      imageUrl: cafe.imageUrl,
      isOpen: cafe.isOpen,
      position: cafe.position,
      price: cafe.price,
      specialties: List<String>.from(cafe.specialties),
    );
  }
}