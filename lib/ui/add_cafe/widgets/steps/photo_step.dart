import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../../../widgets/custom_toast.dart';
import '../../viewmodel/add_cafe_viewmodel.dart';
import '../components/info_banner.dart';

class PhotoStep extends StatelessWidget {
  final AddCafeViewModel viewModel;
  final ImagePicker imagePicker;

  const PhotoStep({
    Key? key,
    required this.viewModel,
    required this.imagePicker,
  }) : super(key: key);

  bool _isMobileWeb() {
    if (!kIsWeb) return false;
    return false;
  }

  Future<void> _selectImageFromSource(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      print('📸 Iniciando seleção de imagem...');
      print('📱 Plataforma: ${kIsWeb ? "Web" : Platform.operatingSystem}');
      print('🔍 Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');

      // O image_picker gerencia as permissões automaticamente
      await _pickImage(context, source);

    } catch (e) {
      print('❌ Erro ao processar imagem: $e');
      CustomToast.showError(
        context,
        message: 'Erro ao selecionar foto. Tente novamente.',
      );
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      print('🖼️ Abrindo picker de imagem...');
      
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('✅ Imagem selecionada: ${pickedFile.path}');
        print('📏 Tamanho: ${await pickedFile.length()} bytes');
        
        viewModel.setCustomPhoto(pickedFile);

        CustomToast.showSuccess(
          context,
          message: source == ImageSource.camera
              ? 'Foto capturada com sucesso!'
              : 'Foto selecionada com sucesso!',
        );
      } else {
        print('⚠️ Nenhuma imagem foi selecionada');
      }
    } catch (e) {
      print('❌ Erro no picker: $e');
      
      // Verifica se é erro de permissão
      if (e.toString().contains('photo') || 
          e.toString().contains('camera') ||
          e.toString().contains('permission')) {
        CustomToast.showError(
          context,
          message: 'Permissão necessária. Ative nas configurações do seu dispositivo.',
        );
      } else {
        throw e;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCameraButton = !kIsWeb || _isMobileWeb();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 10),
          InfoBanner(
            title: 'Adicione uma foto (opcional)',
            subtitle:
                'Ao incluir uma foto você ajuda nossos usuários a reconhecerem o local com mais facilidade.',
            height: 160,
          ),
          if (viewModel.customPhoto != null) ...[
            SizedBox(height: 20),
            _buildPhotoPreview(),
            SizedBox(height: 20),
          ] else
            SizedBox(height: 20),
          if (showCameraButton)
            Row(
              children: [
                Expanded(
                  child: _PhotoActionButton(
                    icon: AppIcons.camera,
                    title: 'Tirar foto',
                    onTap: () => _selectImageFromSource(context, ImageSource.camera),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _PhotoActionButton(
                    icon: AppIcons.image,
                    title: 'Galeria',
                    onTap: () => _selectImageFromSource(context, ImageSource.gallery),
                  ),
                ),
              ],
            )
          else
            _PhotoActionButton(
              icon: AppIcons.image,
              title: 'Selecionar foto',
              onTap: () => _selectImageFromSource(context, ImageSource.gallery),
            ),
          if (viewModel.customPhoto != null) ...[
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => viewModel.removeCustomPhoto(),
                icon: Icon(AppIcons.delete, size: 18, color: Colors.red),
                label: Text(
                  'Remover foto',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: kIsWeb
            ? Image.network(
                viewModel.customPhoto!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildEmptyPhotoPlaceholder();
                },
              )
            : Image.file(
                File(viewModel.customPhoto!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildEmptyPhotoPlaceholder();
                },
              ),
      ),
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.image,
            size: 40,
            color: AppColors.grayScale2,
          ),
          SizedBox(height: 8),
          Text(
            'Nenhuma foto selecionada',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PhotoActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.papayaSensorial.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}