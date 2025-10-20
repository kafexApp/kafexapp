// lib/widgets/custom_text_fields.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

// CAMPO DE TEXTO PADRÃO
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFocused = focusNode.hasFocus;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused 
              ? AppColors.papayaSensorial 
              : AppColors.oatWhite,
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
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: isFocused 
                ? AppColors.papayaSensorial 
                : AppColors.textSecondary,
            size: 22,
          ),
          hintText: hintText,
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
    );
  }
}

// CAMPO DE SENHA
class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const CustomPasswordField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isVisible,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFocused = focusNode.hasFocus;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused 
              ? AppColors.papayaSensorial 
              : AppColors.oatWhite,
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
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isFocused 
                ? AppColors.papayaSensorial 
                : AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          hintText: hintText,
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
    );
  }
}