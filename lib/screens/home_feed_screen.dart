import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/side_menu_overlay.dart';
import '../widgets/feed/feed_post_card.dart';
import '../widgets/common/user_avatar.dart'; // NOVA IMPORTAÇÃO
import '../models/post_models.dart';
import '../models/comment_models.dart';

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  final List<PostData> posts = [
    PostData(
      id: '1',
      authorName: 'Paulo Cristiano',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '03/01/2024',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'Acabei de experimentar um cappuccino com uma crema perfeita! A textura estava cremosa e suave, com uma cor dourada que indicava a extração ideal do espresso. A crema adicionou um toque de doçura...',
      likes: 42,
      comments: 8,
      recentComments: [
        CommentData(
          id: '1',
          userName: 'Amanda Klein',
          userAvatar: null,
          content: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          likes: 5,
          isLiked: false,
          authorAvatar: 'assets/images/default-avatar.svg',
          date: '03/05/2024',
        ),
      ],
    ),
    PostData(
      id: '2',
      authorName: 'Amanda Klein',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '02/01/2024',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'A cena realmente faz toda a diferença. É incrível como a atmosfera e o sabor da experiência.',
      likes: 28,
      comments: 5,
      isLiked: true,
      recentComments: [
        CommentData(
          id: '2',
          userName: 'João Silva',
          userAvatar: null,
          content: 'Concordo totalmente! O ambiente é fundamental para a experiência do café.',
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          likes: 2,
          isLiked: false,
          authorAvatar: 'assets/images/default-avatar.svg',
          date: '02/02/2024',
        ),
      ],
    ),
    PostData(
      id: '3',
      authorName: 'Paulo Cristiano',
      authorAvatar: 'assets/images/default-avatar.svg',
      date: '01/01/2024',
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      content: 'Descobri uma nova cafeteria no centro da cidade. O lugar tem uma atmosfera incrível e o café é excepcional!',
      likes: 67,
      comments: 12,
      recentComments: [
        CommentData(
          id: '3',
          userName: 'Maria Santos',
          userAvatar: null,
          content: 'Qual é o nome da cafeteria? Estou sempre procurando novos lugares para experimentar!',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          likes: 1,
          isLiked: false,
          authorAvatar: 'assets/images/default-avatar.svg',
          date: '01/02/2024',
        ),
      ],
    ),
  ];

  // Função para obter o primeiro nome do usuário
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  // Callbacks para ações dos posts
  void _handleLike(String postId) {
    print('Like no post: $postId');
    // TODO: Implementar lógica de like
  }

  void _handleComment(String postId) {
    print('Comentário no post: $postId');
    // TODO: Navegar para tela de comentários
  }

  void _handleEdit(String postId) {
    print('Editar post: $postId');
    // TODO: Implementar edição do post
  }

  void _handleDelete(String postId) {
    print('Excluir post: $postId');
    // TODO: Implementar confirmação e exclusão do post
  }

  void _handleViewAllComments(String postId) {
    print('Ver todos os comentários do post: $postId');
    // TODO: Navegar para tela de comentários completa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Conteúdo principal usando ListView
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 110),
            children: [
              // Seção de boas-vindas
              _buildWelcomeSection(),
              
              // Posts individuais
              ...posts.map((post) => FeedPostCard(
                key: ValueKey(post.id),
                post: post,
                onLike: () => _handleLike(post.id),
                onComment: () => _handleComment(post.id),
                onEdit: () => _handleEdit(post.id),
                onDelete: () => _handleDelete(post.id),
                onViewAllComments: () => _handleViewAllComments(post.id),
              )).toList(),
            ],
          ),
          
          // Navbar sobreposta
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavbar(
              onMenuPressed: () {
                if (mounted) {
                  print('Abrir menu sidebar');
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
    // Obter usuário atual do Firebase
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String firstName = _getFirstName(currentUser?.displayName);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 130,
      child: Stack(
        children: [
          // Card branco de fundo
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
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar do usuário usando o novo widget
                UserAvatar(
                  user: currentUser,
                  size: 84,
                ),
                
                SizedBox(width: 12),
                
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
                      SizedBox(height: 1),
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
}