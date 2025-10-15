import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../ui/notifications/widgets/notifications_provider.dart';
import '../ui/home/widgets/home_screen_provider.dart';
import '../services/notifications_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    this.onNotificationPressed,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  /// Carrega a contagem de notificações não lidas
  Future<void> _loadNotificationCount() async {
    try {
      final count = await NotificationsService.getUnreadNotificationsCount();
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar contagem de notificações: $e');
    }
  }

  void _navigateToNotifications(BuildContext context) async {
    // Navega para a tela de notificações
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsProvider(),
      ),
    );
    
    // Quando voltar, atualiza a contagem
    _loadNotificationCount();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreenProvider()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.oatWhite,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.showBackButton
                  ? GestureDetector(
                      onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.whiteWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          AppIcons.back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _navigateToHome(context),
                      child: SvgPicture.asset(
                        'assets/images/kafex_logo_positive.svg',
                        width: 160,
                        height: 46,
                      ),
                    ),

              GestureDetector(
                onTap: widget.onNotificationPressed ?? () => _navigateToNotifications(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        AppIcons.notification,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                      
                      if (_notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            constraints: BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppColors.papayaSensorial,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: AppColors.oatWhite,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _notificationCount > 99 ? '99+' : _notificationCount.toString(),
                                style: TextStyle(
                                  color: AppColors.whiteWhite,
                                  fontSize: _notificationCount > 99 ? 8 : 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Albert Sans',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}