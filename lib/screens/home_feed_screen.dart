import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Função para obter o primeiro nome do usuário
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  // Função para gerar nomes mock para os avatares
  String _getUserName(int index) {
    final List<String> mockNames = [
      'Ana Silva',
      'Carlos Lima',
      'Maria José',
      'João Pedro',
      'Beatriz Costa',
    ];
    return mockNames[index % mockNames.length];
  }

  // Função para mostrar modal de opções do post
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
                  print('Editar post: ${post.id}');
                  // TODO: Implementar edição do post
                },
                leading: Icon(
                  Icons.edit_outlined,
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
                  print('Excluir post: ${post.id}');
                  // TODO: Implementar confirmação e exclusão do post
                },
                leading: Icon(
                  Icons.delete_outline,
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
            height: 110, // Aumentado de 100 para 110 para corrigir overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(), // Adiciona efeito de bounce no iOS
              itemCount: userAvatars.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 20), // Aumentado de 16 para 20
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Adiciona para evitar overflow
                    children: [
                      // Avatar container - SEM BORDA
                      Container(
                        width: 80, // Aumentado de 60 para 80
                        height: 80, // Aumentado de 60 para 80
                        decoration: BoxDecoration(
                          color: AppColors.moonAsh,
                          shape: BoxShape.circle,
                          // REMOVIDAS as bordas e shadows
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            userAvatars[index],
                            width: 48, // Aumentado de 36 para 48
                            height: 48, // Aumentado de 36 para 48
                          ),
                        ),
                      ),
                      SizedBox(height: 6), // Reduzido de 8 para 6
                      // Nome do usuário (mock data por enquanto)
                      Flexible( // Adiciona Flexible para evitar overflow
                        child: Text(
                          _getUserName(index),
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                        Icons.image_not_supported,
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