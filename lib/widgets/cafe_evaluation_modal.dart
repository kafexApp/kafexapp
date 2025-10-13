import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';

void showCafeEvaluationModal(
  BuildContext context, {
  required String cafeName,
  required String cafeId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CafeEvaluationModal(
      cafeName: cafeName,
      cafeId: cafeId,
    ),
  );
}

class CafeEvaluationModal extends StatefulWidget {
  final String cafeName;
  final String cafeId;

  const CafeEvaluationModal({
    Key? key,
    required this.cafeName,
    required this.cafeId,
  }) : super(key: key);

  @override
  State<CafeEvaluationModal> createState() => _CafeEvaluationModalState();
}

class _CafeEvaluationModalState extends State<CafeEvaluationModal> {
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _reviewFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  
  double _rating = 0;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reviewFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewFocusNode.dispose();
    super.dispose();
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating.toDouble();
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem da galeria: $e');
      _showErrorSnackBar('Erro ao selecionar imagem');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Erro ao capturar foto: $e');
      _showErrorSnackBar('Erro ao capturar foto');
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayScale2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Selecionar foto',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Opção Câmera
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.moonAsh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.camera,
                              color: AppColors.carbon,
                              size: 24,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Tirar foto',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.carbon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Opção Galeria
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.moonAsh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.image,
                              color: AppColors.carbon,
                              size: 24,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Escolher da galeria',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.carbon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.spiced,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitEvaluation() async {
    // Validações
    if (_rating == 0) {
      _showErrorSnackBar('Por favor, selecione uma avaliação');
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, escreva sua avaliação');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implementar envio da avaliação
      print('Enviando avaliação:');
      print('Cafeteria: ${widget.cafeName}');
      print('ID: ${widget.cafeId}');
      print('Avaliação: $_rating');
      print('Texto: ${_reviewController.text}');
      print('Imagem: ${_selectedImage?.path ?? 'Nenhuma'}');

      // Simular delay de envio
      await Future.delayed(Duration(seconds: 2));

      // Fechar modal
      if (mounted) {
        Navigator.pop(context);
        
        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: AppColors.pear,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Erro ao enviar avaliação: $e');
      _showErrorSnackBar('Erro ao enviar avaliação. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _reviewFocusNode.hasFocus;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle visual
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayScale2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Avaliar cafeteria',
                      style: GoogleFonts.albertSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      AppIcons.close,
                      color: AppColors.grayScale2,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texto introdutório
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.carbon,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'Compartilhe como foi sua experiência na '),
                          TextSpan(
                            text: widget.cafeName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Sistema de avaliação com grãos
                    Text(
                      'Como você avalia a cafeteria?',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => _setRating(index + 1),
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            child: SvgPicture.asset(
                              'assets/images/grain_note.svg',
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                index < _rating
                                  ? AppColors.papayaSensorial
                                  : AppColors.grayScale2,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Campo de texto para avaliação com design atualizado
                    Text(
                      'Conte mais sobre sua experiência',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.whiteWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFocused 
                              ? AppColors.papayaSensorial 
                              : AppColors.grayScale2.withOpacity(0.3),
                          width: isFocused ? 2 : 1,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.papayaSensorial.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: TextField(
                        controller: _reviewController,
                        focusNode: _reviewFocusNode,
                        maxLines: 6,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Qual café você experimentou? Conte mais detalhes sobre a sua experiência.',
                          hintStyle: GoogleFonts.albertSans(
                            fontSize: 16,
                            color: AppColors.textSecondary.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Seleção de foto
                    Text(
                      'Adicionar foto (opcional)',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        width: double.infinity,
                        height: _selectedImage != null ? 200 : 120,
                        decoration: BoxDecoration(
                          color: AppColors.moonAsh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.grayScale2.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.carbon.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        AppIcons.close,
                                        color: AppColors.whiteWhite,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  AppIcons.camera,
                                  color: AppColors.grayScale1,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Adicionar foto',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    color: AppColors.grayScale1,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Botão de envio
            Padding(
              padding: EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _isSubmitting ? null : _submitEvaluation,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isSubmitting 
                      ? AppColors.grayScale2 
                      : AppColors.velvetMerlot,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isSubmitting
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.whiteWhite,
                          ),
                        )
                      : Text(
                          'Enviar avaliação',
                          style: GoogleFonts.albertSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.papayaSensorial,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}