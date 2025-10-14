import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/viewmodel/post_actions_viewmodel.dart';
import 'package:kafex/ui/posts/widgets/base_post_widget.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';
import 'package:kafex/widgets/comments_bottom_sheet.dart';
import 'package:kafex/widgets/cafe_evaluation_modal.dart';
import 'package:kafex/widgets/custom_toast.dart';
import 'package:kafex/ui/cafe_detail/widgets/cafe_detail_modal.dart';

// Classes mock para compatibilidade com o CustomBoxcafe
class MockLatLng {
  final double latitude;
  final double longitude;
  MockLatLng(this.latitude, this.longitude);
}

class MockCafeModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final bool isOpen;
  final MockLatLng position;

  MockCafeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.isOpen,
    required this.position,
  });
}

class NewCoffeePostWidget extends BasePostWidget {
  const NewCoffeePostWidget({
    Key? key,
    required Post post,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) : super(
         key: key,
         post: post,
         onLike: onLike,
         onComment: onComment,
         onEdit: onEdit,
         onDelete: onDelete,
       );

  @override
  State<NewCoffeePostWidget> createState() => _NewCoffeePostWidgetState();
}

class _NewCoffeePostWidgetState
    extends BasePostWidgetState<NewCoffeePostWidget> {
  void _toggleFavorite(PostActionsViewModel viewModel) {
    viewModel.toggleFavorite.execute();

    if (viewModel.isFavorited) {
      CustomToast.show(
        context,
        message:
            'Essa cafeteria foi adicionada em sua lista de cafeterias favoritas.',
        type: ToastType.success,
        customIcon: Icon(
          AppIcons.starFill,
          color: AppColors.cyberLime,
          size: 20,
        ),
      );
    } else {
      CustomToast.show(
        context,
        message:
            'Essa cafeteria foi removida da sua lista de cafeterias favoritas.',
        type: ToastType.info,
        customIcon: Icon(AppIcons.star, color: AppColors.cyberLime, size: 20),
      );
    }
  }

  void _toggleWantToVisit(PostActionsViewModel viewModel) {
    viewModel.toggleWantToVisit.execute();

    if (viewModel.wantToVisit) {
      CustomToast.show(
        context,
        message:
            'Essa cafeteria foi adicionada em sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.success,
        customIcon: Icon(
          AppIcons.tagFill,
          color: AppColors.cyberLime,
          size: 20,
        ),
      );
    } else {
      CustomToast.show(
        context,
        message:
            'Essa cafeteria foi removida da sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.info,
        customIcon: Icon(AppIcons.tag, color: AppColors.cyberLime, size: 20),
      );
    }
  }

  void _openCafeModal(PostActionsViewModel viewModel) {
    print('🔍 DEBUG: coffeeId = ${viewModel.coffeeId}');
    print('🔍 DEBUG: coffeeName = ${viewModel.coffeeName}');
    print('🔍 DEBUG: rating = ${viewModel.rating}');
    print('🔍 DEBUG POST COMPLETO:');
    print('   widget.post.id = ${widget.post.id}');
    print('   widget.post.coffeeId = ${widget.post.coffeeId}');
    print('   widget.post.coffeeName = ${widget.post.coffeeName}');
    print('   widget.post.rating = ${widget.post.rating}');
    print('   widget.post.type = ${widget.post.type}');

    final mockCafeModel = MockCafeModel(
      id: viewModel.coffeeId ?? '',
      name: viewModel.coffeeName ?? '',
      address: viewModel.coffeeAddress ?? '',
      rating: 4.5,
      imageUrl:
          widget.post.imageUrl ??
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      isOpen: true,
      position: MockLatLng(-23.5505, -46.6333),
    );

    showCafeDetailModal(context, mockCafeModel);
  }

  void _openEvaluationModal(PostActionsViewModel viewModel) {
    showCafeEvaluationModal(
      context,
      cafeName: viewModel.coffeeName ?? '',
      cafeId: viewModel.coffeeId ?? '',
    );
  }

  @override
  Widget buildPostMedia(PostActionsViewModel viewModel) {
    final hasValidImage =
        widget.post.imageUrl != null &&
        widget.post.imageUrl!.isNotEmpty &&
        widget.post.imageUrl!.startsWith('http');

    if (!hasValidImage) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        super.buildPostMedia(viewModel),

        // Tag "NOVA CAFETERIA"
        Positioned(
          top: 16,
          left: 32,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pear,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.fire, color: AppColors.carbon, size: 14),
                SizedBox(width: 6),
                Text(
                  'NOVA CAFETERIA',
                  style: GoogleFonts.albertSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.carbon,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildAdditionalContent(PostActionsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DESCRIÇÃO
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: widget.post.authorName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' '),
                TextSpan(text: 'descobriu uma nova cafeteria'),
              ],
            ),
          ),
        ),

        // INFORMAÇÕES DA NOVA CAFETERIA
        Container(
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pear.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.pear.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da cafeteria com badge "NOVA"
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pear,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.star, color: AppColors.carbon, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'NOVA',
                          style: GoogleFonts.albertSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.carbon,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openCafeModal(viewModel),
                      child: Text(
                        viewModel.coffeeName ?? 'Nova Cafeteria',
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (viewModel.coffeeAddress?.isNotEmpty == true) ...[
                SizedBox(height: 8),
                Text(
                  viewModel.coffeeAddress ?? '',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.grayScale1,
                  ),
                ),
              ],
            ],
          ),
        ),

        // BOTÕES DE AÇÃO (FAVORITO E QUERO VISITAR)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Botão Favorito
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleFavorite(viewModel),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: viewModel.isFavorited
                          ? AppColors.papayaSensorial
                          : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: viewModel.isFavorited
                          ? Border.all(
                              color: AppColors.papayaSensorial,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          viewModel.isFavorited
                              ? AppIcons.starFill
                              : AppIcons.star,
                          color: viewModel.isFavorited
                              ? AppColors.whiteWhite
                              : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          viewModel.isFavorited ? 'Favoritado' : 'Favoritar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: viewModel.isFavorited
                                ? AppColors.whiteWhite
                                : AppColors.carbon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Botão Quero Visitar
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleWantToVisit(viewModel),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: viewModel.wantToVisit
                          ? AppColors.pear
                          : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: viewModel.wantToVisit
                          ? Border.all(color: AppColors.pear, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          viewModel.wantToVisit
                              ? AppIcons.tagFill
                              : AppIcons.tag,
                          color: viewModel.wantToVisit
                              ? AppColors.velvetMerlot
                              : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          viewModel.wantToVisit ? 'Na lista!' : 'Quero visitar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: viewModel.wantToVisit
                                ? AppColors.velvetMerlot
                                : AppColors.carbon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // BOTÃO AVALIAR CAFETERIA
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () => _openEvaluationModal(viewModel),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.velvetMerlot,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Avaliar cafeteria',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.papayaSensorial,
                  ),
                ),
              ),
            ),
          ),
        ),

        // CONTADOR DE COMENTÁRIOS
        if (widget.post.comments > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: GestureDetector(
              onTap: () {
                widget.onComment?.call();
                showCommentsModal(
                  context,
                  postId: widget.post.id,
                  comments: [],
                  onCommentAdded: (newComment) {
                    print('Novo comentário adicionado: $newComment');
                  },
                );
              },
              child: Text(
                'Ver ${widget.post.comments == 1 ? '1 comentário' : 'todos os ${widget.post.comments} comentários'}',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale1,
                ),
              ),
            ),
          )
        else
          SizedBox(height: 16),
      ],
    );
  }
}
