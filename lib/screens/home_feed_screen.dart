import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/side_menu_overlay.dart';

// Enum para tipos de post
enum PostType {
  image,
  video,
  cafeReview,
  newCafe,
}

// Modelo de dados para posts
class PostData {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String date;
  final PostType type;
  final String? imageUrl;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;
  final String? cafeName;

  PostData({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    required this.type,
    this.imageUrl,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.cafeName,
  });
}

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Dados mock para demonstração
  final List<String> userAvatars = [
    'assets/images/default-avatar.svg',
    'assets/images/default-avatar.svg',
    'assets/images/default-avatar.svg',
    'assets/images/default-avatar.svg',
    'assets/images/default-avatar.svg',
  ];

  final List<PostData> posts = [
    PostData(
      id: '1',
      authorName: 'Paulo Cristiano',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '03/01/2024',
      type: PostType.cafeReview,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'Acabei de experimentar um cappuccino com uma crema perfeita! A textura estava cremosa e suave, com uma cor dourada que indicava a extração ideal do espresso. A crema adicionou um toque de doçura...',
      likes: 42,
      comments: 8,
    ),
    PostData(
      id: '2',
      authorName: 'Amanda Klein',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '02/01/2024',
      type: PostType.image,
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'A cena realmente faz toda a diferença. É incrível como a atmosfera e o sabor da experiência.',
      likes: 28,
      comments: 5,
      isLiked: true,
    ),
    PostData(
      id: '3',
      authorName: 'Paulo Cristiano',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '01/01/2024',
      type: PostType.newCafe,
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'Acabei de experimentar um cappuccino com uma crema perfeita! A textura estava cremosa e suave, com uma cor dourada que indicava a extração ideal do espresso. A crema adicionou um toque de doçura...',
      likes: 67,
      comments: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Conteúdo principal
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Seção de boas-vindas
                _buildWelcomeSection(),
                
                // Lista de usuários (avatares)
                _buildUsersSection(),
                
                // Lista de posts
                _buildPostsList(),
                
                // Espaçamento para a navbar sobreposta
                SizedBox(height: 110),
              ],
            ),
          ),
          
          // Navbar sobreposta
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                print('Abrir menu sidebar');
                showSideMenu(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 120,
      child: Stack(
        children: [
          // Card branco de fundo
          Container(
            margin: EdgeInsets.only(top: 25),
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar do usuário
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/default-avatar.svg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Texto de boas-vindas
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
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'Francisca!',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Que tal um cafezinho?',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Espaço para a mão que vai sobrepor
                SizedBox(width: 95),
              ],
            ),
          ),
          
          // Ilustração da mão com café (colada na base do card)
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

  Widget _buildUsersSection() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curadoria dos melhores',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: userAvatars.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.moonAsh,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        userAvatars[index],
                        width: 36,
                        height: 36,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(posts[index]);
      },
    );
  }

  Widget _buildPostCard(PostData post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do post
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      post.authorAvatar,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        post.date,
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('Abrir menu do post');
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: SvgPicture.asset(
                      'assets/images/more.svg',
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Imagem do post
          if (post.imageUrl != null)
            Container(
              width: double.infinity,
              height: 280,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.moonAsh,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.moonAsh,
                    child: Center(
                      child: CircularProgressIndicator(
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
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Ações e conteúdo do post
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botões de ação
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print('Toggle like');
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            post.isLiked 
                                ? 'assets/images/like-full.svg'
                                : 'assets/images/like.svg',
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${post.likes}',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: AppColors.grayScale2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    
                    GestureDetector(
                      onTap: () {
                        print('Abrir comentários');
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/comment.svg',
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${post.comments}',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: AppColors.grayScale2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Spacer(),
                    
                    Row(
                      children: [
                        // Botão Favorito
                        GestureDetector(
                          onTap: () {
                            print('Toggle favorito');
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.moonAsh,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/favorite.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        
                        // Botão "Quero visitar"
                        GestureDetector(
                          onTap: () {
                            print('Quero visitar');
                          },
                          child: Container(
                            height: 40,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.moonAsh,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/flag.svg',
                                  width: 16,
                                  height: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Quero visitar',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.papayaSensorial,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Conteúdo do post
                Text(
                  post.content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}