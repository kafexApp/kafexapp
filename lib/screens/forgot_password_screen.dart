import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background decorativo no topo (alinhado de baixo para cima)
            Container(
              width: double.infinity,
              height: 280,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/images/background-coffees.svg',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter, // Alinha de baixo para cima
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.all(56.0),
              child: Column(
                children: [
                  // Logo Kafex
                  SvgPicture.asset(
                    'assets/images/kafex_logo_positive.svg',
                    width: 160,
                    height: 60,
                  ),

                  SizedBox(height: 60),

                  // Campo Email
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.carbon,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.grayScale2,
                      ),
                      filled: true,
                      fillColor: AppColors.whiteWhite,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.oatWhite,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.papayaSensorial,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.oatWhite,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Campo Senha
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.carbon,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      hintStyle: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.grayScale2,
                      ),
                      filled: true,
                      fillColor: AppColors.whiteWhite,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.oatWhite,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.papayaSensorial,
                          width: 2,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.oatWhite,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.grayScale2,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Botão Acessar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Acessar clicado');
                        print('Email: ${_emailController.text}');
                        print('Senha: ${_passwordController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.papayaSensorial,
                        foregroundColor: AppColors.whiteWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Acessar',
                        style: GoogleFonts.albertSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Botão Recuperar senha (alinhamento corrigido)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.papayaSensorial,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: AppColors.papayaSensorial,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Recuperar senha',
                        style: GoogleFonts.albertSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Ou continue com
                  Text(
                    'Ou continue com:',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.grayScale1,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Botões de Social Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Google
                      GestureDetector(
                        onTap: () {
                          print('Login com Google');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          child: SvgPicture.asset(
                            'assets/images/google-sociallogin.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(width: 24),

                      // Botão Apple
                      GestureDetector(
                        onTap: () {
                          print('Login com Apple');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          child: SvgPicture.asset(
                            'assets/images/apple-sociallogin.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}