import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';

class SuccessModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    String? buttonText,
    VoidCallback? onPressed,
    bool autoClose = true,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessModalContent(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        autoClose: autoClose,
        autoCloseDuration: autoCloseDuration,
      ),
    );
  }
}

class _SuccessModalContent extends StatefulWidget {
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onPressed;
  final bool autoClose;
  final Duration autoCloseDuration;

  const _SuccessModalContent({
    required this.title,
    this.message,
    this.buttonText,
    this.onPressed,
    required this.autoClose,
    required this.autoCloseDuration,
  });

  @override
  State<_SuccessModalContent> createState() => _SuccessModalContentState();
}

class _SuccessModalContentState extends State<_SuccessModalContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    if (widget.autoClose) {
      Future.delayed(widget.autoCloseDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSuccessIcon(),
                SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.message != null) ...[
                  SizedBox(height: 8),
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (!widget.autoClose) ...[
                  SizedBox(height: 24),
                  _buildButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.papayaSensorial.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.checkCircle,
        size: 32,
        color: AppColors.papayaSensorial,
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Material(
      color: AppColors.papayaSensorial,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          widget.onPressed?.call();
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            widget.buttonText ?? 'Fechar',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteWhite,
            ),
          ),
        ),
      ),
    );
  }
}