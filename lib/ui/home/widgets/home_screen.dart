import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/user_manager.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/side_menu_overlay.dart';
import '../../../widgets/feed/post_card_factory.dart';
import '../../../widgets/common/user_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodel/home_feed_viewmodel.dart';
import '../viewmodel/post_adapter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.papayaSensorial,
        ),
      ),
    );
  }

  Widget _buildError(HomeFeedViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.spiced,
          ),
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
    );
  }

  Widget _buildFeed(BuildContext context, HomeFeedViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        _buildWelcomeSection(),
        ...viewModel.posts.map((post) {
          final postData = PostAdapter.toPostData(post);
          return PostCardFactory.create(
            post: postData,
            type: postData.type,
            onLike: () => viewModel.likePost(post.id),
            onComment: () => _handleComment(post.id),
            onEdit: () => _handleEdit(post.id),
            onDelete: () => viewModel.deletePost(post.id),
            coffeeName: postData.coffeeName,
            rating: postData.rating,
            coffeeId: postData.coffeeId,
            isFavorited: postData.isFavorited,
            wantToVisit: postData.wantToVisit,
            onFavorite: postData.coffeeId != null
                ? () => _handleFavorite(postData.coffeeId!)
                : null,
            onWantToVisit: postData.coffeeId != null
                ? () => _handleWantToVisit(postData.coffeeId!)
                : null,
            coffeeAddress: postData.coffeeAddress,
            onEvaluateNow: postData.coffeeId != null && postData.coffeeName != null
                ? () => _handleEvaluateNow(
                      postData.coffeeId!,
                      postData.coffeeName!,
                    )
                : null,
            onViewAllComments: () => _handleViewAllComments(post.id),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Builder(
      builder: (context) {
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
                            UserManager.instance.hasLocation
                                ? 'Em ${UserManager.instance.locationDisplay}'
                                : 'Que tal um cafezinho?',
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
      },
    );
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  void _handleComment(String postId) {
    print('Comentário no post: $postId');
  }

  void _handleEdit(String postId) {
    print('Editar post: $postId');
  }

  void _handleViewAllComments(String postId) {
    print('Ver todos os comentários do post: $postId');
  }

  void _handleFavorite(String coffeeId) {
    print('Favoritar cafeteria: $coffeeId');
  }

  void _handleWantToVisit(String coffeeId) {
    print('Quero visitar cafeteria: $coffeeId');
  }

  void _handleEvaluateNow(String coffeeId, String coffeeName) {
    print('Avaliar cafeteria: $coffeeName ($coffeeId)');
  }
}