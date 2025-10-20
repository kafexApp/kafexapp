// lib/ui/email_verification/widgets/email_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_buttons.dart';
import '../viewmodel/email_verification_viewmodel.dart';
import '../../home/widgets/home_screen_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late EmailVerificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmailVerificationViewModel();
    _viewModel.addListener(_onViewModelChanged);
    
    // Envia o email de verificação automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.sendVerificationEmail();
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    
                    _buildEmailIcon(),
                    
                    SizedBox(height: 32),
                    
                    _buildTitle(),
                    
                    SizedBox(height: 16),
                    
                    _buildDescription(),
                    
                    SizedBox(height: 40),
                    
                    _buildVerifyButton(),
                    
                    SizedBox(height: 16),
                    
                    _buildResendSection(),
                    
                    if (_viewModel.errorMessage != null) ...[
                      SizedBox(height: 24),
                      _buildErrorMessage(),
                    ],
                    
                    SizedBox(height: 40),
                    
                    _buildInstructions(),
                    
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
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.papayaSensorial.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mark_email_read_outlined,
        size: 60,
        color: AppColors.papayaSensorial,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Verifique seu email',
      textAlign: TextAlign.center,
      style: GoogleFonts.albertSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          'Enviamos um link de verificação para:',
          textAlign: TextAlign.center,
          style: GoogleFonts.albertSans(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.papayaSensorial,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return PrimaryButton(
      text: 'Já verifiquei meu email',
      onPressed: _viewModel.isLoading ? null : _handleVerifyEmail,
      isLoading: _viewModel.isLoading,
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        if (_viewModel.canResend)
          TextButton(
            onPressed: _handleResendEmail,
            child: Text(
              'Não recebeu o email? Reenviar',
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.papayaSensorial,
              ),
            ),
          )
        else
          Text(
            'Reenviar em ${_viewModel.resendCountdown}s',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        
        if (_viewModel.isResending)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.spiced.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.spiced.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.spiced,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _viewModel.errorMessage!,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.spiced,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.papayaSensorial,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Instruções',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInstructionItem('1. Abra seu email'),
          SizedBox(height: 8),
          _buildInstructionItem('2. Clique no link de verificação'),
          SizedBox(height: 8),
          _buildInstructionItem('3. Volte aqui e toque em "Já verifiquei"'),
          SizedBox(height: 16),
          Text(
            'Não esqueça de verificar sua caixa de spam!',
            style: GoogleFonts.albertSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.papayaSensorial,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _handleVerifyEmail() async {
    _viewModel.clearError();
    
    final isVerified = await _viewModel.checkEmailVerified();
    
    if (isVerified) {
      _showSuccessMessage('Email verificado com sucesso!');
      
      // Aguarda um momento para mostrar a mensagem
      await Future.delayed(Duration(milliseconds: 800));
      
      // Navega para a tela principal
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenProvider()),
        (route) => false,
      );
    }
  }

  void _handleResendEmail() async {
    _viewModel.clearError();
    
    final success = await _viewModel.resendVerificationEmail();
    
    if (success) {
      _showSuccessMessage('Email reenviado! Verifique sua caixa de entrada.');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.forestInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}