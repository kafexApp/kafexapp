import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/viewmodel/post_actions_viewmodel.dart';
import 'package:kafex/ui/posts/widgets/base_post_widget.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';
import 'package:kafex/widgets/comments_bottom_sheet.dart';
import 'package:kafex/widgets/cafe_evaluation_modal.dart';
import 'package:kafex/widgets/custom_toast.dart';
import 'package:kafex/widgets/custom_boxcafe.dart';

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

class ReviewPostWidget extends BasePostWidget {
  const ReviewPostWidget({
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
  State<ReviewPostWidget> createState() => _ReviewPostWidgetState();
}

class _ReviewPostWidgetState extends BasePostWidgetState<ReviewPostWidget> {
  
  void _toggleFavorite(PostActionsViewModel viewModel) {
    viewModel.toggleFavorite.execute();
    
    if (viewModel.isFavorited) {
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi adicionada em sua lista de cafeterias favoritas.',
        type: ToastType.success,
        customIcon: Icon(AppIcons.starFill, color: AppColors.cyberLime, size: 20),
      );
    } else {
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi removida da sua lista de cafeterias favoritas.',
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
        message: 'Essa cafeteria foi adicionada em sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.success,
        customIcon: Icon(AppIcons.tagFill, color: AppColors.cyberLime, size: 20),
      );
    } else {
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi removida da sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.info,
        customIcon: Icon(AppIcons.tag, color: AppColors.cyberLime, size: 20),
      );
    }
  }

  void _openCafeModal(PostActionsViewModel viewModel) {
    final mockCafeModel = MockCafeModel(
      id: viewModel.coffeeId ?? '',
      name: viewModel.coffeeName ?? '',
      address: 'Endereço da cafeteria',
      rating: viewModel.rating ?? 0.0,
      imageUrl: widget.post.imageUrl ?? 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      isOpen: true,
      position: MockLatLng(-23.5505, -46.6333),
    );

    showCafeModal(context, mockCafeModel);
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
                TextSpan(
                  text: widget.post.content.isNotEmpty 
                    ? widget.post.content 
                    : 'avaliou a cafeteria ${viewModel.coffeeName}',
                ),
              ],
            ),
          ),
        ),
        
        // BOX COM INFORMAÇÕES DA CAFETERIA AVALIADA
        Container(
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.moonAsh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da cafeteria com ícone
              Row(
                children: [
                  Icon(
                    AppIcons.coffee,
                    color: AppColors.papayaSensorial,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openCafeModal(viewModel),
                      child: Text(
                        viewModel.coffeeName ?? 'Cafeteria',
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
              
              SizedBox(height: 12),
              
              // Avaliação com grãos de café
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: 4),
                      child: SvgPicture.asset(
                        'assets/images/grain_note.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          index < (viewModel.rating ?? 0).floor() 
                            ? AppColors.papayaSensorial 
                            : AppColors.grayScale2,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8),
                  Text(
                    (viewModel.rating ?? 0.0).toStringAsFixed(1),
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.velvetMerlot,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // BOTÃO AVALIAR CAFETERIA
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () {
              showCafeEvaluationModal(
                context,
                cafeName: viewModel.coffeeName ?? '',
                cafeId: viewModel.coffeeId ?? '',
              );
            },
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
                    print('📝 Novo comentário adicionado: $newComment');
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