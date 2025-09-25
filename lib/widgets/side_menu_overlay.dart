import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/user_manager.dart';
import '../services/auth_service.dart';
import '../screens/home_feed_screen.dart';
import '../screens/cafe_explorer_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../widgets/create_post.dart';

class SideMenuOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const SideMenuOverlay({
    Key? key, 
    required this.onClose,
  }) : super(key: key);

  @override
  _SideMenuOverlayState createState() => _SideMenuOverlayState();
}

class _SideMenuOverlayState extends State<SideMenuOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0), // Começa fora da tela (embaixo)
      end: Offset.zero,        // Termina na posição normal
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Iniciar animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeMenu() async {
    await _animationController.reverse();
    widget.onClose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      UserManager.instance.clearUserData();
      await _authService.signOut();
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Erro no logout: $e');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _openSettings() {
    _closeMenu();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:       Stack(
        children: [
          // Background com fade in/out
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          // Menu com animação de slide
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grayScale2.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: _buildUserHeader(),
                    ),
                    
                    Container(
                      height: 1,
                      color: AppColors.moonAsh,
                      margin: EdgeInsets.symmetric(horizontal: 24),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: PhosphorIcons.house(),
                            title: 'Início',
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => HomeFeedScreen()),
                              );
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.coffee(),
                            title: 'Cafeterias',
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => CafeExplorerScreen()),
                              );
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.bell(),
                            title: 'Notificações',
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => NotificationsScreen()),
                              );
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.user(),
                            title: 'Perfil',
                            onTap: () {
                              _closeMenu();
                              print('Navegar para perfil - Em desenvolvimento');
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.gear(),
                            title: 'Configurações',
                            onTap: _openSettings,
                          ),
                          
                          Container(
                            height: 1,
                            color: AppColors.moonAsh,
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          
                          _buildCreatePostButton(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final userManager = UserManager.instance;
    final userName = userManager.userName;
    final userEmail = userManager.userEmail;
    final userPhotoUrl = userManager.userPhotoUrl;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.papayaSensorial.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        userPhotoUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(userName);
                        },
                      ),
                    )
                  : _buildDefaultAvatar(userName),
            ),
            
            SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.albertSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.moonAsh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.x(),
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _logout(context),
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.spiced.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.spiced.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.signOut(),
                        color: AppColors.spiced,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sair',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.spiced,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String userName) {
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.carbon,
      AppColors.grayScale2,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: GoogleFonts.albertSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.papayaSensorial.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.papayaSensorial,
                  size: 22,
                ),
              ),
              
              SizedBox(width: 16),
              
              Text(
                title,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              
              Spacer(),
              
              Icon(
                PhosphorIcons.caretRight(),
                color: AppColors.grayScale2,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Fechar menu e aguardar a animação completar
          await _animationController.reverse();
          Navigator.of(context).pop();
          
          // Aguardar um frame extra para garantir que a navegação foi concluída
          await Future.delayed(Duration(milliseconds: 50));
          
          // Abrir modal de criar post
          if (context.mounted) {
            showCreatePostModal(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.papayaSensorial,
                AppColors.papayaSensorial.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.papayaSensorial.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.plus(),
                  color: AppColors.whiteWhite,
                  size: 24,
                ),
              ),
              
              SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criar post',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteWhite,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Compartilhe sua experiência com café',
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        color: AppColors.whiteWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                PhosphorIcons.caretRight(),
                color: AppColors.whiteWhite,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSideMenu(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // Permite transparência
      barrierColor: Colors.transparent, // Remove qualquer barreira colorida padrão
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) => SideMenuOverlay(
        onClose: () => Navigator.of(context).pop(),
      ),
      transitionDuration: Duration(milliseconds: 300),
      reverseTransitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Retorna diretamente o child, sem nenhuma animação adicional
        return child;
      },
    ),
  );
}