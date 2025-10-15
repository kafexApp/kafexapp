// lib/widgets/cafe_evaluation_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../data/repositories/avaliacao_repository.dart';

class CafeEvaluationModal extends StatefulWidget {
  final String cafeName;
  final int cafeId;
  final String cafeRef;
  final VoidCallback? onEvaluationSubmitted;

  const CafeEvaluationModal({
    Key? key,
    required this.cafeName,
    required this.cafeId,
    required this.cafeRef,
    this.onEvaluationSubmitted,
  }) : super(key: key);

  @override
  State<CafeEvaluationModal> createState() => _CafeEvaluationModalState();
}

class _CafeEvaluationModalState extends State<CafeEvaluationModal> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AvaliacaoRepository _avaliacaoRepository = AvaliacaoRepositoryImpl();

  int _rating = 0;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      _showErrorSnackBar('Erro ao selecionar imagem');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print('Erro ao capturar foto: $e');
      _showErrorSnackBar('Erro ao capturar foto');
    }
  }

  void _showImageSourceDialog() {
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
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
                    Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pear,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitEvaluation() async {
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
      print('📝 Enviando avaliação:');
      print('  Cafeteria: ${widget.cafeName}');
      print('  ID: ${widget.cafeId}');
      print('  Ref: ${widget.cafeRef}');
      print('  Avaliação: $_rating grãos');
      print('  Texto: ${_reviewController.text}');
      print('  Imagem: ${_selectedImage?.path ?? 'Nenhuma'}');

      // Chama o repositório para criar a avaliação
      final result = await _avaliacaoRepository.createAvaliacao(
        cafeteriaId: widget.cafeId,
        cafeteriaRef: widget.cafeRef,
        nota: _rating.toDouble(),
        descricao: _reviewController.text.trim(),
        foto: _selectedImage,
      );

      if (result.isError) {
        throw result.asError.error;
      }

      final avaliacaoId = result.asOk.value;
      print('✅ Avaliação criada com ID: $avaliacaoId');

      // Fechar modal
      if (mounted) {
        Navigator.pop(context);

        // Chamar callback se fornecido
        widget.onEvaluationSubmitted?.call();

        // Mostrar sucesso
        _showSuccessSnackBar('Avaliação enviada com sucesso!');
      }
    } catch (e) {
      print('❌ Erro ao enviar avaliação: $e');
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
                          TextSpan(
                            text: 'Compartilhe como foi sua experiência na ',
                          ),
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

                    // Campo de texto para avaliação
                    Text(
                      'Conte mais sobre sua experiência',
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),

                    SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.moonAsh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 6,
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.carbon,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Qual café você experimentou? Conte mais detalhes sobre a sua experiência.',
                          hintStyle: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: AppColors.grayScale2,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Adicionar foto
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
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.moonAsh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.grayScale2,
                            width: 1,
                          ),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      width: double.infinity,
                                      height: double.infinity,
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
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.carbon
                                              .withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.whiteWhite,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppIcons.camera,
                                      color: AppColors.grayScale2,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Adicionar foto',
                                      style: GoogleFonts.albertSans(
                                        fontSize: 14,
                                        color: AppColors.grayScale2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Botão de enviar
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEvaluation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.velvetMerlot,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.whiteWhite,
                            ),
                          ),
                        )
                      : Text(
                          'Enviar avaliação',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteWhite,
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

/// Função helper para mostrar o modal de avaliação
void showCafeEvaluationModal(
  BuildContext context, {
  required String cafeName,
  required int cafeId,
  required String cafeRef,
  VoidCallback? onEvaluationSubmitted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => CafeEvaluationModal(
      cafeName: cafeName,
      cafeId: cafeId,
      cafeRef: cafeRef,
      onEvaluationSubmitted: onEvaluationSubmitted,
    ),
  );
}