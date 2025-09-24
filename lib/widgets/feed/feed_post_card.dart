import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../backend/supabase/tables/feed_com_usuario.dart';
import '../../models/comment_models.dart';
import '../../screens/user_profile_screen.dart';
import '../comments_bottom_sheet.dart';

class FeedPostCard extends StatefulWidget {
  final FeedComUsuarioRow post;
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
    _isLiked = false;
    _likesCount = 0;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLike?.call();
  }

  void _navigateToUserProfile(String userName, String? avatarUrl) {
    print('🔍 Navegando para perfil de: $userName');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userId: 'user_${userName.toLowerCase().replaceAll(' ', '_')}',
          userName: userName,
          userAvatar: avatarUrl,
        ),
      ),
    );
  }

  void _openCommentsModal() {
    print('💬 Abrir comentários para post: ${widget.post.id}');
    widget.onComment?.call();

    // Criar uma lista vazia de comentários já que recentComments não existe
    List<CommentData> commentsForModal = [];

    // Abre o modal de comentários
    showCommentsModal(
      context,
      postId: widget.post.id?.toString() ?? '', // Converte int? para String
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
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.moonAsh,
                indent: 16,
                endIndent: 16,
              ),
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
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
          _buildPostHeader(),
          if (_getImageUrl().isNotEmpty || widget.post.urlVideo != null)
            _buildPostMedia(),
          _buildPostActions(),
          if (_likesCount > 0) _buildLikesCounter(),
          _buildPostContent(),
          if ((int.tryParse(widget.post.comentarios ?? '0') ?? 0) > 0)
            _buildCommentsPreview(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    final authorName = _getAuthorName();
    final authorAvatar = _getImageUrl();
    final formattedDate = _formatDate(widget.post.criadoEm);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(authorName, null),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Center(child: _buildAvatarFallback(authorName)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(authorName, null),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: GoogleFonts.albertSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildAvatarFallback(String authorName) {
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
    final imageUrl = _getImageUrl();
    final videoUrl = widget.post.urlVideo;

    return GestureDetector(
      onDoubleTap: () {
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
          child: videoUrl != null && videoUrl.isNotEmpty
              ? _buildVideoPlayer()
              : imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
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
                )
              : Container(
                  color: AppColors.moonAsh,
                  child: Center(
                    child: Icon(
                      AppIcons.image,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                  ),
                ),
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
            Icon(AppIcons.play, color: AppColors.whiteWhite, size: 48),
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

  Widget _buildPostActions() {
    final commentsCount = int.tryParse(widget.post.comentarios ?? '0') ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
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
          GestureDetector(
            onTap: _openCommentsModal,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(AppIcons.comment, color: AppColors.grayScale2, size: 24),
                  if (commentsCount > 0) ...[
                    SizedBox(width: 4),
                    Text(
                      '$commentsCount',
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
    final authorName = _getAuthorName();
    final content = widget.post.descricao ?? '';
    final tipoCalculado = widget.post.tipoCalculado ?? '';

    // Layout específico baseado no tipo_calculado
    switch (tipoCalculado) {
      case 'nova cafeteria':
        return _buildNewCafeContent(authorName, content);
      case 'avaliacao':
        return _buildReviewContent(authorName, content);
      case 'post imagem':
      default:
        return _buildRegularContent(authorName, content);
    }
  }

  String _getAuthorName() {
    // Prioriza nome_exibicao, depois usuario
    return widget.post.nomeExibicao ?? widget.post.usuario ?? 'Usuário';
  }

  String _getImageUrl() {
    // Prioriza url_foto, depois imagem_url
    return widget.post.urlFoto ?? widget.post.imagemUrl ?? '';
  }

  Widget _buildNewCafeContent(String authorName, String content) {
    final cafeName = widget.post.nomeCafeteria ?? widget.post.nome ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$authorName ',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (cafeName.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.papayaSensorial.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '📍 $cafeName',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewContent(String authorName, String content) {
    final cafeName = widget.post.nomeCafeteria ?? widget.post.nome ?? '';
    final rating = widget.post.pontuacao ?? 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$authorName ',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (cafeName.isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.velvetMerlot.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.velvetMerlot.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '☕ $cafeName',
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.velvetMerlot,
                    ),
                  ),
                ),
                if (rating > 0) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.spiced.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.heart, size: 12, color: AppColors.spiced),
                        SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.spiced,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegularContent(String authorName, String content) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$authorName ',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: content,
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
    final commentsCount = int.tryParse(widget.post.comentarios ?? '0') ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GestureDetector(
        onTap: _openCommentsModal,
        child: Text(
          'Ver todos os $commentsCount comentários',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: AppColors.grayScale2,
          ),
        ),
      ),
    );
  }

  // REMOVIDA: _buildLastComment() que usava recentComments
  // Esta função foi removida pois recentComments não existe no FeedComUsuarioRow

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
