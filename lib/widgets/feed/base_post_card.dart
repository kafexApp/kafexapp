import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';

abstract class BasePostCard extends StatefulWidget {
  final PostData post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BasePostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
}

abstract class BasePostCardState<T extends BasePostCard> extends State<T> {
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likesCount = widget.post.likes;
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
    widget.onLike?.call();
  }

  void navigateToUserProfile(String userName, String? avatarUrl) {
    Navigator.pushNamed(
      context,
      '/user-profile',
      arguments: {
        'userId': 'user_${userName.toLowerCase().replaceAll(' ', '_')}',
        'userName': userName,
        'userAvatar': avatarUrl,
      },
    );
  }

  void showPostOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                  color: AppColors.grayScale2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
                leading: Icon(
                  AppIcons.edit,
                  color: AppColors.papayaSensorial,
                  size: 24,
                ),
                title: Text(
                  'Editar',
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
                  widget.onDelete?.call();
                },
                leading: Icon(
                  AppIcons.delete,
                  color: AppColors.spiced,
                  size: 24,
                ),
                title: Text(
                  'Excluir',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.spiced,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget buildPostHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => navigateToUserProfile(
              widget.post.authorName,
              widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http') 
                ? widget.post.authorAvatar 
                : null,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: widget.post.authorAvatar!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return buildAvatarFallback();
                        },
                      ),
                    )
                  : buildAvatarFallback(),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => navigateToUserProfile(
                widget.post.authorName,
                widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http') 
                  ? widget.post.authorAvatar 
                  : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.authorName,
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    widget.post.date,
                    style: GoogleFonts.albertSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: showPostOptionsModal,
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                AppIcons.dotsThree,
                color: AppColors.grayScale2,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatarFallback() {
    final initial = widget.post.authorName.isNotEmpty 
        ? widget.post.authorName[0].toUpperCase() 
        : 'U';
    final colorIndex = widget.post.authorName.isNotEmpty 
        ? widget.post.authorName.codeUnitAt(0) % 5 
        : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: avatarColors[colorIndex].withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: avatarColors[colorIndex],
          ),
        ),
      ),
    );
  }

  Widget buildPostMedia() {
    // CORREÇÃO: Só mostra se tiver imagem válida (URL que começa com http)
    final hasValidImage = widget.post.imageUrl != null && 
                         widget.post.imageUrl!.isNotEmpty && 
                         widget.post.imageUrl!.startsWith('http');
    
    if (!hasValidImage) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onDoubleTap: () {
        if (!isLiked) {
          toggleLike();
        }
      },
      child: Container(
        width: double.infinity,
        height: 300,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.moonAsh,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: buildImageMedia(),
        ),
      ),
    );
  }

  Widget buildImageMedia() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Container(
          color: AppColors.moonAsh,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.papayaSensorial,
              ),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        // Se der erro, não mostra nada
        return SizedBox.shrink();
      },
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget buildLikesCounter() {
    if (likesCount <= 0) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        '$likesCount curtida${likesCount != 1 ? 's' : ''}',
        style: GoogleFonts.albertSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget buildPostContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.post.authorName} ',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: widget.post.content,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método abstrato que cada tipo de post implementará
  Widget buildCustomActions();

  // Método abstrato para elementos adicionais específicos
  Widget? buildAdditionalContent() => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPostHeader(),
          buildPostMedia(), // Só aparece se tiver imagem válida
          buildCustomActions(),
          buildLikesCounter(),
          buildPostContent(),
          if (buildAdditionalContent() != null) buildAdditionalContent()!,
        ],
      ),
    );
  }
}