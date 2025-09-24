import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/side_menu_overlay.dart';
import '../widgets/feed/post_card_factory.dart';
import '../models/post_models.dart';
import '../widgets/common/user_avatar.dart';
import 'package:kafex/services/feed_service.dart';

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  List<PostData> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeedFromDatabase();
  }

  Future<void> _loadFeedFromDatabase() async {
    setState(() {
      _loading = true;
    });

    try {
      // Buscar dados do Supabase
      final rawPosts = await FeedService.getFeed();
      
      // Converter para PostData
      final List<PostData> convertedPosts = [];
      
      for (var post in rawPosts) {
        // Determinar tipo do post baseado nos campos
        PostType postType = PostType.traditional;
        
        // Verificar tipo baseado nos campos disponíveis
        if (post.pontuacao != null && post.nomeCafeteria != null) {
          postType = PostType.coffeeReview;
        } else if (post.nomeCafeteria != null && post.endereco != null) {
          postType = PostType.newCoffee;
        }
        
        // Criar PostData baseado no tipo
        PostData newPost;
        
        switch (postType) {
          case PostType.coffeeReview:
            newPost = PostData.review(
              id: post.id?.toString() ?? '0',
              authorName: post.nomeExibicao ?? post.usuario ?? 'Usuário',
              authorAvatar: post.fotoUrl ?? post.urlFoto ?? '',
              date: _formatDate(post.criadoEm),
              content: post.descricao ?? '',
              coffeeName: post.nomeCafeteria ?? '',
              rating: post.pontuacao ?? 0.0,
              coffeeId: 'coffee_${post.id}',
              imageUrl: post.imagemUrl,
              videoUrl: post.urlVideo,
              likes: _parseIntFromString(post.comentarios) ?? 0,
              comments: 0,
              isLiked: false,
              isFavorited: false,
              wantToVisit: false,
              recentComments: [],
            );
            break;
            
          case PostType.newCoffee:
            newPost = PostData.newCoffee(
              id: post.id?.toString() ?? '0',
              authorName: post.nomeExibicao ?? post.usuario ?? 'Usuário',
              authorAvatar: post.fotoUrl ?? post.urlFoto ?? '',
              date: _formatDate(post.criadoEm),
              coffeeName: post.nomeCafeteria ?? 'Nova Cafeteria',
              coffeeAddress: post.endereco ?? 'Endereço não informado',
              coffeeId: 'coffee_${post.id}',
              imageUrl: post.imagemUrl,
              likes: _parseIntFromString(post.comentarios) ?? 0,
              comments: 0,
              isLiked: false,
              recentComments: [],
            );
            break;
            
          default:
            newPost = PostData.traditional(
              id: post.id?.toString() ?? '0',
              authorName: post.nomeExibicao ?? post.usuario ?? 'Usuário',
              authorAvatar: post.fotoUrl ?? post.urlFoto ?? '',
              date: _formatDate(post.criadoEm),
              content: post.descricao ?? '',
              imageUrl: post.imagemUrl,
              videoUrl: post.urlVideo,
              likes: _parseIntFromString(post.comentarios) ?? 0,
              comments: 0,
              isLiked: false,
              recentComments: [],
            );
        }
        
        convertedPosts.add(newPost);
      }
      
      // Se não houver posts, adicionar alguns de exemplo
      if (convertedPosts.isEmpty) {
        convertedPosts.addAll(_getExamplePosts());
      }
      
      setState(() {
        _posts = convertedPosts;
        _loading = false;
      });
      
    } catch (e) {
      print('Erro ao carregar feed: $e');
      
      // Em caso de erro, usar posts de exemplo
      setState(() {
        _posts = _getExamplePosts();
        _loading = false;
      });
    }
  }

  // Posts de exemplo para quando não há dados
  List<PostData> _getExamplePosts() {
    return [
      PostData.traditional(
        id: 'example_1',
        authorName: 'Equipe Kafex',
        authorAvatar: '',
        date: 'agora',
        content: 'Bem-vindo ao Kafex! Explore cafeterias incríveis e compartilhe suas experiências ☕',
        imageUrl: null,
        videoUrl: null,
        likes: 1,
        comments: 0,
        isLiked: false,
        recentComments: [],
      ),
      PostData.newCoffee(
        id: 'example_2',
        authorName: 'Sistema',
        authorAvatar: '',
        date: 'há 1 hora',
        coffeeName: 'Café Exemplo',
        coffeeAddress: 'Rua das Flores, 123 - Centro',
        coffeeId: 'coffee_example',
        imageUrl: null,
        likes: 0,
        comments: 0,
        isLiked: false,
        recentComments: [],
      ),
    ];
  }

  int? _parseIntFromString(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'agora';
    
    final Duration difference = DateTime.now().difference(date);
    
    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return 'há $weeks semana${weeks > 1 ? 's' : ''}';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  void _handleLike(String postId) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
    });
    // TODO: Salvar like no Supabase
  }

  void _handleComment(String postId) {
    print('Comentário no post: $postId');
    // TODO: Abrir modal de comentários
  }

  void _handleEdit(String postId) {
    print('Editar post: $postId');
    // TODO: Implementar edição
  }

  void _handleDelete(String postId) {
    print('Excluir post: $postId');
    // TODO: Implementar exclusão
  }

  void _handleViewAllComments(String postId) {
    print('Ver todos os comentários do post: $postId');
  }

  void _handleFavorite(String coffeeId) {
    print('Favoritar cafeteria: $coffeeId');
    // TODO: Salvar favorito no Supabase
  }

  void _handleWantToVisit(String coffeeId) {
    print('Quero visitar cafeteria: $coffeeId');
    // TODO: Salvar na lista de quero visitar
  }

  void _handleEvaluateNow(String coffeeId, String coffeeName) {
    print('Avaliar cafeteria: $coffeeName ($coffeeId)');
    // TODO: Abrir modal de avaliação
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadFeedFromDatabase,
            color: AppColors.papayaSensorial,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _buildWelcomeSection(),

                if (_loading)
                  Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.papayaSensorial,
                        ),
                      ),
                    ),
                  )
                else if (_posts.isEmpty)
                  Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.coffee,
                          size: 64,
                          color: AppColors.grayScale2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum post ainda',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Seja o primeiro a compartilhar!',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._posts.map((post) {
                    return PostCardFactory.create(
                      post: post,
                      type: post.type,
                      onLike: () => _handleLike(post.id),
                      onComment: () => _handleComment(post.id),
                      onEdit: () => _handleEdit(post.id),
                      onDelete: () => _handleDelete(post.id),
                      coffeeName: post.coffeeName,
                      rating: post.rating,
                      coffeeId: post.coffeeId,
                      isFavorited: post.isFavorited,
                      wantToVisit: post.wantToVisit,
                      onFavorite: post.coffeeId != null 
                        ? () => _handleFavorite(post.coffeeId!) 
                        : null,
                      onWantToVisit: post.coffeeId != null 
                        ? () => _handleWantToVisit(post.coffeeId!) 
                        : null,
                      coffeeAddress: post.coffeeAddress,
                      onEvaluateNow: post.coffeeId != null && post.coffeeName != null
                        ? () => _handleEvaluateNow(post.coffeeId!, post.coffeeName!)
                        : null,
                      onViewAllComments: () => _handleViewAllComments(post.id),
                    );
                  }).toList(),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                if (mounted) {
                  showSideMenu(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String firstName = _getFirstName(currentUser?.displayName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 130,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 25),
            padding: EdgeInsets.only(left: 12, right: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                UserAvatar(user: currentUser, size: 84),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Olá, ',
                              style: GoogleFonts.albertSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '$firstName!',
                              style: GoogleFonts.albertSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Que tal um cafezinho?',
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 95),
              ],
            ),
          ),
          Positioned(
            right: 15,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/hand-coffee.svg',
              width: 95.32,
              height: 142.09,
            ),
          ),
        ],
      ),
    );
  }
}