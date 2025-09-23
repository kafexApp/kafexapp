// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../widgets/feed/feed_post_card.dart';
import '../widgets/custom_boxcafe_minicard.dart'; // IMPORT ADICIONADO
import '../models/post_models.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - em um app real viria de uma API
  List<PostData> userPosts = [];
  List<CafeData> favoriteCafes = [];
  List<CafeData> wantToVisitCafes = [];
  
  // Estatísticas do usuário
  int postsCount = 0;
  int favoritesCount = 0;
  int wantToVisitCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // Mock data para demonstração
    setState(() {
      // Posts do usuário
      userPosts = [
        PostData(
          id: '1',
          authorName: widget.userName,
          authorAvatar: widget.userAvatar ?? 'assets/images/user.svg',
          date: '2h',
          content: 'Descobri um café incrível hoje! O ambiente é aconchegante e o espresso é excepcional.',
          imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
          likes: 24,
          comments: 8,
          isLiked: false,
          recentComments: [
            CommentData(
              id: '1', // ID ADICIONADO
              authorName: 'Ana Silva',
              authorAvatar: 'assets/images/user.svg',
              content: 'Que lugar lindo! Preciso conhecer.',
              date: '1h',
            ),
          ],
        ),
        PostData(
          id: '2',
          authorName: widget.userName,
          authorAvatar: widget.userAvatar ?? 'assets/images/user.svg',
          date: '1d',
          content: 'Domingo perfeito experimentando diferentes métodos de preparo de café.',
          imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
          likes: 15,
          comments: 3,
          isLiked: true,
          recentComments: [],
        ),
      ];

      // Cafés favoritos
      favoriteCafes = [
        CafeData(
          id: '1',
          name: 'Coffee Lab',
          address: 'Vila Madalena, São Paulo',
          rating: 4.8,
          imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300',
          distance: '0.8 km',
        ),
        CafeData(
          id: '2',
          name: 'Café Girondino',
          address: 'Centro, São Paulo',
          rating: 4.5,
          imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300',
          distance: '1.2 km',
        ),
      ];

      // Cafés que quer visitar
      wantToVisitCafes = [
        CafeData(
          id: '3',
          name: 'Bourbon Coffee',
          address: 'Jardins, São Paulo',
          rating: 4.6,
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
          distance: '2.1 km',
        ),
      ];

      // Atualizar contadores
      postsCount = userPosts.length;
      favoritesCount = favoriteCafes.length;
      wantToVisitCount = wantToVisitCafes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: CustomScrollView(
        slivers: [
          // Header com banner e perfil
          _buildProfileHeader(),
          
          // Estatísticas
          _buildStatsSection(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Conteúdo das tabs
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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
          icon: Icon(
            AppIcons.back,
            color: AppColors.carbon,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Banner image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/user-banner-top.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            // Profile avatar and info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Avatar
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
                        child: widget.userAvatar != null
                            ? Image.network(
                                widget.userAvatar!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // User name
                    Text(
                      widget.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.carbon,
                      ),
                    ),
                    
                    SizedBox(height: 4),
                    
                    // Bio or location (mock)
                    Text(
                      'Amante de cafés especiais ☕️',
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

  Widget _buildDefaultAvatar() {
    final initial = widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U';
    final colorIndex = widget.userName.isNotEmpty ? widget.userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
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

  Widget _buildStatsSection() {
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
            _buildStatItem('Posts', postsCount.toString(), AppIcons.heart),
            Container(
              height: 40,
              width: 1,
              color: AppColors.moonAsh,
            ),
            _buildStatItem('Favoritos', favoritesCount.toString(), AppIcons.bookmark),
            Container(
              height: 40,
              width: 1,
              color: AppColors.moonAsh,
            ),
            _buildStatItem('Quero visitar', wantToVisitCount.toString(), AppIcons.location),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, dynamic icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.papayaSensorial,
          size: 24,
        ),
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

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildFavoritesTab(),
          _buildWantToVisitTab(),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (userPosts.isEmpty) {
      return _buildEmptyState(
        'Nenhum post ainda',
        'Este usuário ainda não fez nenhuma publicação.',
        AppIcons.heart,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        return FeedPostCard(
          post: userPosts[index],
          onLike: () {
            // Implementar ação de like
            print('Like no post ${userPosts[index].id}');
          },
          onComment: () {
            // Implementar abertura de comentários
            print('Abrir comentários do post ${userPosts[index].id}');
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (favoriteCafes.isEmpty) {
      return _buildEmptyState(
        'Nenhum favorito',
        'Este usuário ainda não favoritou nenhuma cafeteria.',
        AppIcons.bookmark,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: favoriteCafes.length,
      itemBuilder: (context, index) {
        final cafe = favoriteCafes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: _buildCafeCard(
            name: cafe.name,
            address: cafe.address,
            rating: cafe.rating,
            distance: cafe.distance,
            imageUrl: cafe.imageUrl,
            onTap: () {
              print('Abrir detalhes da cafeteria ${cafe.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildWantToVisitTab() {
    if (wantToVisitCafes.isEmpty) {
      return _buildEmptyState(
        'Lista vazia',
        'Este usuário ainda não marcou nenhuma cafeteria para visitar.',
        AppIcons.location,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: wantToVisitCafes.length,
      itemBuilder: (context, index) {
        final cafe = wantToVisitCafes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: _buildCafeCard(
            name: cafe.name,
            address: cafe.address,
            rating: cafe.rating,
            distance: cafe.distance,
            imageUrl: cafe.imageUrl,
            onTap: () {
              print('Abrir detalhes da cafeteria ${cafe.id}');
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
              child: Icon(
                icon,
                size: 40,
                color: AppColors.grayScale2,
              ),
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

  Widget _buildCafeCard({
    required String name,
    required String address,
    required double rating,
    required String distance,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da cafeteria
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: AppColors.moonAsh,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.moonAsh,
                      child: Center(
                        child: Icon(
                          AppIcons.coffee,
                          color: AppColors.grayScale2,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Informações da cafeteria
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  Text(
                    address,
                    style: GoogleFonts.albertSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        AppIcons.star,
                        color: AppColors.pear,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbon,
                        ),
                      ),
                      Spacer(),
                      Text(
                        distance,
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate para TabBar persistente
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.oatWhite,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

// Modelos de dados para cafeterias
class CafeData {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final String distance;

  CafeData({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.distance,
  });
}