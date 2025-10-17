// lib/ui/comments/widgets/comment_options_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../models/comment_models.dart';

class CommentOptionsModal extends StatelessWidget {
  final CommentData comment;
  final bool isOwnComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const CommentOptionsModal({
    Key? key,
    required this.comment,
    required this.isOwnComment,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required CommentData comment,
    required bool isOwnComment,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onReport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CommentOptionsModal(
          comment: comment,
          isOwnComment: isOwnComment,
          onEdit: onEdit,
          onDelete: onDelete,
          onReport: onReport,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayScale2.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          if (isOwnComment) ...[
            ListTile(
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
              leading: Icon(
                AppIcons.edit,
                color: AppColors.papayaSensorial,
                size: 24,
              ),
              title: Text(
                'Editar comentário',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.moonAsh,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
              leading: Icon(
                AppIcons.delete,
                color: AppColors.spiced,
                size: 24,
              ),
              title: Text(
                'Excluir comentário',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.spiced,
                ),
              ),
            ),
          ] else ...[
            ListTile(
              onTap: () {
                Navigator.pop(context);
                onReport();
              },
              leading: Icon(
                AppIcons.warning,
                color: AppColors.spiced,
                size: 24,
              ),
              title: Text(
                'Reportar comentário',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          SizedBox(height: 20),
        ],
      ),
    );
  }
}