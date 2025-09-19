import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
              // Botão voltar (se necessário) ou logo
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
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/kafex_logo_positive.svg',
                      width: 140,
                      height: 40,
                    ),

              // Ícone de notificação
              GestureDetector(
                onTap: onNotificationPressed ?? () {
                  print('Abrir notificações');
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/images/notification.svg',
                    width: 24,
                    height: 24,
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