import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/viewmodel/post_actions_viewmodel.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/utils/app_icons.dart';
import 'package:kafex/widgets/comments_bottom_sheet.dart';
import 'package:kafex/widgets/delete_confirmation_dialog.dart';
import 'package:kafex/ui/user_profile/widgets/user_profile_provider.dart';
import 'package:provider/provider.dart';

abstract class BasePostWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BasePostWidget({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
}

abstract class BasePostWidgetState<T extends BasePostWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _heartOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeartAnimation = false);
        _heartAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _triggerHeartAnimation() {
    setState(() => _showHeartAnimation = true);
    _heartAnimationController.forward();
  }

  void _toggleLike(PostActionsViewModel viewModel) {
    viewModel.toggleLike.execute();
    widget.onLike?.call();
  }

  void _navigateToUserProfile(String userName, String? avatarUrl) {
    print('🔍 Navegando para perfil de: $userName');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileProvider(
          userId: 'user_${userName.toLowerCase().replaceAll(' ', '_')}',
          userName: userName,
          userAvatar: avatarUrl,
        ),
      ),
    );
  }

  void _showPostOptionsModal(PostActionsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.moonAsh.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(AppIcons.edit, color: AppColors.carbon),
                title: Text(
                  'Editar',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.carbon,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
              ),
              ListTile(
                leading: Icon(AppIcons.delete, color: AppColors.spiced),
                title: Text(
                  'Excluir',
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.spiced,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(viewModel);
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(PostActionsViewModel viewModel) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Excluir publicação',
    );

    if (confirmed == true) {
      viewModel.deletePost.execute();
      widget.onDelete?.call();
      _showSuccessSnackBar('Publicação excluída com sucesso');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(AppIcons.checkCircle, color: AppColors.whiteWhite, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.papayaSensorial,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(AppIcons.warning, color: AppColors.whiteWhite, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.spiced,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _openCommentsModal(PostActionsViewModel viewModel) {
    widget.onComment?.call();
    showCommentsModal(context, postId: widget.post.id);
  }

  String _formatRelativeTime(DateTime postDate) {
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}a';
    }
  }

  Widget buildPostHeader(PostActionsViewModel viewModel) {
    // ✅ LOG ADICIONADO
    print('🏗️ buildPostHeader - Post ID: ${widget.post.id}, isOwnPost: ${viewModel.isOwnPost}');
    
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToUserProfile(
                widget.post.authorName,
                widget.post.authorAvatar != null &&
                        widget.post.authorAvatar!.startsWith('http')
                    ? widget.post.authorAvatar
                    : null,
              ),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.moonAsh.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.post.authorAvatar != null &&
                          widget.post.authorAvatar!.startsWith('http')
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.post.authorAvatar!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              AppIcons.user,
                              color: AppColors.grayScale2,
                              size: 24,
                            ),
                            errorWidget: (context, url, error) => Text(
                              widget.post.authorName.isNotEmpty
                                  ? widget.post.authorName[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.albertSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          widget.post.authorName.isNotEmpty
                              ? widget.post.authorName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatRelativeTime(widget.post.createdAt),
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // ✅ CORRIGIDO: Usa isOwnPost do viewModel diretamente
          if (viewModel.isOwnPost)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showPostOptionsModal(viewModel),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    AppIcons.dotsThreeVertical,
                    size: 24,
                    color: AppColors.carbon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPostMedia(PostActionsViewModel viewModel) {
    if (widget.post.imageUrl == null || widget.post.imageUrl!.isEmpty) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onDoubleTap: () {
        if (!viewModel.isLiked) {
          _toggleLike(viewModel);
          _triggerHeartAnimation();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: AppColors.moonAsh.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.papayaSensorial,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: AppColors.moonAsh.withOpacity(0.1),
                child: Icon(AppIcons.image, size: 48, color: AppColors.moonAsh),
              ),
            ),
          ),
          if (_showHeartAnimation)
            AnimatedBuilder(
              animation: _heartAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartScaleAnimation.value,
                  child: Opacity(
                    opacity: _heartOpacityAnimation.value,
                    child: Icon(
                      AppIcons.heartFill,
                      size: 100,
                      color: AppColors.whiteWhite,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget buildCustomActions(PostActionsViewModel viewModel) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          _buildActionButton(
            icon: viewModel.isLiked ? AppIcons.heartFill : AppIcons.heart,
            iconColor: viewModel.isLiked ? AppColors.spiced : AppColors.carbon,
            count: viewModel.likesCount,
            onTap: () => _toggleLike(viewModel),
            isActive: viewModel.isLiked,
          ),
          SizedBox(width: 4),
          _buildActionButton(
            icon: AppIcons.comment,
            iconColor: AppColors.carbon,
            count: viewModel.commentsCount,
            onTap: () => _openCommentsModal(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    int? count,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              if (count != null && count > 0) ...[
                SizedBox(width: 8),
                Text(
                  count.toString(),
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? buildAdditionalContent(PostActionsViewModel viewModel) => null;

  @override
  Widget build(BuildContext context) {
    return Consumer<PostActionsViewModel>(
      builder: (context, viewModel, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPostHeader(viewModel),
              buildPostMedia(viewModel),
              buildCustomActions(viewModel),
              if (buildAdditionalContent(viewModel) != null)
                buildAdditionalContent(viewModel)!,
            ],
          ),
        );
      },
    );
  }
}