import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../comments_bottom_sheet.dart';
import '../../screens/user_profile_screen.dart';
import 'base_post_card.dart';

class TraditionalPostCard extends BasePostCard {
  final VoidCallback? onViewAllComments;

  const TraditionalPostCard({
    Key? key,
    required PostData post,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    this.onViewAllComments,
  }) : super(
          key: key,
          post: post,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
        );

  @override
  State<TraditionalPostCard> createState() => _TraditionalPostCardState();
}

class _TraditionalPostCardState extends BasePostCardState<TraditionalPostCard> {
  bool _isExpanded = false;
  
  // Sobrescrever o método do base para usar nossa implementação específica
  @override
  void _openCommentsModal() {
    widget.onComment?.call();
    
    showCommentsModal(
      context,
      postId: widget.post.id,
      comments: [],
      onCommentAdded: (newComment) {
        print('Novo comentário adicionado: $newComment');
      },
    );
  }

  // Sobrescrever buildPostContent para não renderizar o conteúdo padrão
  @override
  Widget buildPostContent() {
    return SizedBox.shrink(); // Não renderiza nada
  }

  @override
  Widget? buildAdditionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DESCRIÇÃO EXPANDÍVEL - Material 3 style
        if (widget.post.content.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      color: AppColors.carbon,
                      height: 1.5,
                      letterSpacing: 0.1,
                    ),
                    children: [
                      TextSpan(
                        text: widget.post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbon,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: _isExpanded || widget.post.content.length <= 120
                          ? widget.post.content
                          : '${widget.post.content.substring(0, 120)}...',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.carbon.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.post.content.length > 120)
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            _isExpanded ? 'ver menos' : 'ver mais',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grayScale1,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        
        // CONTADOR DE COMENTÁRIOS - Material 3 style
        if (widget.post.comments > 0)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openCommentsModal,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    widget.post.comments == 1 
                      ? 'Ver 1 comentário' 
                      : 'Ver todos os ${widget.post.comments} comentários',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grayScale1,
                      letterSpacing: 0.1,
                    ),
                  ),
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