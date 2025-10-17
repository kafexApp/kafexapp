// lib/ui/comments/utils/comment_helpers.dart

import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class CommentHelpers {
  /// Formata o timestamp para exibição (agora, 5min, 2h, 3d)
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
  }

  /// Retorna a cor do avatar baseada no nome do usuário
  static Color getAvatarColor(String userName) {
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];

    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    return avatarColors[colorIndex];
  }

  /// Retorna a inicial do nome do usuário
  static String getInitial(String userName) {
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }
}