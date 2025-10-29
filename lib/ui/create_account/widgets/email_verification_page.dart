// lib/ui/create_account/widgets/email_verification_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../services/email_verification_service.dart';
import '../../../config/app_routes.dart';

/// Página que processa a verificação de email via token
/// Chamada quando o usuário clica no link do email
class EmailVerificationPage extends StatefulWidget {
  final String? token;

  const EmailVerificationPage({
    Key? key,
    this.token,
  }) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isVerifying = true;
  bool _verificationSuccess = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    if (widget.token == null || widget.token!.isEmpty) {
      setState(() {
        _isVerifying = false;
        _verificationSuccess = false;
        _errorMessage = 'Token de verificação inválido';
      });
      return;
    }

    try {
      print('🔄 Verificando token: ${widget.token}');
      
      final success = await EmailVerificationService.verifyEmail(widget.token!);

      setState(() {
        _isVerifying = false;
        _verificationSuccess = success;
        if (!success) {
          _errorMessage = 'Token inválido ou expirado';
        }
      });

      // Se sucesso, redirecionar para login após 2 segundos
      if (success) {
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        });
      }
    } catch (e) {
      print('❌ Erro ao verificar email: $e');
      setState(() {
        _isVerifying = false;
        _verificationSuccess = false;
        _errorMessage = 'Erro ao verificar email. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isVerifying) ...[
                  _buildVerifyingState(),
                ] else if (_verificationSuccess) ...[
                  _buildSuccessState(),
                ] else ...[
                  _buildErrorState(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyingState() {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
          strokeWidth: 3,
        ),
        SizedBox(height: 32),
        Text(
          'Verificando seu email...',
          style: GoogleFonts.albertSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Por favor, aguarde um momento',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.pear.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 80,
            color: AppColors.pear,
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Email Verificado!',
          style: GoogleFonts.albertSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Sua conta foi ativada com sucesso!\nRedirecionando para o login...',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pear),
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.spiced.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: AppColors.spiced,
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Erro na Verificação',
          style: GoogleFonts.albertSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          _errorMessage,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.papayaSensorial,
            foregroundColor: AppColors.whiteWhite,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Ir para o Login',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: _verifyEmail,
          child: Text(
            'Tentar novamente',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.papayaSensorial,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}