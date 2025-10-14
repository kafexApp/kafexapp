// lib/ui/cafe_detail/widgets/cafe_reviews_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/date_extensions.dart';
import '../models/user_review_model.dart';

class CafeReviewsModal extends StatelessWidget {
  final String cafeName;
  final List<UserReview> reviews;

  const CafeReviewsModal({
    Key? key,
    required this.cafeName,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle clean
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context),

          // Lista de avaliações
          Flexible(
            child: reviews.isEmpty
                ? _buildEmptyState(context)
                : _buildReviewsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avaliações',
                      style: GoogleFonts.albertSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      cafeName,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  PhosphorIcons.x(),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Estatísticas das avaliações
          if (reviews.isNotEmpty) _buildReviewStats(context),
        ],
      ),
    );
  }

  Widget _buildReviewStats(BuildContext context) {
    final double averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) /
        reviews.length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rating médio
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.albertSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: SvgPicture.asset(
                      'assets/images/grain_note.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        index < averageRating.floor()
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

          SizedBox(width: 24),

          // Total de avaliações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reviews.length} ${reviews.length == 1 ? 'avaliação' : 'avaliações'}',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Baseado nas experiências dos usuários',
                  style: GoogleFonts.albertSans(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/grain_note.svg',
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhuma avaliação ainda',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seja o primeiro a avaliar esta cafeteria!',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 20),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewItem(context, review, index == reviews.length - 1);
      },
    );
  }

  Widget _buildReviewItem(
    BuildContext context,
    UserReview review,
    bool isLast,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 0 : 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da avaliação
          Row(
            children: [
              // Avatar do usuário
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.moonAsh,
                backgroundImage: review.userAvatar.isNotEmpty
                    ? NetworkImage(review.userAvatar)
                    : null,
                child: review.userAvatar.isEmpty
                    ? Icon(
                        PhosphorIcons.user(),
                        color: AppColors.carbon,
                        size: 24,
                      )
                    : null,
              ),

              SizedBox(width: 12),

              // Info do usuário
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
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

              // Rating da avaliação
              Row(
                children: List.generate(5, (starIndex) {
                  return Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: SvgPicture.asset(
                      'assets/images/grain_note.svg',
                      width: 16,
                      height: 16,
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

          SizedBox(height: 16),

          // Texto da avaliação
          Text(
            review.comment,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),

          SizedBox(height: 16),

          // Ações da avaliação
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Implementar curtir avaliação
                },
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
          ),
        ],
      ),
    );
  }
}

// Função para mostrar o modal
void showCafeReviewsModal(
  BuildContext context,
  String cafeName,
  List<UserReview> reviews,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          CafeReviewsModal(cafeName: cafeName, reviews: reviews),
    ),
  );
}
