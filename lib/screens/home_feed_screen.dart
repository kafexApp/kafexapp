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
import 'package:kafex/services/feed_service.dart';
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

  /// Estado do feed vindo do Supabase
  bool _loading = true;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final posts = await FeedService.getFeed(); // ✅ chamada corrigida
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Função para obter o primeiro nome do usuário
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  // Callbacks para ações dos posts
  void _handleLike(String postId) {
    print('Like no post: $postId');
    // TODO: Implementar lógica de like no Supabase
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
    // TODO: Implementar confirmação e exclusão no Supabase
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
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _buildWelcomeSection(),

                // Lista de posts reais do Supabase
                ..._posts.map(
                  (post) => FeedPostCard(
                    key: ValueKey(post.id),
                    post:
                        post, // ⚠️ ainda espera PostData → vamos adaptar o card
                    onLike: () => _handleLike(post.id.toString()),
                    onComment: () => _handleComment(post.id.toString()),
                    onEdit: () => _handleEdit(post.id.toString()),
                    onDelete: () => _handleDelete(post.id.toString()),
                    onViewAllComments: () =>
                        _handleViewAllComments(post.id.toString()),
                  ),
                ),
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
                // Avatar do usuário usando o novo widget
                UserAvatar(user: currentUser, size: 84),

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
