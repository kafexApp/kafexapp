import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import 'base_post_card.dart';

class NewCoffeePostCard extends BasePostCard {
  final String coffeeName;
  final String coffeeAddress;
  final String coffeeId;
  final VoidCallback? onEvaluateNow;

  const NewCoffeePostCard({
    Key? key,
    required PostData post,
    required this.coffeeName,
    required this.coffeeAddress,
    required this.coffeeId,
    this.onEvaluateNow,
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
  State<NewCoffeePostCard> createState() => _NewCoffeePostCardState();
}

class _NewCoffeePostCardState extends BasePostCardState<NewCoffeePostCard> {
  
  void _openEvaluationModal() {
    widget.onEvaluateNow?.call();
    // Aqui você pode abrir o modal de avaliação
    print('🎯 Abrir modal de avaliação para: ${widget.coffeeName}');
  }

  @override
  Widget buildCustomActions() {
    return Column(
      children: [
        // Banner de nova cafeteria
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.papayaSensorial,
                AppColors.velvetMerlot,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.whiteWhite,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'NOVA CAFETERIA',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteWhite,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        
        // Card com informações da cafeteria
        Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.oatWhite,
                AppColors.whiteWhite,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.papayaSensorial.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.papayaSensorial.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.papayaSensorial.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.coffee,
                        color: AppColors.papayaSensorial,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.coffeeName,
                            style: GoogleFonts.albertSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.grayScale2,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.coffeeAddress,
                                  style: GoogleFonts.albertSans(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botão de avaliar
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _openEvaluationModal,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.papayaSensorial,
                          AppColors.velvetMerlot,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.papayaSensorial.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_outline,
                          color: AppColors.whiteWhite,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Avaliar agora',
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.whiteWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Texto motivacional
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seja o primeiro a avaliar esta cafeteria!',
                          style: GoogleFonts.albertSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Ações padrão do post (like, comment, save)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: toggleLike,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    isLiked ? AppIcons.heartFill : AppIcons.heart,  // MUDANÇA: sem underscore
                    color: isLiked ? AppColors.spiced : AppColors.grayScale2,  // MUDANÇA: sem underscore
                    size: 24,
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  widget.onComment?.call();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.comment,
                        color: AppColors.grayScale2,
                        size: 24,
                      ),
                      if (widget.post.comments > 0) ...[
                        SizedBox(width: 4),
                        Text(
                          '${widget.post.comments}',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: AppColors.grayScale2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              Spacer(),
              
              GestureDetector(
                onTap: () {
                  print('Compartilhar nova cafeteria');
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.share_outlined,
                    color: AppColors.grayScale2,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildAdditionalContent() {
    return SizedBox(height: 16);
  }
}