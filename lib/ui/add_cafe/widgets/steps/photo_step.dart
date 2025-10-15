import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
    // Detectar se é mobile web checando user agent ou largura da tela
    // Simplificado: considerar mobile se largura < 768px
    return false; // Por enquanto, sempre retorna false no web
  }

  Future<void> _selectImageFromSource(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      print('📸 Iniciando seleção de imagem...');
      print('📱 Plataforma: ${kIsWeb ? "Web" : Platform.operatingSystem}');
      print('🔍 Source: ${source == ImageSource.camera ? "Camera" : "Gallery"}');

      // Web não precisa de permissões
      if (kIsWeb) {
        print('🌐 Executando no Web, pulando verificação de permissão');
        await _pickImage(context, source);
        return;
      }

      // Android e iOS: verificar permissões
      Permission permission;
      
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else {
        // Para galeria, usar permissão específica por plataforma
        if (Platform.isAndroid) {
          // Android 13+ usa photos, versões antigas usam storage
          final androidInfo = await _getAndroidVersion();
          if (androidInfo >= 33) {
            permission = Permission.photos;
          } else {
            permission = Permission.storage;
          }
        } else {
          // iOS sempre usa photos
          permission = Permission.photos;
        }
      }

      print('🔐 Verificando permissão: ${permission.toString()}');

      // Verificar status atual
      final status = await permission.status;
      print('📊 Status atual: ${status.toString()}');

      if (status.isDenied) {
        print('❓ Permissão negada, solicitando...');
        final result = await permission.request();
        print('📊 Resultado da solicitação: ${result.toString()}');
        
        if (!result.isGranted) {
          print('❌ Permissão não concedida');
          
          if (result.isPermanentlyDenied) {
            _showPermissionDialog(context, source);
            return;
          }
          
          CustomToast.showError(
            context,
            message: 'Permissão necessária para acessar ${source == ImageSource.camera ? "a câmera" : "a galeria"}',
          );
          return;
        }
      } else if (status.isPermanentlyDenied) {
        print('⛔ Permissão permanentemente negada');
        _showPermissionDialog(context, source);
        return;
      }

      print('✅ Permissão concedida, selecionando imagem...');
      await _pickImage(context, source);

    } catch (e) {
      print('❌ Erro ao processar imagem: $e');
      CustomToast.showError(
        context,
        message: 'Erro ao selecionar foto. Tente novamente.',
      );
    }
  }

  Future<int> _getAndroidVersion() async {
    try {
      if (!Platform.isAndroid) return 0;
      // Retorna versão genérica para Android
      return 33; // Assumir Android 13+ por padrão
    } catch (e) {
      return 33;
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
      throw e;
    }
  }

  void _showPermissionDialog(BuildContext context, ImageSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Permissão necessária',
          style: GoogleFonts.albertSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Para ${source == ImageSource.camera ? "tirar fotos" : "acessar sua galeria"}, precisamos da sua permissão. '
          'Por favor, ative nas configurações do seu dispositivo.',
          style: GoogleFonts.albertSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.albertSans(
                color: AppColors.grayScale1,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'Abrir configurações',
              style: GoogleFonts.albertSans(
                color: AppColors.papayaSensorial,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No Web Desktop, esconder botão de câmera
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
            // Web Desktop: apenas galeria
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