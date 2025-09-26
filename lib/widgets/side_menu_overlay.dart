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
import '../screens/user_profile_screen.dart';
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
      duration: Duration(milliseconds: 350),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
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

  // Método corrigido para navegação
  Future<void> _navigateToScreen(Widget screen) async {
    // Primeiro fecha o menu
    await _closeMenu();
    
    // Aguarda um frame para garantir que o menu foi fechado
    await Future.delayed(Duration(milliseconds: 50));
    
    // Então navega para a tela
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  // Método para navegação push (não replacement)
  Future<void> _pushToScreen(Widget screen) async {
    // Primeiro fecha o menu
    await _closeMenu();
    
    // Aguarda um frame para garantir que o menu foi fechado
    await Future.delayed(Duration(milliseconds: 50));
    
    // Então navega para a tela
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background com Material 3 scrim
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).colorScheme.scrim.withOpacity(0.32),
              ),
            ),
          ),
          
          // Menu com Material 3 design
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle M3
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 8),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: _buildUserHeader(),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: PhosphorIcons.house(),
                            title: 'Início',
                            subtitle: 'Feed principal',
                            onTap: () => _navigateToScreen(HomeFeedScreen()),
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.coffee(),
                            title: 'Cafeterias',
                            subtitle: 'Explorar cafeterias',
                            onTap: () => _navigateToScreen(CafeExplorerScreen()),
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.bell(),
                            title: 'Notificações',
                            subtitle: 'Alertas e atualizações',
                            onTap: () => _pushToScreen(NotificationsScreen()),
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.user(),
                            title: 'Perfil',
                            subtitle: 'Meus dados',
                            onTap: () {
                              final userManager = UserManager.instance;
                              _pushToScreen(UserProfileScreen(
                                userId: userManager.userEmail, // Usando email como ID
                                userName: userManager.userName,
                                userAvatar: userManager.userPhotoUrl,
                              ));
                            },
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.gear(),
                            title: 'Configurações',
                            subtitle: 'Preferências do app',
                            onTap: () => _pushToScreen(ProfileSettingsScreen()),
                          ),
                          
                          SizedBox(height: 20),
                          
                          _buildCreatePostButton(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
            // Avatar com Material 3
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        userPhotoUrl,
                        width: 64,
                        height: 64,
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
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Botão fechar
            IconButton(
              onPressed: _closeMenu,
              icon: Icon(
                PhosphorIcons.x(),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Botão logout
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: Icon(
              PhosphorIcons.signOut(),
              size: 18,
            ),
            label: Text(
              'Sair da conta',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error.withOpacity(0.12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String userName) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: GoogleFonts.albertSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Ícone com Material 3
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
              
              SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                PhosphorIcons.caretRight(),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: () async {
          await _animationController.reverse();
          Navigator.of(context).pop();
          
          await Future.delayed(Duration(milliseconds: 50));
          
          if (context.mounted) {
            showCreatePostModal(context);
          }
        },
        icon: Icon(
          PhosphorIcons.plus(),
          size: 20,
        ),
        label: Text(
          'Criar post',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.papayaSensorial,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

void showSideMenu(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) => SideMenuOverlay(
        onClose: () => Navigator.of(context).pop(),
      ),
      transitionDuration: Duration(milliseconds: 350),
      reverseTransitionDuration: Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}