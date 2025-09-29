import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';
import 'package:kafex/ui/posts/widgets/feed_post_widget.dart';
import 'package:kafex/widgets/custom_boxcafe_minicard.dart';
import 'package:kafex/ui/user_profile/viewmodel/user_profile_viewmodel.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<UserProfileViewModel>().changeTab.execute(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<UserProfileViewModel>();
      viewModel.loadUserProfile.execute();
      viewModel.loadTabData.execute();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.oatWhite,
          body: CustomScrollView(
            slivers: [
              _buildProfileHeader(viewModel),
              _buildStatsSection(viewModel),
              _buildTabBar(),
              _buildTabContent(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfileViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: false,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite.withOpacity(0.9),
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
          icon: Icon(AppIcons.back, color: AppColors.carbon, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/user-banner-top.png'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('Erro ao carregar banner: $exception');
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.papayaSensorial.withOpacity(0.8),
                      AppColors.velvetMerlot.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.whiteWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.whiteWhite,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: viewModel.userProfile?.avatar != null
                            ? Image.network(
                                viewModel.userProfile!.avatar!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar(viewModel);
                                },
                              )
                            : _buildDefaultAvatar(viewModel),
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      viewModel.userProfile?.name ?? '',
                      style: GoogleFonts.albertSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.carbon,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      viewModel.userProfile?.bio ?? 'Coffeelover ☕️',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(UserProfileViewModel viewModel) {
    if (viewModel.userProfile == null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.moonAsh,
          shape: BoxShape.circle,
        ),
      );
    }

    final initial = viewModel.getDefaultAvatar(viewModel.userProfile!.name);
    final avatarColor = viewModel.getAvatarColor(viewModel.userProfile!.name);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserProfileViewModel viewModel) {
    if (viewModel.loadUserProfile.running) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.all(20),
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Posts', 
              (viewModel.userProfile?.postsCount ?? 0).toString(), 
              AppIcons.heart
            ),
            Container(height: 40, width: 1, color: AppColors.moonAsh),
            _buildStatItem(
              'Favoritos',
              (viewModel.userProfile?.favoritesCount ?? 0).toString(),
              AppIcons.bookmark,
            ),
            Container(height: 40, width: 1, color: AppColors.moonAsh),
            _buildStatItem(
              'Quero visitar',
              (viewModel.userProfile?.wantToVisitCount ?? 0).toString(),
              AppIcons.location,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, dynamic icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.papayaSensorial, size: 24),
        SizedBox(height: 8),
        Text(
          count,
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.carbon,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.albertSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.papayaSensorial,
          indicatorWeight: 3,
          labelColor: AppColors.papayaSensorial,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'Posts'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Quero visitar'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(UserProfileViewModel viewModel) {
    if (viewModel.loadTabData.running) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(viewModel),
          _buildFavoritesTab(viewModel),
          _buildWantToVisitTab(viewModel),
        ],
      ),
    );
  }

  Widget _buildPostsTab(UserProfileViewModel viewModel) {
    if (viewModel.userPosts.isEmpty) {
      return _buildEmptyState(
        'Nenhum post ainda',
        'Este usuário ainda não fez nenhuma publicação.',
        AppIcons.heart,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16),
      itemCount: viewModel.userPosts.length,
      itemBuilder: (context, index) {
        final post = viewModel.userPosts[index];
        
        // Convertendo Post para FeedComUsuarioRow (compatibilidade)
        final feedPost = FeedComUsuarioRow({
          'id': int.tryParse(post.id) ?? index,
          'criado_em': post.createdAt,
          'descricao': post.content,
          'imagem_url': post.imageUrl,
          'usuario': post.authorName,
          'comentarios': post.commentsCount.toString(),
        });

        return FeedPostCard(
          post: feedPost,
          onLike: () => viewModel.likePost.execute(post.id),
          onComment: () => viewModel.openComments.execute(post.id),
        );
      },
    );
  }

  Widget _buildFavoritesTab(UserProfileViewModel viewModel) {
    if (viewModel.favoriteCafes.isEmpty) {
      return _buildEmptyState(
        'Nenhum favorito',
        'Este usuário ainda não favoritou nenhuma cafeteria.',
        AppIcons.bookmark,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: viewModel.favoriteCafes.length,
      itemBuilder: (context, index) {
        final cafe = viewModel.favoriteCafes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: CustomBoxcafeMinicard(
            cafe: cafe,
            onTap: () {
              print('Cafeteria favorita ${cafe.name} clicada');
            },
          ),
        );
      },
    );
  }

  Widget _buildWantToVisitTab(UserProfileViewModel viewModel) {
    if (viewModel.wantToVisitCafes.isEmpty) {
      return _buildEmptyState(
        'Lista vazia',
        'Este usuário ainda não marcou nenhuma cafeteria para visitar.',
        AppIcons.location,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: viewModel.wantToVisitCafes.length,
      itemBuilder: (context, index) {
        final cafe = viewModel.wantToVisitCafes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: CustomBoxcafeMinicard(
            cafe: cafe,
            onTap: () {
              print('Cafeteria "quero visitar" ${cafe.name} clicada');
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, dynamic icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.grayScale2),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale1,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.oatWhite, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}