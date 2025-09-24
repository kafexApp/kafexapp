import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER DO POST
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => navigateToUserProfile(
                    widget.post.authorName,
                    widget.post.authorAvatar,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.papayaSensorial.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.moonAsh,
                      backgroundImage: _getAvatarImage(),
                      child: _getAvatarImage() == null
                        ? Text(
                            widget.post.authorName.isNotEmpty 
                              ? widget.post.authorName[0].toUpperCase()
                              : 'U',
                            style: GoogleFonts.albertSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.papayaSensorial,
                            ),
                          )
                        : null,
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Nome e data
                Expanded(
                  child: GestureDetector(
                    onTap: () => navigateToUserProfile(
                      widget.post.authorName,
                      widget.post.authorAvatar,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.authorName,
                          style: GoogleFonts.albertSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.carbon,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.post.date,
                          style: GoogleFonts.albertSans(
                            fontSize: 13,
                            color: AppColors.grayScale1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Menu de opções (APENAS para o autor do post)
                if (_isAuthor)
                  GestureDetector(
                    onTap: showPostOptionsModal,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        AppIcons.dotsThree,
                        size: 24,
                        color: AppColors.grayScale2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // MÍDIA DO POST - SÓ APARECE SE TIVER IMAGEM VÁLIDA
          _buildMediaSection(),
          
          // AÇÕES DO POST
          buildCustomActions(),
          
          // CONTADOR DE LIKES
          buildLikesCounter(),
          
          // CONTEÚDO ADICIONAL
          if (buildAdditionalContent() != null) buildAdditionalContent()!,
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    final avatar = widget.post.authorAvatar;
    if (avatar != null && avatar.isNotEmpty && avatar.startsWith('http')) {
      return CachedNetworkImageProvider(avatar);
    }
    return null;
  }

  // MÉTODO CORRIGIDO - SÓ MOSTRA SEÇÃO SE TIVER IMAGEM VÁLIDA
  Widget _buildMediaSection() {
    final hasValidImage = widget.post.imageUrl != null && 
                         widget.post.imageUrl!.isNotEmpty && 
                         widget.post.imageUrl!.startsWith('http');
    
    if (!hasValidImage) {
      // Se não tem imagem válida, retorna espaço vazio
      return SizedBox.shrink();
    }

    return GestureDetector(
      onDoubleTap: () {
        if (!isLiked) {
          toggleLike();
        }
      },
      child: Container(
        width: double.infinity,
        height: 300,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.moonAsh,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: widget.post.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                color: AppColors.moonAsh,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.papayaSensorial,
                    ),
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) {
              // Se der erro ao carregar, não mostra nada
              return SizedBox.shrink();
            },
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}