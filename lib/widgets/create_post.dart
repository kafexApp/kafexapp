// lib/widgets/create_post.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/user_manager.dart';
import './custom_buttons.dart';

class CreatePostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Abre o modal automaticamente quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCreatePostModal(context);
      // Remove o .then() porque showCreatePostModal retorna void
      Navigator.of(context).pop();
    });

    // Retorna uma tela transparente
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(),
    );
  }
}

class CreatePostModal extends StatefulWidget {
  @override
  _CreatePostModalState createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedMedia;
  bool _isVideo = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
          // Header do modal (apenas título e botão fechar)
          _buildHeader(),
          
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
                  _buildDescriptionField(),
                  
                  SizedBox(height: 20),
                  
                  // Área de mídia
                  _buildMediaSection(),
                  
                  SizedBox(height: 20),
                  
                  // Campo de link
                  _buildLinkField(),
                  
                  SizedBox(height: 20),
                  
                  // Botões de ação (apenas na parte inferior)
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.moonAsh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _descriptionController,
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

  Widget _buildMediaSection() {
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
        
        if (_selectedMedia != null) ...[
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
                  child: _isVideo
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.carbon,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  size: 48,
                                  color: AppColors.whiteWhite,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Vídeo selecionado',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    color: AppColors.whiteWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.file(
                          _selectedMedia!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                
                // Botão remover
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMedia = null;
                        _isVideo = false;
                      });
                    },
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
                icon: Icons.photo_library,
                label: 'Galeria',
                onTap: () => _pickMedia(ImageSource.gallery),
              ),
            ),
            
            SizedBox(width: 12),
            
            Expanded(
              child: _buildMediaButton(
                icon: Icons.camera_alt,
                label: 'Câmera',
                onTap: () => _pickMedia(ImageSource.camera),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
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

  Widget _buildLinkField() {
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
            controller: _linkController,
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
              suffixIcon: _linkController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.open_in_new,
                        color: AppColors.papayaSensorial,
                        size: 20,
                      ),
                      onPressed: _testLink,
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botão Cancelar usando CustomOutlineButton
        Expanded(
          child: CustomOutlineButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        
        SizedBox(width: 16),
        
        // Botão Publicar usando PrimaryButton
        Expanded(
          child: PrimaryButton(
            text: 'Publicar',
            onPressed: _publishPost,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      // Mostrar opções de foto ou vídeo
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
                  leading: Icon(Icons.photo, color: AppColors.papayaSensorial),
                  title: Text('Foto'),
                  onTap: () => Navigator.of(context).pop('photo'),
                ),
                ListTile(
                  leading: Icon(Icons.videocam, color: AppColors.papayaSensorial),
                  title: Text('Vídeo'),
                  onTap: () => Navigator.of(context).pop('video'),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      if (result != null) {
        XFile? pickedFile;
        
        if (result == 'photo') {
          pickedFile = await _picker.pickImage(source: source);
          _isVideo = false;
        } else {
          pickedFile = await _picker.pickVideo(source: source);
          _isVideo = true;
        }

        if (pickedFile != null) {
          setState(() {
            _selectedMedia = File(pickedFile!.path);
          });
        }
      }
    } catch (e) {
      print('Erro ao selecionar mídia: $e');
      _showCustomToast('Erro ao selecionar mídia');
    }
  }

  Future<void> _testLink() async {
    final url = _linkController.text.trim();
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Link inválido')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir link')),
        );
      }
    }
  }

  void _showCustomToast(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_rounded : Icons.check_circle_rounded,
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
        backgroundColor: isError ? AppColors.spiced : AppColors.papayaSensorial,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _publishPost() async {
    if (_descriptionController.text.trim().isEmpty && _selectedMedia == null) {
      _showCustomToast('Adicione uma descrição ou mídia para continuar');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular publicação
      await Future.delayed(Duration(seconds: 2));
      
      print('Post publicado:');
      print('Descrição: ${_descriptionController.text}');
      print('Mídia: ${_selectedMedia?.path ?? 'Nenhuma'}');
      print('Vídeo: $_isVideo');
      print('Link: ${_linkController.text}');
      
      Navigator.of(context).pop();
      
      _showCustomToast('Post publicado com sucesso!', isError: false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar post')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}

// Função helper para mostrar o modal
void showCreatePostModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CreatePostModal(),
  );
}