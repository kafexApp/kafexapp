// lib/ui/cafe_detail/widgets/cafe_review_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/date_extensions.dart';
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

  Widget _buildReviewCard(
    BuildContext context,
    UserReview review,
    CafeDetailViewModel viewModel,
  ) {
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
          _buildReviewHeader(context, review),
          SizedBox(height: 12),
          _buildReviewContent(context, review),
          SizedBox(height: 12),
          _buildReviewActions(context, review, viewModel),
        ],
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context, UserReview review) {
    return Row(
      children: [
        // Avatar do usuário
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.moonAsh,
          backgroundImage: review.userAvatar.isNotEmpty
              ? NetworkImage(review.userAvatar)
              : null,
          child: review.userAvatar.isEmpty
              ? Icon(PhosphorIcons.user(), color: AppColors.carbon, size: 20)
              : null,
        ),
        SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  // Estrelas da avaliação
                  Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          'assets/images/grain_note.svg',
                          width: 12,
                          height: 12,
                          colorFilter: ColorFilter.mode(
                            index < review.rating.floor()
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
                review.date.toRelativeTime(),
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
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildReviewActions(
    BuildContext context,
    UserReview review,
    CafeDetailViewModel viewModel,
  ) {
    return Row(
      children: [
        // Botão curtir
        TextButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.likeReview(review.id),
          icon: Icon(
            review.isLiked
                ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                : PhosphorIcons.heart(),
            size: 16,
            color: review.isLiked
                ? AppColors.sunsetBlaze
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          label: Text(
            review.likes > 0 ? '${review.likes}' : 'Útil',
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
          review.date.toRelativeTime(),
          style: GoogleFonts.albertSans(
            fontSize: 11,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(
    BuildContext context,
    CafeDetailViewModel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => viewModel.showAllReviews(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Ver todas as avaliações (${viewModel.cafe.reviews.length})',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
