// lib/ui/cafe_detail/widgets/cafe_review_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../models/user_review_model.dart';
import '../view_model/cafe_detail_view_model.dart';
import 'cafe_reviews_modal.dart';

class CafeReviewWidget extends StatelessWidget {
  const CafeReviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeDetailViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.hasReviews) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Text(
              'Avaliações',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            
            // Card da última avaliação
            _buildReviewCard(context, viewModel.cafe.reviews.first, viewModel),
            SizedBox(height: 12),
            
            // Botão "Ver todas as avaliações"
            _buildViewAllButton(context, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, UserReview review, CafeDetailViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do comentário
          _buildReviewHeader(context, review),
          SizedBox(height: 12),
          
          // Conteúdo do comentário
          _buildReviewContent(context, review),
          SizedBox(height: 16),
          
          // Ações do comentário
          _buildReviewActions(context, review, viewModel),
        ],
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context, UserReview review) {
    return Row(
      children: [
        // Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://images.unsplash.com/photo-1494790108755-2616b612b17c?w=150&h=150&fit=crop&crop=face',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  PhosphorIcons.user(),
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            },
          ),
        ),
        
        SizedBox(width: 12),
        
        // Info do usuário
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome + Rating na mesma linha
              Row(
                children: [
                  Text(
                    review.userName,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 8),
                  // Rating com grain_note.svg
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Padding(
                        padding: EdgeInsets.only(right: 1),
                        child: SvgPicture.asset(
                          'assets/images/grain_note.svg',
                          width: 12,
                          height: 12,
                          colorFilter: ColorFilter.mode(
                            starIndex < review.rating.floor() 
                                ? AppColors.sunsetBlaze 
                                : Theme.of(context).colorScheme.outlineVariant,
                            BlendMode.srcIn,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                review.date,
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewContent(BuildContext context, UserReview review) {
    return Text(
      review.comment,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      ),
    );
  }

  Widget _buildReviewActions(BuildContext context, UserReview review, CafeDetailViewModel viewModel) {
    return Row(
      children: [
        // Botão curtir
        TextButton.icon(
          onPressed: viewModel.isLoading ? null : () => viewModel.likeReview(review.userId),
          icon: Icon(
            PhosphorIcons.heart(),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          label: Text(
            'Útil',
            style: GoogleFonts.albertSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size(0, 0),
          ),
        ),
        
        Spacer(),
        
        // Timestamp relativo
        Text(
          '2 semanas atrás',
          style: GoogleFonts.albertSans(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context, CafeDetailViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: viewModel.isLoading ? null : () {
          showCafeReviewsModal(context, viewModel.cafe.name, viewModel.cafe.reviews);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/grain_note.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Ver todas as avaliações',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}