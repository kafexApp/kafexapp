import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  bool _isEmailSent = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
  }

  void _sendResetEmail() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _isEmailSent = true;
      });
      // Aqui você adicionaria a lógica real de envio de email
      print('Email de recuperação enviado para: ${_emailController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.carbon,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(56.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Logo Kafex
              SvgPicture.asset(
                'assets/images/kafex_logo_positive.svg',
                width: 160,
                height: 60,
              ),

              SizedBox(height: 80),

              // Ícone de senha
              SvgPicture.asset(
                'assets/images/icon-password.svg',
                width: 120,
                height: 120,
              ),

              SizedBox(height: 40),

              // Título
              Text(
                _isEmailSent ? 'EMAIL ENVIADO' : 'RECUPERAR SENHA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Monigue',
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: AppColors.velvetMerlot,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 24),

              // Descrição condicional
              Text(
                _isEmailSent
                    ? 'O email de redefinição de senha foi enviado com sucesso. Confira a caixa de entrada do seu email ou o SPAM.'
                    : 'Digite seu email abaixo e enviaremos um link para redefinir sua senha.',
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 40),

              // Campo de email (apenas se o email não foi enviado)
              if (!_isEmailSent) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.carbon,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.carbon,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite seu email',
                        hintStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.grayScale2,
                        ),
                        filled: true,
                        fillColor: AppColors.whiteWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.moonAsh,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.moonAsh,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.papayaSensorial,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],

              // Botão principal usando PrimaryButton
              PrimaryButton(
                text: _isEmailSent ? 'Voltar ao Login' : 'Enviar Email',
                onPressed: _isEmailSent 
                    ? () => Navigator.pop(context)
                    : _sendResetEmail,
              ),

              // Botão secundário (apenas se o email foi enviado)
              if (_isEmailSent) ...[
                SizedBox(height: 16),
                CustomOutlineButton(
                  text: 'Reenviar Email',
                  onPressed: () {
                    setState(() {
                      _isEmailSent = false;
                    });
                    _emailController.clear();
                  },
                ),
              ],

              SizedBox(height: 40),

              // Link para voltar ao login (apenas se o email não foi enviado)
              if (!_isEmailSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lembrou da senha? ',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.grayScale1,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Fazer login',
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.papayaSensorial,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }
}