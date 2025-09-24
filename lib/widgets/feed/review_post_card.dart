import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../comments_bottom_sheet.dart';
import 'base_post_card.dart';

class ReviewPostCard extends BasePostCard {
  final String coffeeName;
  final double rating;
  final String coffeeId;
  final bool isFavorited;
  final bool wantToVisit;
  final VoidCallback? onFavorite;
  final VoidCallback? onWantToVisit;

  const ReviewPostCard({
    Key? key,
    required PostData post,
    required this.coffeeName,
    required this.rating,
    required this.coffeeId,
    this.isFavorited = false,
    this.wantToVisit = false,
    this.onFavorite,
    this.onWantToVisit,
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
  State<ReviewPostCard> createState() => _ReviewPostCardState();
}

class _ReviewPostCardState extends BasePostCardState<ReviewPostCard> {
  late bool _isFavorited;
  late bool _wantToVisit;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _wantToVisit = widget.wantToVisit;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    widget.onFavorite?.call();
  }

  void _toggleWantToVisit() {
    setState(() {
      _wantToVisit = !_wantToVisit;
    });
    widget.onWantToVisit?.call();
  }

  void _openCommentsModal() {
    widget.onComment?.call();
    
    showCommentsModal(
      context,
      postId: widget.post.id,
      comments: [],
      onCommentAdded: (newComment) {
        print('📝 Novo comentário adicionado: $newComment');
      },
    );
  }

  @override
  Widget buildCustomActions() {
    return Column(
      children: [
        // Card da cafeteria avaliada
        Container(
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.oatWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.moonAsh,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.coffee,
                    color: AppColors.papayaSensorial,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.coffeeName,
                      style: GoogleFonts.albertSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Estrelas de avaliação
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < widget.rating.floor() 
                        ? Icons.star 
                        : (index < widget.rating ? Icons.star_half : Icons.star_border),
                      color: AppColors.papayaSensorial,
                      size: 18,
                    );
                  }),
                  SizedBox(width: 8),
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Botões de ação da cafeteria
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isFavorited 
                            ? AppColors.papayaSensorial 
                            : AppColors.whiteWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.papayaSensorial,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFavorited ? AppIcons.heartFill : AppIcons.heart,
                              color: _isFavorited 
                                ? AppColors.whiteWhite 
                                : AppColors.papayaSensorial,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Favoritar',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isFavorited 
                                  ? AppColors.whiteWhite 
                                  : AppColors.papayaSensorial,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleWantToVisit,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _wantToVisit 
                            ? AppColors.forestInk 
                            : AppColors.whiteWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _wantToVisit 
                              ? AppColors.forestInk 
                              : AppColors.grayScale2,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              color: _wantToVisit 
                                ? AppColors.whiteWhite 
                                : AppColors.grayScale2,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Quero visitar',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _wantToVisit 
                                  ? AppColors.whiteWhite 
                                  : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Ações padrão do post (like, comment, save)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                onTap: _openCommentsModal,
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
                  print('Toggle salvar post');
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    AppIcons.bookmark,
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
    if (widget.post.comments > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GestureDetector(
              onTap: _openCommentsModal,
              child: Text(
                'Ver todos os ${widget.post.comments} comentários',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(height: 16);
  }
}