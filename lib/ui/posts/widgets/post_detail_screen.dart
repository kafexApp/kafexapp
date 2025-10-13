// lib/ui/posts/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../data/models/domain/post.dart';
import '../../../services/feed_service.dart';
import '../../../data/repositories/feed_repository.dart';
import '../widgets/traditional_post_widget.dart';
import '../widgets/review_post_widget.dart';
import '../widgets/new_coffee_post_widget.dart';
import '../viewmodel/post_actions_viewmodel.dart';
import '../../../models/comment_models.dart';
import '../../../services/comments_service.dart';
import '../../../utils/app_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tela de detalhes de um post específico
/// Exibe o post completo + lista de comentários abaixo
class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String? highlightCommentId; // ID do comentário para destacar (opcional)

  const PostDetailScreen({
    Key? key,
    required this.postId,
    this.highlightCommentId,
  }) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  Post? _post;
  List<CommentData> _comments = [];
  bool _isLoadingPost = true;
  bool _isLoadingComments = true;
  bool _isPostingComment = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPostAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Carrega o post e os comentários
  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoadingPost = true;
      _isLoadingComments = true;
      _errorMessage = null;
    });

    try {
      // Buscar o post
      await _loadPost();

      // Buscar os comentários
      await _loadComments();
    } catch (e) {
      print('❌ Erro ao carregar post e comentários: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar o post';
      });
    }
  }

  /// Busca o post do banco de dados
  Future<void> _loadPost() async {
    try {
      print('🔍 Buscando post ID: ${widget.postId}');

      // Buscar post específico pelo ID
      final response = await FeedService.getFeed(limit: 100);
      
      // Encontrar o post pelo ID
      final foundPost = response.firstWhere(
        (feedRow) => feedRow.id?.toString() == widget.postId,
        orElse: () => throw Exception('Post não encontrado'),
      );

      // Converter para Post usando o FeedRepository
      final repository = FeedRepositoryImpl();
      final post = repository._convertToPost(foundPost);

      setState(() {
        _post = post;
        _isLoadingPost = false;
      });

      print('✅ Post carregado: ${post.id}');
    } catch (e) {
      print('❌ Erro ao carregar post: $e');
      setState(() {
        _isLoadingPost = false;
        _errorMessage = 'Post não encontrado';
      });
    }
  }

  /// Busca os comentários do post
  Future<void> _loadComments() async {
    try {
      final comments = await CommentsService.getCommentsByPostId(widget.postId);

      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });

      // Se houver um comentário para destacar, scroll até ele
      if (widget.highlightCommentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToHighlightedComment();
        });
      }

      print('✅ ${comments.length} comentários carregados');
    } catch (e) {
      print('❌ Erro ao carregar comentários: $e');
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  /// Scroll até o comentário destacado
  void _scrollToHighlightedComment() {
    // TODO: Implementar scroll automático até o comentário específico
    // Por enquanto, apenas scroll até o final
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  /// Adiciona novo comentário
  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPostingComment) return;

    // Verificar se usuário está logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isPostingComment = true;
    });

    try {
      final newComment = await CommentsService.addComment(
        postId: widget.postId,
        conteudo: text,
      );

      if (newComment != null) {
        setState(() {
          _comments.add(newComment);
          _commentController.clear();
        });

        // Scroll para o final para mostrar novo comentário
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentário adicionado!'),
            backgroundColor: AppColors.papayaSensorial,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar('Erro ao adicionar comentário');
      }
    } catch (e) {
      print('Erro ao postar comentário: $e');
      _showErrorSnackBar('Erro ao adicionar comentário');
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login necessário'),
          content: Text('Você precisa estar logado para comentar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.spiced,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteWhite,
      elevation: 0,
      leading: IconButton(
        icon: Icon(AppIcons.back, color: AppColors.carbon),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Post',
        style: GoogleFonts.albertSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.carbon,
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Estado de erro
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Loading do post
    if (_isLoadingPost) {
      return _buildLoadingState();
    }

    // Post não encontrado
    if (_post == null) {
      return _buildNotFoundState();
    }

    // Post + Comentários
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // POST
                _buildPost(),

                // DIVISOR
                Container(
                  height: 8,
                  color: AppColors.moonAsh,
                ),

                // SEÇÃO DE COMENTÁRIOS
                _buildCommentsSection(),
              ],
            ),
          ),
        ),

        // INPUT DE COMENTÁRIO FIXO NA PARTE INFERIOR
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppColors.papayaSensorial),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.warning, size: 60, color: AppColors.spiced),
            SizedBox(height: 24),
            Text(
              _errorMessage ?? 'Erro ao carregar post',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPostAndComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.papayaSensorial,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tentar novamente',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.warning, size: 60, color: AppColors.grayScale2),
          SizedBox(height: 24),
          Text(
            'Post não encontrado',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost() {
    if (_post == null) return SizedBox.shrink();

    // Cria ViewModel para o post
    return ChangeNotifierProvider(
      create: (_) => PostActionsViewModel(
        postId: _post!.id,
        initialPost: _post!,
      ),
      child: _buildPostWidget(_post!),
    );
  }

  Widget _buildPostWidget(Post post) {
    // Renderiza o widget correto baseado no tipo do post
    switch (post.type) {
      case DomainPostType.traditional:
        return TraditionalPostWidget(
          post: post,
          onComment: () {
            // Foca no input de comentário
            _commentFocus.requestFocus();
          },
        );

      case DomainPostType.coffeeReview:
        return ReviewPostWidget(
          post: post,
          onComment: () {
            _commentFocus.requestFocus();
          },
        );

      case DomainPostType.newCoffee:
        return NewCoffeePostWidget(
          post: post,
          onComment: () {
            _commentFocus.requestFocus();
          },
        );

      default:
        return TraditionalPostWidget(
          post: post,
          onComment: () {
            _commentFocus.requestFocus();
          },
        );
    }
  }

  Widget _buildCommentsSection() {
    return Container(
      color: AppColors.whiteWhite,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de comentários
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Comentários (${_comments.length})',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ),

          SizedBox(height: 16),

          // Lista de comentários
          if (_isLoadingComments)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: AppColors.papayaSensorial,
                ),
              ),
            )
          else if (_comments.isEmpty)
            _buildEmptyComments()
          else
            ..._comments.map((comment) => _buildCommentItem(comment)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.comment, size: 40, color: AppColors.grayScale2),
            SizedBox(height: 12),
            Text(
              'Nenhum comentário ainda',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    // Destacar comentário se for o que veio da notificação
    final isHighlighted = widget.highlightCommentId == comment.id;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.papayaSensorial.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: AppColors.papayaSensorial.withOpacity(0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildUserAvatar(comment.userName, comment.userAvatar),
          SizedBox(width: 12),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.carbon,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String userName, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          avatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildAvatarFallback(userName);
          },
        ),
      );
    }

    return _buildAvatarFallback(userName);
  }

  Widget _buildAvatarFallback(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
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

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        border: Border(top: BorderSide(color: AppColors.moonAsh, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.oatWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _commentFocus.hasFocus
                        ? AppColors.papayaSensorial.withOpacity(0.3)
                        : AppColors.moonAsh,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.carbon,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentário...',
                    hintStyle: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.grayScale2,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            SizedBox(width: 12),

            // Botão Enviar
            GestureDetector(
              onTap: _commentController.text.trim().isNotEmpty && !_isPostingComment
                  ? _postComment
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _commentController.text.trim().isNotEmpty && !_isPostingComment
                      ? AppColors.papayaSensorial
                      : AppColors.grayScale2.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: _isPostingComment
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteWhite,
                        ),
                      )
                    : Icon(
                        AppIcons.paperPlaneTilt,
                        color: AppColors.whiteWhite,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
}