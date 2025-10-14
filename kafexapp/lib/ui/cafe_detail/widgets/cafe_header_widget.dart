// lib/ui/cafe_detail/widgets/cafe_header_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../models/cafe_detail_model.dart';
import '../view_model/cafe_detail_view_model.dart';
import 'cafe_facility_widget.dart';

class CafeHeaderWidget extends StatelessWidget {
  const CafeHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeDetailViewModel>(
      builder: (context, viewModel, child) {
        final cafe = viewModel.cafe;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da cafeteria
            _buildCafeImage(context, cafe),
            SizedBox(height: 16),
            
            // Header com nome, rating e Instagram
            _buildCafeInfo(context, cafe, viewModel),
            SizedBox(height: 12),
            
            // Endereço
            _buildAddress(context, cafe),
            SizedBox(height: 16),
            
            // Botões Favoritar e Quero Visitar (mesmo design dos posts)
            _buildFavoriteAndWantToVisitButtons(context, viewModel),
            SizedBox(height: 16),
            
            // Status e facilidades
            _buildStatusAndFacilities(context, cafe),
          ],
        );
      },
    );
  }

  Widget _buildCafeImage(BuildContext context, CafeDetailModel cafe) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(cafe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCafeInfo(BuildContext context, CafeDetailModel cafe, CafeDetailViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da cafeteria
              Text(
                cafe.name,
                style: GoogleFonts.albertSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 6),
              
              // Rating com estrelas
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/grain_note.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.sunsetBlaze,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${cafe.rating}',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Ícone do Instagram
        IconButton(
          onPressed: viewModel.isLoading ? null : () => viewModel.openInstagram(),
          icon: Icon(
            PhosphorIcons.instagramLogo(),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress(BuildContext context, CafeDetailModel cafe) {
    return Text(
      cafe.address,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  Widget _buildFavoriteAndWantToVisitButtons(BuildContext context, CafeDetailViewModel viewModel) {
    return Row(
      children: [
        // Botão Favorito (mesmo design dos posts)
        Expanded(
          child: GestureDetector(
            onTap: viewModel.isLoading ? null : () => viewModel.toggleFavorite(),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: viewModel.isFavorited ? AppColors.papayaSensorial : AppColors.moonAsh,
                borderRadius: BorderRadius.circular(12),
                border: viewModel.isFavorited 
                  ? Border.all(color: AppColors.papayaSensorial, width: 1)
                  : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    viewModel.isFavorited ? AppIcons.starFill : AppIcons.star,
                    color: viewModel.isFavorited ? AppColors.whiteWhite : AppColors.carbon,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    viewModel.isFavorited ? 'Favoritado' : 'Favoritar',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: viewModel.isFavorited ? AppColors.whiteWhite : AppColors.carbon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Botão Quero Visitar (mesmo design dos posts)
        Expanded(
          child: GestureDetector(
            onTap: viewModel.isLoading ? null : () => viewModel.toggleWantToVisit(),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: viewModel.wantToVisit ? AppColors.pear : AppColors.moonAsh,
                borderRadius: BorderRadius.circular(12),
                border: viewModel.wantToVisit 
                  ? Border.all(color: AppColors.pear, width: 1)
                  : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    viewModel.wantToVisit ? AppIcons.tagFill : AppIcons.tag,
                    color: viewModel.wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    viewModel.wantToVisit ? 'Na lista!' : 'Quero visitar',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: viewModel.wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndFacilities(BuildContext context, CafeDetailModel cafe) {
    return Row(
      children: [
        // Status (Aberto/Fechado)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cafe.isOpen 
                ? Theme.of(context).colorScheme.primaryContainer 
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cafe.isOpen ? 'Aberto' : 'Fechado',
            style: GoogleFonts.albertSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cafe.isOpen 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
        
        // Horário de abertura (apenas quando fechado)
        if (!cafe.isOpen) ...[
          SizedBox(width: 8),
          Text(
            cafe.openingHours,
            style: GoogleFonts.albertSans(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        Spacer(),
        
        // Facilidades
        Row(
          children: cafe.facilities
              .map((facility) => CafeFacilityWidget(facility: facility))
              .toList(),
        ),
      ],
    );
  }
}