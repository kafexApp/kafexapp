import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import 'package:kafex/config/app_routes.dart';
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
    await Navigator.pushNamed(
      context,
      AppRoutes.notifications,
    );
    _loadNotificationCount();
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.oatWhite,
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo ou botão de voltar
              if (widget.showBackButton)
                GestureDetector(
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
                          offset: const Offset(0, 2),
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
              else
                GestureDetector(
                  onTap: () => _navigateToHome(context),
                  child: SvgPicture.asset(
                    'assets/images/kafex_logo_positive.svg',
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
              
              // Botão de notificação
              GestureDetector(
                onTap: widget.onNotificationPressed ?? () => _navigateToNotifications(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
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