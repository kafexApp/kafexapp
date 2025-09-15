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

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
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
                'RECUPERAR SENHA',
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

              // Descrição
              Text(
                'O email de redefinição de senha foi enviado com sucesso. Confira a caixa de entrada do seu email ou o SPAM.',
                textAlign: TextAlign.center,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 60),

              // Botão Login usando PrimaryButton
              PrimaryButton(
                text: 'Login',
                onPressed: () {
                  Navigator.pop(context); // Volta para tela de login
                },
              ),

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