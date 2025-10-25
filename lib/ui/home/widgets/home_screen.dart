import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/side_menu_overlay.dart';
import '../../posts/factories/post_card_factory.dart';
import '../viewmodel/home_feed_viewmodel.dart';
import '../../../services/auth_state_handler.dart';
import 'welcome_section.dart';
import 'clube_xicara_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _photoSyncExecuted = false;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _syncUserDataOnce();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Mostrar/esconder botão de voltar ao topo
      if (_scrollController.offset > 300 && !_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }

      // Carregar mais posts quando chegar perto do fim
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final viewModel = context.read<HomeFeedViewModel>();
        if (viewModel.hasMorePosts && !viewModel.isLoadingMore) {
          viewModel.loadMorePosts.execute();
        }
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _syncUserDataOnce() async {
    if (_photoSyncExecuted) return;

    _photoSyncExecuted = true;

    await Future.delayed(Duration(milliseconds: 500));

    try {
      print('🔄 Iniciando sincronização completa dos dados...');
      await AuthStateHandler.syncUserData();
    } catch (e) {
      print('❌ Erro na sincronização: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeFeedViewModel>();

    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => viewModel.refreshFeed.execute(),
            color: AppColors.papayaSensorial,
            child: ListenableBuilder(
              listenable: viewModel.loadFeed,
              builder: (context, _) {
                if (viewModel.loadFeed.running) {
                  return _buildLoading();
                }

                if (viewModel.loadFeed.error) {
                  return _buildError(viewModel);
                }

                if (viewModel.posts.isEmpty) {
                  return _buildEmpty();
                }

                return _buildFeed(context, viewModel);
              },
            ),
          ),
          
          // Botão de voltar ao topo - Posicionado acima da navbar
          Positioned(
            right: 16,
            bottom: 140,
            child: AnimatedOpacity(
              opacity: _showScrollToTopButton ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: _showScrollToTopButton
                  ? Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.whiteWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _scrollToTop,
                        icon: Icon(
                          Icons.arrow_upward,
                          color: AppColors.carbon,
                          size: 24,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                showSideMenu(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
      ),
    );
  }

  Widget _buildError(HomeFeedViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.spiced),
          SizedBox(height: 16),
          Text(
            'Erro ao carregar feed',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.loadFeed.execute(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.papayaSensorial,
            ),
            child: Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.coffee, size: 64, color: AppColors.grayScale2),
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
    );
  }

  Widget _buildFeed(BuildContext context, HomeFeedViewModel viewModel) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120, top: 0, left: 0, right: 0),
      itemCount:
          viewModel.posts.length +
          3,
      itemBuilder: (context, index) {
        if (index == 0) {
          return WelcomeSection();
        }

        if (index == 1) {
          return ClubeXicaraBanner();
        }

        if (index <= viewModel.posts.length + 1) {
          final post = viewModel.posts[index - 2];
          return PostCardFactory.create(
            post: post,
            onLike: () => viewModel.likePost(post.id),
            onComment: () => _handleComment(post.id),
            onEdit: () => _handleEdit(post.id),
            onDelete: () => viewModel.deletePost(post.id),
          );
        }

        if (viewModel.isLoadingMore) {
          return _buildLoadingIndicator();
        } else if (!viewModel.hasMorePosts) {
          return _buildEndMessage();
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
        ),
      ),
    );
  }

  Widget _buildEndMessage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          'Você viu todos os posts! ☕',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleComment(String postId) {
    print('Comentário no post: $postId');
  }

  void _handleEdit(String postId) {
    print('Editar post: $postId');
  }
}