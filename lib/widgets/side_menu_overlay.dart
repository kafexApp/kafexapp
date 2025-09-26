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
      duration: Duration(milliseconds: 350), // Animação mais suave M3
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curva M3
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
                color: Theme.of(context).colorScheme.scrim.withOpacity(0.32), // M3 scrim
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
                  color: Theme.of(context).colorScheme.surface, // M3 surface
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28), // M3 border radius
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.15), // M3 shadow
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4), // M3 handle
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
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => HomeFeedScreen()),
                              );
                            },
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.coffee(),
                            title: 'Cafeterias',
                            subtitle: 'Explorar cafeterias',
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => CafeExplorerScreen()),
                              );
                            },
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.bell(),
                            title: 'Notificações',
                            subtitle: 'Alertas e atualizações',
                            onTap: () {
                              _closeMenu();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => NotificationsScreen()),
                              );
                            },
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.user(),
                            title: 'Perfil',
                            subtitle: 'Meus dados',
                            onTap: () {
                              _closeMenu();
                              print('Navegar para perfil - Em desenvolvimento');
                            },
                          ),
                          
                          SizedBox(height: 8),
                          
                          _buildMenuItem(
                            icon: PhosphorIcons.gear(),
                            title: 'Configurações',
                            subtitle: 'Preferências do app',
                            onTap: _openSettings,
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
                color: Theme.of(context).colorScheme.primaryContainer, // M3 container
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
            
            // Botão fechar com cor cinza clara
            IconButton(
              onPressed: _closeMenu,
              icon: Icon(
                PhosphorIcons.x(),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Cinza clarinho igual ao hover
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Botão logout com Material 3
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
            style: OutlinedButton.styleFrom( // M3 OutlinedButton style
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
        color: Theme.of(context).colorScheme.primaryContainer, // M3 container
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
        borderRadius: BorderRadius.circular(16), // M3 border radius
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
                  color: Theme.of(context).colorScheme.secondaryContainer, // M3 container
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSecondaryContainer, // M3 on-container
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
      child: FilledButton.tonalIcon( // M3 Filled Tonal - mais suave que o Filled
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
          backgroundColor: AppColors.papayaSensorial, // Cor Papaya Sensorial
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
      transitionDuration: Duration(milliseconds: 350), // M3 timing
      reverseTransitionDuration: Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}