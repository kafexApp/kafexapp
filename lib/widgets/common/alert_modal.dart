import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';

enum AlertType {
  warning,
  error,
  success,
  info,
}

class AlertModal {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    AlertType type = AlertType.warning,
    String? confirmText,
    String? cancelText,
    bool showCancelButton = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(type),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  if (showCancelButton) ...[
                    Expanded(
                      child: _buildCancelButton(
                        context: context,
                        text: cancelText ?? 'Cancelar',
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _buildConfirmButton(
                      context: context,
                      text: confirmText ?? 'Confirmar',
                      type: type,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildIcon(AlertType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AlertType.warning:
        icon = AppIcons.warning;
        color = AppColors.papayaSensorial;
        break;
      case AlertType.error:
        icon = AppIcons.warning;
        color = AppColors.spiced;
        break;
      case AlertType.success:
        icon = AppIcons.checkCircle;
        color = AppColors.papayaSensorial;
        break;
      case AlertType.info:
        icon = AppIcons.info;
        color = AppColors.carbon;
        break;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 32,
        color: color,
      ),
    );
  }

  static Widget _buildCancelButton({
    required BuildContext context,
    required String text,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(false),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.velvetMerlot,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: AppColors.velvetMerlot,
            width: 1.5,
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  static Widget _buildConfirmButton({
    required BuildContext context,
    required String text,
    required AlertType type,
  }) {
    Color backgroundColor;

    switch (type) {
      case AlertType.error:
        backgroundColor = AppColors.spiced;
        break;
      case AlertType.warning:
      case AlertType.success:
      case AlertType.info:
      default:
        backgroundColor = AppColors.papayaSensorial;
        break;
    }

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}