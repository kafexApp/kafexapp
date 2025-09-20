import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import '../services/auth_service.dart';
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
  final AuthService _authService = AuthService();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  // Fazer login com email e senha
  Future<void> _loginWithEmail() async {
    // Validar campos
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.isSuccess) {
        // Login realizado com sucesso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFeedScreen()),
        );
      } else {
        // Erro no login
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Fazer login com Google
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result.isSuccess) {
        // Login realizado com sucesso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFeedScreen()),
        );
      } else {
        // Erro no login
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login com Google.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Verificar se deve mostrar botão Apple
  bool get _shouldShowAppleLogin {
    if (kIsWeb) {
      // No web, Apple login funciona, então pode mostrar
      return true;
    }
    
    try {
      // No mobile, só mostrar se for iOS ou macOS
      return Platform.isIOS || Platform.isMacOS;
    } catch (e) {
      // Se der erro na detecção, não mostrar
      return false;
    }
  }
  Future<void> _loginWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithApple();

      if (result.isSuccess) {
        // Login realizado com sucesso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFeedScreen()),
        );
      } else {
        // Erro no login
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login com Apple.';
      });
    }

    setState(() {
      _isLoading = false;
    });
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

                  // Mensagem de erro (se houver)
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.spiced.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.spiced.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.spiced,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

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
                      enabled: !_isLoading,
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
                      onChanged: (value) {
                        // Limpar erro quando usuário começar a digitar
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
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
                      enabled: !_isLoading,
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
                          onPressed: _isLoading ? null : () {
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
                      onChanged: (value) {
                        // Limpar erro quando usuário começar a digitar
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      onSubmitted: (value) {
                        if (!_isLoading) {
                          _loginWithEmail();
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 32),

                  // Botão "Acessar"
                  PrimaryButton(
                    text: 'Acessar',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? () {} : _loginWithEmail,
                  ),

                  SizedBox(height: 16),

                  // Botão "Recuperar senha"
                  CustomOutlineButton(
                    text: 'Recuperar senha',
                    onPressed: _isLoading ? () {} : () {
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
                      // Botão Google (sempre disponível)
                      GestureDetector(
                        onTap: _isLoading ? null : _loginWithGoogle,
                        child: Opacity(
                          opacity: _isLoading ? 0.5 : 1.0,
                          child: SvgPicture.asset(
                            'assets/images/google-sociallogin.svg',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),

                      // Botão Apple (apenas iOS/macOS/Web)
                      if (_shouldShowAppleLogin) ...[
                        SizedBox(width: 24),
                        GestureDetector(
                          onTap: _isLoading ? null : _loginWithApple,
                          child: Opacity(
                            opacity: _isLoading ? 0.5 : 1.0,
                            child: SvgPicture.asset(
                              'assets/images/apple-sociallogin.svg',
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                      ],
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