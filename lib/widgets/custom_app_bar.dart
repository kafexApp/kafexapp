import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../screens/notifications_screen.dart';
import '../ui/home/widgets/home_screen_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final int notificationCount;

  const CustomAppBar({
    Key? key,
    this.onNotificationPressed,
    this.showBackButton = false,
    this.onBackPressed,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(80);

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(),
      ),
    );
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
              showBackButton
                  ? GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
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
                        width: 140,
                        height: 40,
                      ),
                    ),

              GestureDetector(
                onTap: onNotificationPressed ?? () => _navigateToNotifications(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        notificationCount > 0 
                          ? AppIcons.notificationFill 
                          : AppIcons.notification,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                      
                      if (notificationCount > 0)
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
                                notificationCount > 99 ? '99+' : notificationCount.toString(),
                                style: TextStyle(
                                  color: AppColors.whiteWhite,
                                  fontSize: notificationCount > 99 ? 8 : 10,
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