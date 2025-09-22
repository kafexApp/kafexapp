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

// Modelo de dados para o post (temporário até criar o arquivo separado)
class PostData {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String date;
  final String? imageUrl;
  final String? videoUrl;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<CommentData> recentComments;

  PostData({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    this.imageUrl,
    this.videoUrl,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.recentComments = const [],
  });
}

// Modelo de dados para comentários (temporário)
class CommentData {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String date;

  CommentData({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.date,
  });
}

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
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
          authorName: 'Amanda Klein',
          authorAvatar: 'assets/images/default-avatar.svg',
          content: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
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
          authorName: 'João Silva',
          authorAvatar: 'assets/images/default-avatar.svg',
          content: 'Concordo totalmente! O ambiente é fundamental para a experiência do café.',
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
          authorName: 'Maria Santos',
          authorAvatar: 'assets/images/default-avatar.svg',
          content: 'Qual é o nome da cafeteria? Estou sempre procurando novos lugares para experimentar!',
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

  // Modal de opções do post
  void _showPostOptionsModal(BuildContext context, PostData post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual do modal
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayScale2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Botão Editar
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _handleEdit(post.id);
                },
                leading: Icon(
                  AppIcons.edit,
                  color: AppColors.papayaSensorial,
                  size: 24,
                ),
                title: Text(
                  'Editar',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              // Divisor
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.moonAsh,
                indent: 16,
                endIndent: 16,
              ),
              
              // Botão Excluir
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _handleDelete(post.id);
                },
                leading: Icon(
                  AppIcons.delete,
                  color: AppColors.spiced,
                  size: 24,
                ),
                title: Text(
                  'Excluir',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.spiced,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

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
                
                // Lista de posts (removida seção de usuários)
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
    // Obter usuário atual do Firebase
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String firstName = _getFirstName(currentUser?.displayName);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 130, // Aumentado de 120 para 130 para acomodar texto maior
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
                // Avatar do usuário - agora dinâmico
                Container(
                  width: 84, // Aumentado de 55 para 84
                  height: 84, // Aumentado de 55 para 84
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh,
                    shape: BoxShape.circle,
                  ),
                  child: currentUser?.photoURL != null
                      ? Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(currentUser!.photoURL!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                SizedBox(width: 2), // Reduzido para 2
                
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
                                fontSize: 18, // Aumentado de 16 para 18
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '$firstName!',
                              style: GoogleFonts.albertSans(
                                fontSize: 18, // Aumentado de 16 para 18
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1), // Reduzido para 1
                      Text(
                        'Que tal um cafezinho?',
                        style: GoogleFonts.albertSans(
                          fontSize: 16, // Aumentado de 14 para 16
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

  // Widget para avatar padrão quando não há foto do usuário
  Widget _buildDefaultAvatar() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/default-avatar.svg',
        width: 50, // Ajustado proporcionalmente
        height: 50, // Ajustado proporcionalmente
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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(20),
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
          // Header do post
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                      width: 20,
                      height: 20,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        post.date,
                        style: GoogleFonts.albertSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showPostOptionsModal(context, post);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/images/more.svg',
                      width: 20,
                      height: 20,
                      color: AppColors.grayScale2,
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
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.moonAsh,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.moonAsh,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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
                        AppIcons.image, // Ícone Phosphor
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Ações do post
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Botão Like
                GestureDetector(
                  onTap: () {
                    print('Toggle like');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      post.isLiked 
                          ? 'assets/images/like-full.svg'
                          : 'assets/images/like.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                
                // Botão Comentário
                GestureDetector(
                  onTap: () {
                    print('Abrir comentários');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/images/comment.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                
                Spacer(),
                
                // Botão Favorito
                GestureDetector(
                  onTap: () {
                    print('Toggle favorito');
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/images/favorite.svg',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
                
                // Botão "Quero visitar"
                GestureDetector(
                  onTap: () {
                    print('Quero visitar');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/flag.svg',
                          width: 14,
                          height: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Quero visitar',
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
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
          ),
          
          // Contador de likes
          if (post.likes > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                '${post.likes} curtidas',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

          // Conteúdo do post
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.authorName} ',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: post.content,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Preview de comentários
          if (post.comments > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GestureDetector(
                onTap: () {
                  print('Ver todos os comentários');
                },
                child: Text(
                  'Ver todos os ${post.comments} comentários',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.grayScale2,
                  ),
                ),
              ),
            ),
          
          // Comentário preview
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.oatWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar do comentário
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.moonAsh,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/default-avatar.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Conteúdo do comentário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome e data
                        Row(
                          children: [
                            Text(
                              'Amanda Klein',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '03/05/2024',
                              style: GoogleFonts.albertSans(
                                fontSize: 12,
                                color: AppColors.grayScale2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        // Texto do comentário
                        Text(
                          'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
                          style: GoogleFonts.albertSans(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}