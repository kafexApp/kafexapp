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
import '../screens/create_post_screen.dart'; // NOVO IMPORT
import '../screens/splash_screen.dart';

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
      // LIMPAR DADOS DO USER MANAGER
      UserManager.instance.clearUserData();
      
      await _authService.signOut();
      
      // Navegar de volta para splash/login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Erro no logout: $e');
      // Mesmo com erro, navegar para tela de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    widget.onClose(); // Fechar menu
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Overlay escuro de fundo
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          
          // Menu deslizando de baixo para cima
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
                  // Handle para arrastar (indicador visual)
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grayScale2.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header com perfil do usuário + botão sair
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _buildUserHeaderWithLogout(),
                  ),
                  
                  // Divisor
                  Container(
                    height: 1,
                    color: AppColors.moonAsh,
                    margin: EdgeInsets.symmetric(horizontal: 24),
                  ),
                  
                  // Lista de opções do menu
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.homeFill,
                          title: 'Início',
                          onTap: () => _navigateToScreen(context, HomeFeedScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.coffeeFill,
                          title: 'Cafeterias',
                          onTap: () => _navigateToScreen(context, CafeExplorerScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.notificationFill,
                          title: 'Notificações',
                          onTap: () => _navigateToScreen(context, NotificationsScreen()),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.userFill,
                          title: 'Perfil',
                          onTap: () {
                            widget.onClose();
                            print('Navegar para perfil');
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.settings,
                          title: 'Configurações',
                          onTap: () {
                            widget.onClose();
                            print('Navegar para configurações');
                          },
                        ),
                        
                        // Divisor antes do criar post
                        Container(
                          height: 1,
                          color: AppColors.moonAsh,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        
                        // Botão "Criar post" - agora destacado no final
                        _buildCreatePostButton(context),
                      ],
                    ),
                  ),
                  
                  // Espaçamento inferior para safe area
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
    // OBTER DADOS DO USER MANAGER
    final userManager = UserManager.instance;
    final userName = userManager.userName;
    final userEmail = userManager.userEmail;
    final userPhotoUrl = userManager.userPhotoUrl;

    return Column(
      children: [
        // Header do usuário
        Row(
          children: [
            // Avatar do usuário
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
            
            // Info do usuário
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
            
            // Botão fechar
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
                  AppIcons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Botão "Sair" pequeno
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
                        AppIcons.signOut,
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
        onTap: () {
          widget.onClose();
          showCreatePostModal(context);
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
                  AppIcons.plus,
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
                AppIcons.chevronRight,
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
    // Gerar cor baseada no nome do usuário para consistência
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
                AppIcons.chevronRight,
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
    builder: (context) => SideMenuOverlay(
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}