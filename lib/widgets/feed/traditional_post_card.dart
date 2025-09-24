import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../comments_bottom_sheet.dart';
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
  
  void _openCommentsModal() {
    widget.onComment?.call();
    
    showCommentsModal(
      context,
      postId: widget.post.id,
      comments: [], // Você pode passar os comentários convertidos aqui
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
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                isLiked ? AppIcons.heartFill : AppIcons.heart,  // MUDANÇA: isLiked sem underscore
                color: isLiked ? AppColors.spiced : AppColors.grayScale2,  // MUDANÇA: isLiked sem underscore
                size: 24,
              ),
            ),
          ),
          
          // Botão Comentário
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
          
          // Botão Salvar
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
    );
  }

  @override
  Widget? buildAdditionalContent() {
    if (widget.post.comments == 0 && widget.post.recentComments.isEmpty) {
      return SizedBox(height: 16);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.post.comments > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
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
        
        if (widget.post.recentComments.isNotEmpty)
          _buildLastComment(),
        
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLastComment() {
    final lastComment = widget.post.recentComments.first;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: _openCommentsModal,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.oatWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => navigateToUserProfile(
                  lastComment.authorName,
                  lastComment.authorAvatar?.startsWith('http') == true 
                    ? lastComment.authorAvatar 
                    : null,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: lastComment.authorAvatar?.startsWith('http') == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            lastComment.authorAvatar!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCommentAvatarFallback(lastComment.authorName);
                            },
                          ),
                        )
                      : _buildCommentAvatarFallback(lastComment.authorName),
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => navigateToUserProfile(
                            lastComment.authorName,
                            lastComment.authorAvatar?.startsWith('http') == true 
                              ? lastComment.authorAvatar 
                              : null,
                          ),
                          child: Text(
                            lastComment.authorName,
                            style: GoogleFonts.albertSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.papayaSensorial,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          lastComment.date ?? '',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: AppColors.grayScale2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      lastComment.content,
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentAvatarFallback(String authorName) {
    final initial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U';
    final colorIndex = authorName.isNotEmpty ? authorName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColors[colorIndex].withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: avatarColors[colorIndex],
          ),
        ),
      ),
    );
  }
}