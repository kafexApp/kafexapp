// lib/widgets/common/user_avatar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/avatar_service.dart';
import '../../utils/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double size;
  final String? overrideName;
  final String? overridePhotoUrl;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    Key? key,
    this.user,
    this.size = 84,
    this.overrideName,
    this.overridePhotoUrl,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final photoUrl = overridePhotoUrl ?? user?.photoURL;
    final displayName = overrideName ?? user?.displayName;
    final optimizedUrl = AvatarService.optimizePhotoUrl(photoUrl, size: size.toInt());

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.whiteWhite,
                width: borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        image: optimizedUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(optimizedUrl),
                fit: BoxFit.contain, // MUDANÇA AQUI: de cover para contain
                onError: (exception, stackTrace) {
                  print('Erro ao carregar avatar: $exception');
                },
              )
            : null,
      ),
      child: optimizedUrl == null ? _buildInitialsAvatar(displayName) : null,
    );
  }

  Widget _buildInitialsAvatar(String? displayName) {
    final initials = AvatarService.generateInitials(displayName);
    final backgroundColor = AvatarService.generateAvatarColor(displayName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.albertSans(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}