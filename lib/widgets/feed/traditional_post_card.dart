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

  bool get _isAuthor {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    
    return currentUser.displayName == widget.post.authorName ||
           currentUser.email?.split('@')[0] == widget.post.authorName.toLowerCase().replaceAll(' ', '');
  }

  @override
  void navigateToUserProfile(String userName, String? userAvatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: widget.post.id,
          userName: widget.post.authorName,
          userAvatar: widget.post.authorAvatar,
        ),
      ),
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
        // DESCRIÇÃO EXPANDÍVEL
        if (widget.post.content.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
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
                        text: _isExpanded || widget.post.content.length <= 120
                          ? widget.post.content
                          : '${widget.post.content.substring(0, 120)}...',
                      ),
                    ],
                  ),
                ),
                if (widget.post.content.length > 120)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        _isExpanded ? 'menos' : 'mais',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.grayScale1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        
        // CONTADOR DE COMENTÁRIOS
        if (widget.post.comments > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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