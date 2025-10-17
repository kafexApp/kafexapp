// lib/ui/comments/widgets/comment_input.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isPosting;
  final VoidCallback onSend;
  final VoidCallback onChanged;
  final bool isEditMode;
  final VoidCallback? onCancelEdit;

  const CommentInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isPosting,
    required this.onSend,
    required this.onChanged,
    this.isEditMode = false,
    this.onCancelEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isEditMode 
            ? AppColors.papayaSensorial.withOpacity(0.05)
            : AppColors.whiteWhite,
        border: Border(
          top: BorderSide(
            color: isEditMode 
                ? AppColors.papayaSensorial.withOpacity(0.3)
                : AppColors.moonAsh,
            width: isEditMode ? 2 : 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditMode) ...[
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.papayaSensorial,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editando comentário',
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.papayaSensorial,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onCancelEdit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.albertSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayScale2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.oatWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: focusNode.hasFocus
                            ? AppColors.papayaSensorial.withOpacity(0.3)
                            : AppColors.moonAsh,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.carbon,
                      ),
                      decoration: InputDecoration(
                        hintText: isEditMode 
                            ? 'Edite seu comentário...'
                            : 'Escreva um comentário...',
                        hintStyle: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.grayScale2,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      onChanged: (value) => onChanged(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: controller.text.trim().isNotEmpty && !isPosting
                      ? onSend
                      : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: controller.text.trim().isNotEmpty && !isPosting
                          ? AppColors.papayaSensorial
                          : AppColors.grayScale2.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: isPosting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.whiteWhite,
                            ),
                          )
                        : Icon(
                            isEditMode ? Icons.check : AppIcons.paperPlaneTilt,
                            color: AppColors.whiteWhite,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}