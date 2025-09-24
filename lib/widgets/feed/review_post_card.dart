import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _isDescriptionExpanded = false;

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
    
    if (_isFavorited) {
      print('Adicionou ${widget.coffeeName} aos favoritos');
      // TODO: Implementar adição aos favoritos no backend
    } else {
      print('Removeu ${widget.coffeeName} dos favoritos');
      // TODO: Implementar remoção dos favoritos no backend
    }
    
    widget.onFavorite?.call();
  }

  void _toggleWantToVisit() {
    setState(() {
      _wantToVisit = !_wantToVisit;
    });
    
    if (_wantToVisit) {
      print('Adicionou ${widget.coffeeName} à lista "Quero visitar"');
      // TODO: Implementar adição à lista "Quero visitar" no backend
    } else {
      print('Removeu ${widget.coffeeName} da lista "Quero visitar"');
      // TODO: Implementar remoção da lista "Quero visitar" no backend
    }
    
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
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Botão Like
          GestureDetector(
            onTap: toggleLike,
            child: Icon(
              isLiked ? AppIcons.heartFill : AppIcons.heart,
              size: 24,
              color: isLiked ? AppColors.spiced : AppColors.carbon,
            ),
          ),
          
          SizedBox(width: 16),
          
          // Botão Comentário
          GestureDetector(
            onTap: _openCommentsModal,
            child: Icon(
              AppIcons.comment,
              size: 24,
              color: AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildAdditionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              // Nome da cafeteria
              Text(
                widget.coffeeName,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.carbon,
                ),
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
                          index < widget.rating.floor() 
                            ? AppColors.papayaSensorial 
                            : AppColors.grayScale2,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 8),
                  Text(
                    widget.rating.toStringAsFixed(1),
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                    ),
                  ),
                ],
              ),
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
                  onTap: _toggleFavorite,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isFavorited ? AppColors.papayaSensorial : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: _isFavorited 
                        ? Border.all(color: AppColors.papayaSensorial, width: 1)
                        : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFavorited ? AppIcons.starFill : AppIcons.star,
                          color: _isFavorited ? AppColors.whiteWhite : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _isFavorited ? 'Favoritado' : 'Favoritar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isFavorited ? AppColors.whiteWhite : AppColors.carbon,
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
                  onTap: _toggleWantToVisit,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _wantToVisit ? AppColors.pear : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: _wantToVisit 
                        ? Border.all(color: AppColors.pear, width: 1)
                        : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _wantToVisit ? AppIcons.tagFill : AppIcons.tag,
                          color: _wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _wantToVisit ? 'Na lista!' : 'Quero visitar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
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
            onTap: () {
              print('Abrir modal de avaliação para: ${widget.coffeeName}');
              // TODO: Implementar abertura do modal de avaliação
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
              onTap: _openCommentsModal,
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