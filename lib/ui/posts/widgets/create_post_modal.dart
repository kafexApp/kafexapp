// lib/ui/posts/widgets/create_post_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/user_manager.dart';
import '../../../widgets/custom_buttons.dart';
import '../viewmodel/create_post_viewmodel.dart';

class CreatePostModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header do modal
              _buildHeader(context),
              
              // Conteúdo do modal
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info do usuário
                      _buildUserInfo(),
                      
                      SizedBox(height: 20),
                      
                      // Campo de descrição
                      _buildDescriptionField(viewModel),
                      
                      SizedBox(height: 20),
                      
                      // Área de mídia
                      _buildMediaSection(context, viewModel),
                      
                      SizedBox(height: 20),
                      
                      // Campo de link
                      _buildLinkField(viewModel),
                      
                      SizedBox(height: 20),
                      
                      // Botões de ação
                      _buildActionButtons(context, viewModel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.moonAsh,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Título "Criar Post" à esquerda
          Expanded(
            child: Text(
              'Criar post',
              style: GoogleFonts.albertSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Botão fechar à direita
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.close,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final userManager = UserManager.instance;
    final userName = userManager.userName;
    final userPhotoUrl = userManager.userPhotoUrl;

    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.papayaSensorial.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.papayaSensorial.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: userPhotoUrl != null
              ? ClipOval(
                  child: Image.network(
                    userPhotoUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildUserAvatar(userName);
                    },
                  ),
                )
              : _buildUserAvatar(userName),
        ),
        
        SizedBox(width: 12),
        
        // Nome do usuário
        Text(
          userName,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String userName) {
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.carbon,
      AppColors.grayScale2,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(CreatePostViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.moonAsh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: viewModel.descriptionController,
        maxLines: 6,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.carbon,
        ),
        decoration: InputDecoration(
          hintText: 'Compartilhe sua experiência com café...',
          hintStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, CreatePostViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adicionar mídia',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: 12),
        
        if (viewModel.selectedMediaFile != null) ...[
          // Preview da mídia selecionada
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.moonAsh,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.papayaSensorial.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            viewModel.isVideo ? AppIcons.video : AppIcons.image,
                            size: 48,
                            color: AppColors.papayaSensorial,
                          ),
                          SizedBox(height: 8),
                          Text(
                            viewModel.isVideo ? 'Vídeo selecionado' : 'Imagem selecionada',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.papayaSensorial,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Upload temporariamente indisponível',
                            style: GoogleFonts.albertSans(
                              fontSize: 12,
                              color: AppColors.grayScale2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Botão remover
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: viewModel.removeMedia,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.close,
                        color: AppColors.whiteWhite,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
        ],
        
        // Botões de seleção de mídia
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                icon: AppIcons.images,
                label: 'Galeria',
                onTap: () => _showMediaSourceDialog(context, viewModel, ImageSource.gallery),
              ),
            ),
            
            SizedBox(width: 12),
            
            Expanded(
              child: _buildMediaButton(
                icon: AppIcons.camera,
                label: 'Câmera',
                onTap: () => _showMediaSourceDialog(context, viewModel, ImageSource.camera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.papayaSensorial.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.papayaSensorial.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.papayaSensorial,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.papayaSensorial,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkField(CreatePostViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link externo (opcional)',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.moonAsh.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: viewModel.linkController,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.carbon,
            ),
            decoration: InputDecoration(
              hintText: 'https://exemplo.com',
              hintStyle: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: EdgeInsets.all(16),
              suffixIcon: viewModel.hasLink
                  ? IconButton(
                      icon: Icon(
                        AppIcons.link,
                        color: AppColors.papayaSensorial,
                        size: 20,
                      ),
                      onPressed: () => _testLink(viewModel.linkController.text),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, CreatePostViewModel viewModel) {
    return Row(
      children: [
        // Botão Cancelar
        Expanded(
          child: CustomOutlineButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
        SizedBox(width: 16),
        
        // Botão Publicar
        Expanded(
          child: PrimaryButton(
            text: 'Publicar',
            onPressed: () => _handlePublish(context, viewModel),
            isLoading: viewModel.isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _showMediaSourceDialog(
    BuildContext context, 
    CreatePostViewModel viewModel, 
    ImageSource source
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(AppIcons.image, color: AppColors.papayaSensorial),
                title: Text('Foto'),
                onTap: () => Navigator.of(context).pop('photo'),
              ),
              ListTile(
                leading: Icon(AppIcons.video, color: AppColors.papayaSensorial),
                title: Text('Vídeo'),
                onTap: () => Navigator.of(context).pop('video'),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result == 'photo') {
      await viewModel.pickMediaFromGallery();
    } else if (result == 'video') {
      await viewModel.pickMediaFromCamera();
    }
  }

  Future<void> _testLink(String url) async {
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        // Link inválido - ViewModel já trata isso
      }
    }
  }

  Future<void> _handlePublish(
    BuildContext context, 
    CreatePostViewModel viewModel
  ) async {
    final success = await viewModel.publishPost();
    
    if (success) {
      Navigator.of(context).pop();
      _showSuccessToast(context);
    } else if (viewModel.errorMessage != null) {
      _showErrorToast(context, viewModel.errorMessage!);
    }
  }

  void _showSuccessToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              AppIcons.checkCircle,
              color: AppColors.whiteWhite,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Post publicado com sucesso!',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              AppIcons.warning,
              color: AppColors.whiteWhite,
              size: 20,
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }
}