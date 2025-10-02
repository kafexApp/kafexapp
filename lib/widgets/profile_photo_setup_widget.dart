// lib/widgets/profile_photo_setup_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_colors.dart';
import '../services/user_profile_service.dart';
import '../utils/user_manager.dart';
import 'custom_toast.dart';

class ProfilePhotoSetupWidget extends StatefulWidget {
  final VoidCallback? onPhotoUpdated;
  final bool showSetupPrompt;
  
  const ProfilePhotoSetupWidget({
    Key? key,
    this.onPhotoUpdated,
    this.showSetupPrompt = true,
  }) : super(key: key);

  @override
  _ProfilePhotoSetupWidgetState createState() => _ProfilePhotoSetupWidgetState();
}

class _ProfilePhotoSetupWidgetState extends State<ProfilePhotoSetupWidget> {
  bool _isLoading = false;
  bool _hasPhoto = false;

  @override
  void initState() {
    super.initState();
    _checkIfHasPhoto();
  }

  Future<void> _checkIfHasPhoto() async {
    final hasPhoto = await UserProfileService.hasProfilePhoto();
    if (mounted) {
      setState(() {
        _hasPhoto = hasPhoto;
      });
    }
  }

  Future<void> _selectAndUploadPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final success = await UserProfileService.updateUserProfilePhoto(image);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasPhoto = success;
          });

          if (success) {
            CustomToast.showSuccess(context, message: 'Foto de perfil atualizada!');
            widget.onPhotoUpdated?.call();
          } else {
            CustomToast.showError(context, message: 'Erro ao atualizar foto de perfil');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomToast.showError(context, message: 'Erro ao selecionar imagem');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se já tem foto e não deve mostrar prompt, não exibe nada
    if (_hasPhoto && !widget.showSetupPrompt) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grayScale4.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Ícone ou avatar atual
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _hasPhoto 
                ? _buildCurrentAvatar()
                : Icon(
                    PhosphorIcons.user,
                    size: 24,
                    color: AppColors.primaryColor,
                  ),
          ),
          
          const SizedBox(height: 12),
          
          // Título
          Text(
            _hasPhoto ? 'Atualizar foto de perfil' : 'Adicionar foto de perfil',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Descrição
          Text(
            _hasPhoto 
                ? 'Você pode alterar sua foto de perfil a qualquer momento'
                : 'Adicione uma foto para que outros usuários possam te reconhecer',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Botão
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _selectAndUploadPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasPhoto ? PhosphorIcons.camera : PhosphorIcons.plus,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasPhoto ? 'Alterar foto' : 'Adicionar foto',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentAvatar() {
    final userManager = UserManager.instance;
    final photoUrl = userManager.userPhotoUrl;
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar();
          },
        ),
      );
    }
    
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final userManager = UserManager.instance;
    final userName = userManager.userName;
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: GoogleFonts.albertSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}