import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../comments_bottom_sheet.dart';

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

abstract class BasePostCardState<T extends BasePostCard> extends State<T> 
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  int likesCount = 0;

  // Animação do coração
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likesCount = widget.post.likes;
    
    print('BASE POST CARD INIT - Iniciado!');
    
    // Configurar animação do coração
    _heartAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_heartAnimationController);
    
    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0)
            .chain(CurveTween(curve: Curves.linear)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_heartAnimationController);
    
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showHeartAnimation = false;
          });
          _heartAnimationController.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void toggleLike() {
    print('TOGGLE LIKE - Estado antes: isLiked=$isLiked, likesCount=$likesCount');
    
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
    
    print('TOGGLE LIKE - Estado depois: isLiked=$isLiked, likesCount=$likesCount');
    widget.onLike?.call();
  }

  void _triggerHeartAnimation() {
    print('TRIGGER HEART ANIMATION - Iniciando...');
    
    if (mounted) {
      setState(() {
        _showHeartAnimation = true;
      });
      print('TRIGGER HEART ANIMATION - _showHeartAnimation: $_showHeartAnimation');
      _heartAnimationController.forward(from: 0.0);
    }
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
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle do modal - Material 3 style
              Container(
                margin: EdgeInsets.only(top: 16, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayScale2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Opção Editar - Material 3 style
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEdit?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.papayaSensorial.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            AppIcons.edit,
                            color: AppColors.papayaSensorial,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Editar',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Divider sutil
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 1,
                color: AppColors.moonAsh.withOpacity(0.3),
              ),
              
              // Opção Excluir - Material 3 style
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.spiced.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            AppIcons.delete,
                            color: AppColors.spiced,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Excluir',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.spiced,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget buildPostHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Avatar clicável - Material 3 style
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => navigateToUserProfile(
                widget.post.authorName,
                widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http') 
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
                  child: widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.authorAvatar!,
                          width: 44,
                          height: 44,
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
          ),
          
          SizedBox(width: 12),
          
          // Informações do usuário - Material 3 style
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => navigateToUserProfile(
                  widget.post.authorName,
                  widget.post.authorAvatar != null && widget.post.authorAvatar!.startsWith('http') 
                    ? widget.post.authorAvatar 
                    : null,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.post.date,
                        style: GoogleFonts.albertSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Menu de opções - Material 3 style
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: showPostOptionsModal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Icon(
                  AppIcons.dotsThree,
                  color: AppColors.grayScale2,
                  size: 24,
                ),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: avatarColors[colorIndex].withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: avatarColors[colorIndex],
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget buildPostMedia() {
    final hasValidImage = widget.post.imageUrl != null && 
                         widget.post.imageUrl!.isNotEmpty && 
                         widget.post.imageUrl!.startsWith('http');
    
    print('BUILD POST MEDIA - hasValidImage: $hasValidImage');
    print('BUILD POST MEDIA - imageUrl: ${widget.post.imageUrl}');
    
    if (!hasValidImage) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onDoubleTap: () {
            print('DUPLO CLIQUE DETECTADO NA IMAGEM!');
            toggleLike();
            _triggerHeartAnimation();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.moonAsh.withOpacity(0.1),
            ),
            child: Stack(
              children: [
                // Imagem
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: buildImageMedia(),
                ),
                
                // Animação do coração
                if (_showHeartAnimation)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _heartAnimationController,
                        builder: (context, child) {
                          print('ANIMANDO CORAÇÃO - scale: ${_heartScaleAnimation.value}, opacity: ${_heartOpacityAnimation.value}');
                          return Transform.scale(
                            scale: _heartScaleAnimation.value,
                            child: Opacity(
                              opacity: _heartOpacityAnimation.value,
                              child: Icon(
                                AppIcons.heartFill,
                                size: 100,
                                color: AppColors.whiteWhite,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImageMedia() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 300,
      placeholder: (context, url) {
        return Container(
          color: AppColors.moonAsh.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.papayaSensorial,
              ),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
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
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Text(
        '$likesCount curtida${likesCount != 1 ? 's' : ''}',
        style: GoogleFonts.albertSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget buildPostContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.post.authorName} ',
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
            TextSpan(
              text: widget.post.content,
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary.withOpacity(0.85),
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método padrão para ações - pode ser sobrescrito se necessário
  Widget buildCustomActions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Botão Like - Material 3 Filled Tonal style
          buildActionButton(
            icon: isLiked ? AppIcons.heartFill : AppIcons.heart,
            iconColor: isLiked ? AppColors.spiced : AppColors.carbon,
            count: likesCount,
            onTap: toggleLike,
            isActive: isLiked,
          ),
          
          SizedBox(width: 12),
          
          // Botão Comentário - Material 3 Filled Tonal style  
          buildActionButton(
            icon: AppIcons.comment,
            iconColor: AppColors.carbon,
            count: widget.post.comments,
            onTap: _openCommentsModal,
          ),
          
          Spacer(),
          
          // Botão Share - Material 3 Filled Tonal style
          buildActionButton(
            icon: AppIcons.share,
            iconColor: AppColors.carbon,
            onTap: _handleShare,
          ),
        ],
      ),
    );
  }

  // Método auxiliar para criar botões de ação padronizados
  Widget buildActionButton({
    required IconData icon,
    required Color iconColor,
    int? count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
              ? iconColor.withOpacity(0.08)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive 
                ? iconColor.withOpacity(0.2)
                : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
              if (count != null && count > 0) ...[
                SizedBox(width: 6),
                Text(
                  '$count',
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares para ações
  void _openCommentsModal() {
    widget.onComment?.call();
    
    showCommentsModal(
      context,
      postId: widget.post.id,
      comments: [],
      onCommentAdded: (newComment) {
        print('Novo comentário adicionado: $newComment');
      },
    );
  }

  void _handleShare() {
    print('Compartilhar post: ${widget.post.id}');
    // Implementar funcionalidade de compartilhamento
  }

  void _handleBookmark() {
    print('Salvar post: ${widget.post.id}');
    // Implementar funcionalidade de bookmark
  }

  // Método abstrato para elementos adicionais específicos
  Widget? buildAdditionalContent() => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          buildPostHeader(),
          buildPostMedia(),
          buildCustomActions(),
          buildLikesCounter(),
          buildPostContent(),
          if (buildAdditionalContent() != null) buildAdditionalContent()!,
        ],
      ),
    );
  }
}