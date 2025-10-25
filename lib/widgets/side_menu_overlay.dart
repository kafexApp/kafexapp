import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/user_manager.dart';
import '../services/auth_service.dart';
import '../ui/cafe_explorer/widgets/cafe_explorer_provider.dart';
import '../ui/notifications/widgets/notifications_provider.dart';
import '../ui/user_profile/widgets/user_profile_provider.dart';
import '../ui/profile_settings/widgets/profile_settings_provider.dart';
import '../screens/welcome_screen.dart';
import '../ui/posts/widgets/create_post_screen.dart';
import '../ui/home/widgets/home_screen_provider.dart';
import '../ui/subscription/widgets/subscription_screen.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
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
    
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _closeMenu() async {
    await _animationController.reverse();
    widget.onClose();
  }

  Future<void> _navigateToScreen(Widget screen) async {
    await _closeMenu();
    await Future.delayed(Duration(milliseconds: 50));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  Future<void> _pushToScreen(Widget screen) async {
    await _closeMenu();
    await Future.delayed(Duration(milliseconds: 50));
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _closeMenu();
    await Future.delayed(Duration(milliseconds: 200));
    
    if (!mounted) return;
    
    try {
      UserManager.instance.clearUserData();
      await _authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
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
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: _buildUserHeader(),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _logout(context),
                              icon: Icon(PhosphorIcons.signOut(), size: 18),
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
                          
                          SizedBox(height: 16),
                          
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.95,
                            children: [
                              _buildGridItem(PhosphorIcons.house(), 'Início', 
                                () => _navigateToScreen(HomeScreenProvider())),
                              _buildGridItem(PhosphorIcons.coffee(), 'Cafeterias', 
                                () => _navigateToScreen(CafeExplorerProvider())),
                              _buildGridItem(PhosphorIcons.bell(), 'Notificações', 
                                () => _pushToScreen(NotificationsProvider())),
                              _buildGridItem(PhosphorIcons.user(), 'Perfil', () {
                                final um = UserManager.instance;
                                _pushToScreen(UserProfileProvider(
                                  userId: um.userUid,
                                  userName: um.userName,
                                  userAvatar: um.userPhotoUrl,
                                ));
                              }),
                              _buildGridItem(PhosphorIcons.gear(), 'Config.', 
                                () => _pushToScreen(ProfileSettingsProvider())),
                              _buildGridItemWithImagePulse('assets/images/icon-clube-da-xicara.png', 'Nosso clube', 
                                () => _pushToScreen(const SubscriptionScreen())),
                            ],
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildCreatePostButton(),
                          
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
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
    final um = UserManager.instance;
    final photoUrl = um.userPhotoUrl;
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: photoUrl != null && photoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(photoUrl, width: 64, height: 64, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(um.userName)))
              : _buildDefaultAvatar(um.userName),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(um.userName, style: GoogleFonts.albertSans(
                fontSize: 20, fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Text(um.userEmail, style: GoogleFonts.albertSans(
                fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          onPressed: _closeMenu,
          icon: Icon(PhosphorIcons.x(), color: Theme.of(context).colorScheme.onSurfaceVariant),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.oatWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.albertSans(fontSize: 24, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimaryContainer)),
    );
  }

  Widget _buildGridItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.moonAsh,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, 
                  color: AppColors.carbon, size: 22),
              ),
              SizedBox(height: 8),
              Text(title, style: GoogleFonts.albertSans(fontSize: 12, fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItemWithImagePulse(String imagePath, String title, VoidCallback onTap) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pear,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 53,
                  height: 53,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8),
                Text(title, style: GoogleFonts.albertSans(fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.carbon),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
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
          if (context.mounted) showCreatePostModal(context);
        },
        icon: Icon(PhosphorIcons.plus(), size: 20),
        label: Text('Criar post', style: GoogleFonts.albertSans(
          fontSize: 16, fontWeight: FontWeight.w500)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.papayaSensorial,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      pageBuilder: (context, animation, secondaryAnimation) => 
        SideMenuOverlay(onClose: () => Navigator.of(context).pop()),
      transitionDuration: Duration(milliseconds: 350),
      reverseTransitionDuration: Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    ),
  );
}