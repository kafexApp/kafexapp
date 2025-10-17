// lib/ui/comments/widgets/comment_item.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../models/comment_models.dart';
import '../utils/comment_helpers.dart';

class CommentItem extends StatelessWidget {
  final CommentData comment;
  final bool isHighlighted;
  final VoidCallback onOptionsPressed;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.isHighlighted,
    required this.onOptionsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: isHighlighted ? EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: isHighlighted
          ? BoxDecoration(
              color: AppColors.papayaSensorial.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.papayaSensorial.withOpacity(0.3),
                width: 2,
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      CommentHelpers.formatTimestamp(comment.timestamp),
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: onOptionsPressed,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          AppIcons.dotsThreeVertical,
                          color: AppColors.grayScale2,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    if (comment.userAvatar != null && comment.userAvatar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          comment.userAvatar!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildAvatarFallback();
          },
        ),
      );
    }

    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    final initial = CommentHelpers.getInitial(comment.userName);
    final avatarColor = CommentHelpers.getAvatarColor(comment.userName);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }
}