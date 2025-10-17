// lib/ui/comments/dialogs/edit_comment_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';

class EditCommentDialog {
  static Future<String?> show(
    BuildContext context, {
    required String currentContent,
  }) async {
    final editController = TextEditingController(text: currentContent);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar comentário',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          content: TextField(
            controller: editController,
            maxLines: 3,
            autofocus: true,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.carbon,
            ),
            decoration: InputDecoration(
              hintText: 'Digite seu comentário...',
              hintStyle: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.moonAsh),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.papayaSensorial,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newContent = editController.text.trim();
                if (newContent.isNotEmpty) {
                  Navigator.of(context).pop(newContent);
                }
              },
              child: Text(
                'Salvar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}