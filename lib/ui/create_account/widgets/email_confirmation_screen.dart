// lib/ui/create_account/widgets/email_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../services/email_verification_service.dart';
import 'package:kafex/config/app_routes.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;

  const EmailConfirmationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _EmailConfirmationScreenState createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 48),
                    _buildEmailIcon(),
                    SizedBox(height: 32),
                    _buildTitle(),
                    SizedBox(height: 16),
                    _buildDescription(),
                    SizedBox(height: 40),
                    _buildResendButton(),
                    SizedBox(height: 16),
                    _buildLoginButton(),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Confirme seu email',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildEmailIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: AppColors.papayaSensorial.withOpacity(0.1),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 64,
            color: AppColors.papayaSensorial,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pear,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.whiteWhite,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 18,
                color: AppColors.forestInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Falta pouco!',
      style: GoogleFonts.albertSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          'Recebemos seus dados e enviamos um email de confirmação para:',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.papayaSensorial.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                size: 20,
                color: AppColors.papayaSensorial,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.email,
                  style: GoogleFonts.albertSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.papayaSensorial,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Clique no link do email e volte aqui nessa tela para acessar o app.',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pear.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.pear.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.forestInk,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Não esqueça de verificar sua caixa de spam!',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestInk,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    return OutlineButton(
      text: 'Reenviar email',
      onPressed: _isResending ? null : _handleResendEmail,
      isLoading: _isResending,
      icon: Icons.refresh_rounded,
    );
  }

  Widget _buildLoginButton() {
    return PrimaryButton(
      text: 'Já confirmei, fazer login',
      onPressed: _handleGoToLogin,
      icon: Icons.arrow_forward_rounded,
    );
  }

  Future<void> _handleResendEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final success = await EmailVerificationService.resendVerificationEmail();

      if (success) {
        _showSuccessMessage('Email reenviado com sucesso!');
      } else {
        _showErrorMessage('Erro ao reenviar email. Tente novamente.');
      }
    } catch (e) {
      _showErrorMessage('Erro ao reenviar email: $e');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _handleGoToLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.spiced,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.forestInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }
}