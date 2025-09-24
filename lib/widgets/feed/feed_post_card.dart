import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../../models/comment_models.dart';
import '../../screens/user_profile_screen.dart';
import '../comments_bottom_sheet.dart';

class FeedPostCard extends StatefulWidget {
  final PostData post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewAllComments;

  const FeedPostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onDelete,
    this.onViewAllComments,
  }) : super(key: key);

  @override
  _FeedPostCardState createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLike?.call();
  }

  // Navega para o perfil do usuário
  void _navigateToUserProfile(String userName, String? avatarUrl) {
    print('🔍 Navegando para perfil de: $userName');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: 'user_${userName.toLowerCase().replaceAll(' ', '_')}', // ID mock baseado no nome
          userName: userName,
          userAvatar: avatarUrl,
        ),
      ),
    );
  }

  void _openCommentsModal() {
    print('💬 Abrir comentários para post: ${widget.post.id}');
    widget.onComment?.call();
    
    // Converter os comentários do post para o formato do modal
    List<CommentData> commentsForModal = widget.post.recentComments.map((comment) {
      return CommentData(
        id: comment.id,
        userName: comment.authorName,
        userAvatar: comment.authorAvatar?.startsWith('http') == true 
            ? comment.authorAvatar 
            : null,
        content: comment.content,
        timestamp: DateTime.now().subtract(Duration(hours: 2)), // Mock timestamp
        likes: 0, // Mock likes
        isLiked: false,
      );
    }).toList();

    // Abre o modal de comentários
    showCommentsModal(
      context,
      postId: widget.post.id,
      comments: commentsForModal,
      onCommentAdded: (newComment) {
        print('📝 Novo comentário adicionado: $newComment');
        // Aqui você pode atualizar o estado do post se necessário
      },
    );
  }

  void _showPostOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual do modal
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayScale2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Botão Editar
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
                leading: Icon(
                  AppIcons.edit,
                  color: AppColors.papayaSensorial,
                  size: 24,
                ),
                title: Text(
                  'Editar',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              // Divisor
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.moonAsh,
                indent: 16,
                endIndent: 16,
              ),
              
              // Botão Excluir
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
                leading: Icon(
                  AppIcons.delete,
                  color: AppColors.spiced,
                  size: 24,
                ),
                title: Text(
                  'Excluir',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.spiced,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
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
          // Header do post (Avatar + Nome + Data + Menu)
          _buildPostHeader(),
          
          // Mídia do post (Imagem/Vídeo)
          if (widget.post.imageUrl != null || widget.post.videoUrl != null)
            _buildPostMedia(),
          
          // Ações do post (Like + Comentário)
          _buildPostActions(),
          
          // Contador de likes
          if (_likesCount > 0) _buildLikesCounter(),
          
          // Conteúdo do post (Descrição)
          _buildPostContent(),
          
          // Preview de comentários
          if (widget.post.comments > 0) _buildCommentsPreview(),
          
          // Último comentário
          if (widget.post.recentComments.isNotEmpty) _buildLastComment(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // Avatar do usuário - CLICÁVEL
          GestureDetector(
            onTap: () => _navigateToUserProfile(
              widget.post.authorName,
              widget.post.authorAvatar.startsWith('http') 
                ? widget.post.authorAvatar 
                : null,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.post.authorAvatar.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.post.authorAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback();
                        },
                      ),
                    )
                  : _buildAvatarFallback(),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Nome e data - NOME TAMBÉM CLICÁVEL
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(
                widget.post.authorName,
                widget.post.authorAvatar.startsWith('http') 
                  ? widget.post.authorAvatar 
                  : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.authorName,
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    widget.post.date,
                    style: GoogleFonts.albertSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão de menu (3 pontos)
          GestureDetector(
            onTap: _showPostOptionsModal,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                AppIcons.dotsThree,
                color: AppColors.grayScale2,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final initial = widget.post.authorName.isNotEmpty 
        ? widget.post.authorName[0].toUpperCase() 
        : 'U';
    final colorIndex = widget.post.authorName.isNotEmpty 
        ? widget.post.authorName.codeUnitAt(0) % 5 
        : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPostMedia() {
    return GestureDetector(
      onDoubleTap: () {
        // Double tap para dar like
        if (!_isLiked) {
          _toggleLike();
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
          child: widget.post.videoUrl != null
              ? _buildVideoPlayer()
              : _buildImageMedia(),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: AppColors.carbon,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.play,
              color: AppColors.whiteWhite,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Vídeo',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.whiteWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMedia() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.moonAsh,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.papayaSensorial,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.moonAsh,
        child: Center(
          child: Icon(
            AppIcons.image,
            color: AppColors.textSecondary,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Botão Like
          GestureDetector(
            onTap: _toggleLike,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                _isLiked ? AppIcons.heartFill : AppIcons.heart,
                color: _isLiked ? AppColors.spiced : AppColors.grayScale2,
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
          
          // Botão Favorito
          GestureDetector(
            onTap: () {
              print('Toggle favorito');
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

  Widget _buildLikesCounter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        '$_likesCount curtida${_likesCount != 1 ? 's' : ''}',
        style: GoogleFonts.albertSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.post.authorName} ',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: widget.post.content,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPreview() {
    return Padding(
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
    );
  }

  Widget _buildLastComment() {
    final lastComment = widget.post.recentComments.first;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              // Avatar do comentário
              GestureDetector(
                onTap: () => _navigateToUserProfile(
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
              
              // Conteúdo do comentário
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e data
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToUserProfile(
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
                          lastComment.date ?? '', // CORREÇÃO AQUI
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: AppColors.grayScale2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    // Texto do comentário
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
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }
}