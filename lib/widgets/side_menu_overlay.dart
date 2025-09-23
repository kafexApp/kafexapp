// lib/widgets/side_menu_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/user_manager.dart';
import '../services/auth_service.dart';
import '../screens/home_feed_screen.dart';
import '../screens/cafe_explorer_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/create_post.dart'; // Import do widget create_post

class SideMenuOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const SideMenuOverlay({
    Key? key, 
    required this.onClose,
  }) : super(key: key);

  @override
  _SideMenuOverlayState createState() => _SideMenuOverlayState();
}

class _SideMenuOverlayState extends State<SideMenuOverlay> {
  final AuthService _authService = AuthService();

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

  void _navigateToScreen(BuildContext context, Widget screen) {
    widget.onClose();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showCreatePostModal(BuildContext context) {
    widget.onClose(); // Fecha o menu lateral primeiro
    showCreatePostModal(context); // Usa a função do create_post_screen.dart
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background overlay com fade separado
          AnimatedBuilder(
            animation: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              final animation = ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0);
              return FadeTransition(
                opacity: animation,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
                    child: _buildUserHeaderWithLogout(),
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
                          context: context,
                          icon: AppIcons.home, // Agora usando Phosphor Regular
                          title: 'Início',
                          onTap: () => _navigateToScreen(context, HomeFeedScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.coffee, // Agora usando Phosphor Regular
                          title: 'Cafeterias',
                          onTap: () => _navigateToScreen(context, CafeExplorerScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.notification, // Agora usando Phosphor Regular
                          title: 'Notificações',
                          onTap: () => _navigateToScreen(context, NotificationsScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.user, // Agora usando Phosphor Regular
                          title: 'Perfil',
                          onTap: () {
                            widget.onClose();
                            print('Navegar para perfil');
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.settings, // Agora usando Phosphor Regular
                          title: 'Configurações',
                          onTap: () {
                            widget.onClose();
                            print('Navegar para configurações');
                          },
                        ),
                        
                        Container(
                          height: 1,
                          color: AppColors.moonAsh,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        
                        _buildCreatePostButton(context),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeaderWithLogout() {
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
              child: userPhotoUrl != null 
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
              onTap: widget.onClose,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.moonAsh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.close, // Agora usando Phosphor Regular
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
                        AppIcons.signOut, // Agora usando Phosphor Regular
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

  Widget _buildCreatePostButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCreatePostModal(context),
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
                  AppIcons.plus, // Agora usando Phosphor Regular
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
                AppIcons.chevronRight, // Agora usando Phosphor Regular
                color: AppColors.whiteWhite,
                size: 20,
              ),
            ],
          ),
        ),
      ),
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
    required BuildContext context,
    required dynamic icon, // Agora aceita PhosphorIconData
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
                AppIcons.chevronRight, // Agora usando Phosphor Regular
                color: AppColors.grayScale2,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Função helper para mostrar o menu
void showSideMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent, // Remove o background padrão
    builder: (context) => SideMenuOverlay(
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}