// lib/widgets/side_menu_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../services/auth_service.dart';
import '../screens/home_feed_screen.dart';
import '../screens/cafe_explorer_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/splash_screen.dart'; // Para navegar após logout

class SideMenuOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final AuthService _authService = AuthService();

  SideMenuOverlay({Key? key, required this.onClose}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.signOut();
      // Navegar de volta para splash/login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Erro no logout: $e');
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    onClose(); // Fechar menu
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dados fixos para o usuário mock (já que não há Firebase)
    final userName = 'Usuário Kafex';
    final userEmail = 'usuario@kafex.app';
    final hasPhoto = false; // Como não há autenticação real
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Overlay escuro de fundo
          GestureDetector(
            onTap: onClose,
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
                  
                  // Header com perfil do usuário
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
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
                          child: _buildDefaultAvatar(),
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
                          onTap: onClose,
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
                          icon: AppIcons.plus,
                          title: 'Criar post',
                          onTap: () {
                            onClose();
                            // TODO: Implementar tela de criação de post
                            print('Navegar para criar post');
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.userFill,
                          title: 'Perfil',
                          onTap: () {
                            onClose();
                            // TODO: Implementar tela de perfil
                            print('Navegar para perfil');
                          },
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.settings,
                          title: 'Configurações',
                          onTap: () {
                            onClose();
                            // TODO: Implementar tela de configurações
                            print('Navegar para configurações');
                          },
                        ),
                        
                        // Divisor antes do logout
                        Container(
                          height: 1,
                          color: AppColors.moonAsh,
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        
                        _buildMenuItem(
                          context: context,
                          icon: AppIcons.signOut,
                          title: 'Sair',
                          isLogout: true,
                          onTap: () => _logout(context),
                        ),
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

  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.papayaSensorial.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.userFill,
        color: AppColors.papayaSensorial,
        size: 30,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
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
                  color: isLogout 
                      ? AppColors.spiced.withOpacity(0.1)
                      : AppColors.papayaSensorial.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isLogout 
                      ? AppColors.spiced
                      : AppColors.papayaSensorial,
                  size: 22,
                ),
              ),
              
              SizedBox(width: 16),
              
              Text(
                title,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout 
                      ? AppColors.spiced
                      : AppColors.textPrimary,
                ),
              ),
              
              Spacer(),
              
              if (!isLogout)
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