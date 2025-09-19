import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

// BOTÃO PRIMÁRIO - Papaya Sensorial com texto Velvet Merlot
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.papayaSensorial,
          foregroundColor: AppColors.velvetMerlot,
          disabledBackgroundColor: AppColors.grayScale2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetMerlot),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}

// BOTÃO SECUNDÁRIO - Velvet Merlot com texto Papaya
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.velvetMerlot,
          foregroundColor: AppColors.papayaSensorial,
          disabledBackgroundColor: AppColors.grayScale2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// BOTÃO OUTLINED - Fundo transparente com borda Velvet Merlot
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomOutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.velvetMerlot,
          disabledForegroundColor: AppColors.grayScale2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: isLoading ? AppColors.grayScale2 : AppColors.velvetMerlot,
            width: 2,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.velvetMerlot),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.albertSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}

// BOTÃO TEXTO - Apenas texto, sem fundo
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: GoogleFonts.albertSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? AppColors.papayaSensorial,
          decoration: TextDecoration.underline,
          decorationColor: textColor ?? AppColors.papayaSensorial,
        ),
      ),
    );
  }
}

// BOTÃO DE ÍCONE - Para ações específicas
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.papayaSensorial,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.whiteWhite,
          size: size * 0.5,
        ),
      ),
    );
  }
}

// BOTÃO SOCIAL LOGIN - Para Google, Apple, etc.
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final double? width;
  final double height;

  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.width,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: AppColors.grayScale2.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
            ),
            SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOTÃO SOCIAL LOGIN SIMPLES - Apenas ícone (versão do código original)
class SocialLoginIconButton extends StatelessWidget {
  final String svgAsset;
  final VoidCallback onPressed;
  final double size;

  const SocialLoginIconButton({
    Key? key,
    required this.svgAsset,
    required this.onPressed,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.moonAsh,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayScale2.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            svgAsset,
            width: size * 0.6,
            height: size * 0.6,
          ),
        ),
      ),
    );
  }
}