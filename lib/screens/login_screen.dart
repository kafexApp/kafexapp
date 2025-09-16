import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import 'forgot_password_screen.dart';
import 'home_feed_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _isPasswordVisible = false;

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
            // Imagem de fundo no topo
            Container(
              width: double.infinity,
              height: 280,
              child: SvgPicture.asset(
                'assets/images/background-coffees.svg',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // Conteúdo principal
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Logo do Kafex
                  SvgPicture.asset(
                    'assets/images/kafex_logo_positive.svg',
                    width: 120,
                    height: 40,
                  ),
                  
                  SizedBox(height: 40),

                  // Campo de Email
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.papayaSensorial,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Campo de Senha
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_isPasswordVisible,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.papayaSensorial,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grayScale2,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Botão "Acessar"
                  PrimaryButton(
                    text: 'Acessar',
                    onPressed: () {
                      // Navegar para a tela do feed principal
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeFeedScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // Botão "Recuperar senha"
                  CustomOutlineButton(
                    text: 'Recuperar senha',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32),

                  // Texto "Ou continue com:"
                  Text(
                    'Ou continue com:',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.grayScale2,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Botões de login social
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Google
                      GestureDetector(
                        onTap: () {
                          print('Login com Google');
                        },
                        child: SvgPicture.asset(
                          'assets/images/google-sociallogin.svg',
                          width: 70,
                          height: 70,
                        ),
                      ),

                      SizedBox(width: 24),

                      // Botão Apple
                      GestureDetector(
                        onTap: () {
                          print('Login com Apple');
                        },
                        child: SvgPicture.asset(
                          'assets/images/apple-sociallogin.svg',
                          width: 70,
                          height: 70,
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