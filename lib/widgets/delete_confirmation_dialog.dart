import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';

class DeleteConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                AppIcons.warning,
                color: AppColors.spiced,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Excluir post',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.spiced,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação não pode ser desfeita.',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tem certeza que deseja excluir este post?',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.spiced,
              ),
              child: Text(
                'Excluir',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.spiced,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}