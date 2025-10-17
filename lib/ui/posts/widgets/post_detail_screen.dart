// lib/ui/posts/widgets/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../data/models/domain/post.dart';
import '../../../services/feed_service.dart';
import '../widgets/traditional_post_widget.dart';
import '../widgets/review_post_widget.dart';
import '../widgets/new_coffee_post_widget.dart';
import '../viewmodel/post_actions_viewmodel.dart';
import '../../comments/widgets/comments_bottom_sheet.dart';

/// Tela de detalhes de um post específico
/// Exibe o post completo e pode abrir o modal de comentários automaticamente
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
  Post? _post;
  bool _isLoadingPost = true;
  String? _errorMessage;
  bool _hasOpenedModal = false; // 🔧 NOVO: Controle para abrir modal apenas uma vez

  @override
  void initState() {
    super.initState();
    _loadPostAndComments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Carrega o post e abre modal de comentários se necessário
  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoadingPost = true;
      _errorMessage = null;
    });

    try {
      // Buscar o post
      await _loadPost();

      // 🔧 CORRIGIDO: Abrir modal apenas se ainda não foi aberto
      if (widget.highlightCommentId != null && _post != null && !_hasOpenedModal) {
        _hasOpenedModal = true; // Marcar como aberto
        
        // Delay para garantir que a tela está totalmente construída
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            _openCommentsModalWithHighlight();
          }
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar post: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar o post';
      });
    }
  }

  /// Abre o modal de comentários destacando o comentário específico
  void _openCommentsModalWithHighlight() {
    if (_post == null) return;

    print('💬 Abrindo modal de comentários');
    print('   Destacar comentário ID: ${widget.highlightCommentId}');

    showCommentsModal(
      context,
      postId: _post!.id,
      highlightCommentId: widget.highlightCommentId,
      onCommentAdded: (newComment) {
        print('Novo comentário adicionado: $newComment');
        // Recarregar o post para atualizar contador de comentários
        _loadPost();
      },
    );
  }

  /// Busca o post do banco de dados
  Future<void> _loadPost() async {
    try {
      print('🔍 Buscando post ID: ${widget.postId}');

      // Buscar post específico pelo ID usando FeedService
      final response = await FeedService.getFeed(limit: 100);
      
      // Encontrar o post pelo ID
      final foundPost = response.firstWhere(
        (feedRow) => feedRow.id?.toString() == widget.postId,
        orElse: () => throw Exception('Post não encontrado'),
      );

      // Converter para Post manualmente (mesmo método do FeedRepository)
      final post = _convertFeedRowToPost(foundPost);

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

  /// Converte FeedRow para Post (copiado do FeedRepository)
  Post _convertFeedRowToPost(dynamic raw) {
    DomainPostType postType = DomainPostType.traditional;

    if (raw.pontuacao != null && raw.nomeCafeteria != null) {
      postType = DomainPostType.coffeeReview;
    } else if (raw.nomeCafeteria != null && raw.endereco != null) {
      postType = DomainPostType.newCoffee;
    }

    String authorName = 'Usuário';
    if (raw.nomeExibicao != null && raw.nomeExibicao!.isNotEmpty) {
      authorName = raw.nomeExibicao!;
    } else if (raw.nome_usuario != null && raw.nome_usuario!.isNotEmpty) {
      authorName = raw.nome_usuario!;
    } else if (raw.usuario != null && raw.usuario!.isNotEmpty) {
      authorName = raw.usuario!;
    }

    String authorAvatar = '';
    if (raw.fotoUrl != null && raw.fotoUrl!.isNotEmpty) {
      authorAvatar = raw.fotoUrl!;
    } else if (raw.urlFoto != null && raw.urlFoto!.isNotEmpty) {
      authorAvatar = raw.urlFoto!;
    }

    String? authorUid = raw.usuarioUid;

    String? coffeeId;
    if (raw.cafeteriaId != null) {
      coffeeId = raw.cafeteriaId.toString();
    }

    return Post(
      id: raw.id?.toString() ?? '0',
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: raw.criadoEm ?? DateTime.now(),
      content: raw.descricao ?? '',
      authorUid: authorUid,
      imageUrl: raw.urlFoto,
      videoUrl: raw.urlVideo,
      likes: 0,
      comments: int.tryParse(raw.comentarios ?? '0') ?? 0,
      isLiked: false,
      type: postType,
      coffeeName: raw.nomeCafeteria,
      rating: raw.pontuacao,
      coffeeId: coffeeId,
      coffeeAddress: raw.endereco,
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

    // Apenas o POST (comentários abrem no modal)
    return SingleChildScrollView(
      child: _buildPost(),
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
    // NÃO passar onComment pois o widget já abre o modal internamente
    switch (post.type) {
      case DomainPostType.traditional:
        return TraditionalPostWidget(
          post: post,
        );

      case DomainPostType.coffeeReview:
        return ReviewPostWidget(
          post: post,
        );

      case DomainPostType.newCoffee:
        return NewCoffeePostWidget(
          post: post,
        );

      default:
        return TraditionalPostWidget(
          post: post,
        );
    }
  }
}