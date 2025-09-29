import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../widgets/feed/feed_post_card.dart';
import '../models/cafe_model.dart';
import '../backend/supabase/tables/feed_com_usuario.dart';
import '../models/comment_models.dart';
import '../widgets/custom_boxcafe_minicard.dart';

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

  List<FeedComUsuarioRow> userPosts = [];
  List<CafeModel> favoriteCafes = [];
  List<CafeModel> wantToVisitCafes = [];

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
    setState(() {
      userPosts = [
        FeedComUsuarioRow({
          'id': 1,
          'criado_em': DateTime.now().subtract(Duration(hours: 2)),
          'descricao':
              'Descobri um café incrível hoje! O ambiente é aconchegante e o espresso é excepcional.',
          'imagem_url':
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
          'usuario': widget.userName,
          'comentarios': '8',
        }),
        FeedComUsuarioRow({
          'id': 2,
          'criado_em': DateTime.now().subtract(Duration(days: 1)),
          'descricao':
              'Domingo perfeito experimentando diferentes métodos de preparo de café.',
          'imagem_url':
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
          'usuario': widget.userName,
          'comentarios': '3',
        }),
      ];

      favoriteCafes = [
        CafeModel(
          id: '1',
          name: 'Coffee Lab',
          address: 'Vila Madalena, São Paulo - SP, 05416-001',
          rating: 4.8,
          distance: '0.8 km',
          imageUrl:
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300',
          isOpen: true,
          position: LatLng(-23.5505, -46.6333),
          price: 'R\$ 15-25',
          specialties: ['Espresso', 'V60', 'Chemex', 'Cold Brew'],
        ),
        CafeModel(
          id: '2',
          name: 'Café Girondino',
          address: 'Centro, São Paulo - SP, 01310-100',
          rating: 4.5,
          distance: '1.2 km',
          imageUrl:
              'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300',
          isOpen: true,
          position: LatLng(-23.5611, -46.6564),
          price: 'R\$ 8-25',
          specialties: ['Café Tradicional', 'Doces Caseiros', 'Pão de Açúcar'],
        ),
      ];

      wantToVisitCafes = [
        CafeModel(
          id: '3',
          name: 'Bourbon Coffee',
          address: 'Jardins, São Paulo - SP, 01401-001',
          rating: 4.6,
          distance: '2.1 km',
          imageUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
          isOpen: true,
          position: LatLng(-23.5729, -46.6520),
          price: 'R\$ 20-45',
          specialties: [
            'Bourbon Santos',
            'Cappuccino Artesanal',
            'French Press',
          ],
        ),
      ];

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
          _buildProfileHeader(),
          _buildStatsSection(),
          _buildTabBar(),
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

                    Text(
                      widget.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.carbon,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Coffeelover ☕️',
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
    final initial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : 'U';
    final colorIndex = widget.userName.isNotEmpty
        ? widget.userName.codeUnitAt(0) % 5
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
            Container(height: 40, width: 1, color: AppColors.moonAsh),
            _buildStatItem(
              'Favoritos',
              favoritesCount.toString(),
              AppIcons.bookmark,
            ),
            Container(height: 40, width: 1, color: AppColors.moonAsh),
            _buildStatItem(
              'Quero visitar',
              wantToVisitCount.toString(),
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
            print('Like no post ${userPosts[index].id}');
          },
          onComment: () {
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