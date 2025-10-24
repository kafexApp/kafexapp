// lib/ui/posts/widgets/feed_post_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';
import 'package:kafex/models/comment_models.dart';
import 'package:kafex/config/app_routes.dart';
import 'package:kafex/services/comments_service.dart';
import 'package:kafex/ui/comments/widgets/comments_bottom_sheet.dart';
import 'package:kafex/data/repositories/likes_repository.dart';

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
  int _commentsCount = 0;
  final LikesRepository _likesRepository = LikesRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _commentsCount = int.tryParse(widget.post.comentarios ?? '0') ?? 0;

    // Carrega o estado inicial das curtidas do banco de dados
    _loadLikesState();
  }

  /// Carrega o estado das curtidas do banco de dados
  Future<void> _loadLikesState() async {
    try {
      final feedId = widget.post.id;
      if (feedId == null) return;

      // Verifica se o usuário curtiu este post
      final isLikedResult = await _likesRepository.checkIfUserLikedFeedPost(
        feedId,
      );

      if (isLikedResult.isOk && mounted) {
        final isLiked = isLikedResult.asOk.value;

        // Busca o contador real de curtidas
        final likesCountResult = await _likesRepository.getFeedPostLikesCount(
          feedId,
        );

        if (likesCountResult.isOk && mounted) {
          setState(() {
            _isLiked = isLiked;
            _likesCount = likesCountResult.asOk.value;
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar curtidas: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final feedId = widget.post.id;
      if (feedId == null) {
        print('❌ ID do post inválido');
        return;
      }

      // Armazena os valores anteriores para rollback em caso de erro
      final previousIsLiked = _isLiked;
      final previousLikesCount = _likesCount;

      // Atualização otimista da UI (instant feedback)
      setState(() {
        _isLiked = !_isLiked;
        _likesCount += _isLiked ? 1 : -1;
      });

      // Chama callback opcional
      widget.onLike?.call();

      // Faz a chamada real para o banco de dados
      final result = await _likesRepository.toggleLikeFeedPost(feedId);

      if (result.isError) {
        // Se deu erro, reverte para o estado anterior
        if (mounted) {
          setState(() {
            _isLiked = previousIsLiked;
            _likesCount = previousLikesCount;
          });
        }
        print('❌ Erro ao curtir: ${result.asError.error}');

        // Opcional: mostrar snackbar de erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao curtir post. Tente novamente.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Atualiza com os valores reais do banco
      final isNowLiked = result.asOk.value;
      final likesCountResult = await _likesRepository.getFeedPostLikesCount(
        feedId,
      );

      if (likesCountResult.isOk && mounted) {
        setState(() {
          _isLiked = isNowLiked;
          _likesCount = likesCountResult.asOk.value;
        });
      }

      print('✅ Curtida ${isNowLiked ? "adicionada" : "removida"} com sucesso');
    } catch (e) {
      print('❌ Exceção ao curtir: $e');
      // Recarrega o estado correto do banco
      _loadLikesState();
    }
  }

  /// ✅ CORRIGIDO: Agora passa o Firebase UID real do usuário
  void _navigateToUserProfile(String userName, String? avatarUrl) {
    // 🔍 DEBUG: Ver o que está vindo do post
    print('🔍 DEBUG - Dados do post:');
    print('   Nome: $userName');
    print('   Avatar: $avatarUrl');
    print('   usuario_uid: ${widget.post.usuarioUid}');

    // Busca o Firebase UID do autor do post
    final String? authorUid = widget.post.usuarioUid;

    if (authorUid == null || authorUid.isEmpty) {
      print('❌ Firebase UID do autor não encontrado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível carregar o perfil do usuário'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('🔍 Navegando para perfil do usuário:');
    print('   Nome: $userName');
    print('   Firebase UID: $authorUid');

    Navigator.pushNamed(
      context,
      AppRoutes.userProfile,
      arguments: {
        'userId': authorUid,
        'userName': userName,
        'userAvatar': avatarUrl,
      },
    );
  }

  void _openCommentsModal() async {
    print('💬 Abrir comentários para post: ${widget.post.id}');
    widget.onComment?.call();

    // Abre o modal de comentários carregando dados reais do Supabase
    showCommentsModal(
      context,
      postId: widget.post.id?.toString() ?? '',
      onCommentAdded: (newComment) {
        // Atualiza contador local quando novo comentário é adicionado
        setState(() {
          _commentsCount += 1;
        });
        print('Novo comentário adicionado: $newComment');
      },
    );
  }

  Widget _buildPostHeader() {
    final authorName = _getAuthorName();
    final userAvatarUrl = _getUserAvatarUrl();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(authorName, userAvatarUrl),
            child: _buildUserAvatar(authorName, userAvatarUrl),
          ),

          SizedBox(width: 12),

          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(authorName, userAvatarUrl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _formatRelativeTime(widget.post.criadoEm),
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: AppColors.grayScale2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botão de opções
          GestureDetector(
            onTap: () {
              print('Mostrar opções do post');
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                AppIcons.dotsThreeVertical,
                color: AppColors.grayScale2,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String authorName, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildAvatarFallback(authorName),
          errorWidget: (context, url, error) =>
              _buildAvatarFallback(authorName),
        ),
      );
    }

    return _buildAvatarFallback(authorName);
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
    final postImageUrl = _getPostImageUrl();
    final videoUrl = widget.post.urlVideo;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      return _buildVideoPlayer(videoUrl);
    } else if (postImageUrl.isNotEmpty) {
      return _buildImage(postImageUrl);
    }

    return SizedBox.shrink();
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.moonAsh,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.papayaSensorial),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: AppColors.moonAsh,
          child: Center(
            child: Icon(AppIcons.image, color: AppColors.grayScale2, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return Container(
      width: double.infinity,
      height: 250,
      color: AppColors.carbon,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(AppIcons.play, color: AppColors.whiteWhite, size: 48),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VÍDEO',
                style: GoogleFonts.albertSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostActions() {
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
                  if (_commentsCount > 0) ...[
                    SizedBox(width: 4),
                    Text(
                      '$_commentsCount',
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

  Widget _buildNewCafeContent(String authorName, String content) {
    final cafeName =
        widget.post.nomeCafeteria ?? widget.post.nome ?? 'Nova Cafeteria';
    final endereco = widget.post.endereco ?? '';

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
                  text: 'adicionou uma nova cafeteria',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.oatWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.moonAsh, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cafeName,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (endereco.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        AppIcons.location,
                        size: 14,
                        color: AppColors.grayScale2,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          endereco,
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: AppColors.grayScale2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (content.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
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
                  text: 'avaliou ',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (cafeName.isNotEmpty)
                  TextSpan(
                    text: cafeName,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),

          if (rating > 0) ...[
            SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating.floor() ? AppIcons.starFill : AppIcons.star,
                    color: AppColors.papayaSensorial,
                    size: 16,
                  );
                }),
                SizedBox(width: 8),
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
          ],

          if (content.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsPreview() {
    if (_commentsCount == 0) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GestureDetector(
        onTap: _openCommentsModal,
        child: Text(
          'Ver todos os $_commentsCount comentário${_commentsCount != 1 ? 's' : ''}',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: AppColors.grayScale2,
          ),
        ),
      ),
    );
  }

  String _getAuthorName() {
    return widget.post.nomeExibicao ?? widget.post.usuario ?? 'Usuário';
  }

  String? _getUserAvatarUrl() {
    return widget.post.getField<String>('foto_url');
  }

  String _getPostImageUrl() {
    return widget.post.urlFoto ?? widget.post.imagemUrl ?? '';
  }

  String _formatRelativeTime(DateTime? dateTime) {
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
          if (_getPostImageUrl().isNotEmpty || widget.post.urlVideo != null)
            _buildPostMedia(),
          _buildPostActions(),
          if (_likesCount > 0) _buildLikesCounter(),
          _buildPostContent(),
          _buildCommentsPreview(),
        ],
      ),
    );
  }
}