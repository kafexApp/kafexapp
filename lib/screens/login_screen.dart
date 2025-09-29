import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/user_manager.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_toast.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'home_feed_screen.dart';
import '../ui/home/widgets/home_screen_provider.dart';

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
  bool _isLoading = false;

  final AuthService _authService = AuthService();

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
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
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
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
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
                                ? AppIcons.eyeSlash
                                : AppIcons.eye,
                            color: AppColors.grayScale2,
                            size: 20,
                          ),
                          onPressed: () {
                            if (!_isLoading) {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            }
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

                  // Botão "Acessar" com loading
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.papayaSensorial,
                        disabledBackgroundColor: AppColors.grayScale2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.whiteWhite,
                                ),
                              ),
                            )
                          : Text(
                              'Acessar',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteWhite,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Botão "Recuperar senha"
                  CustomOutlineButton(
                    text: 'Recuperar senha',
                    onPressed: () {
                      if (!_isLoading) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      }
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
                        onTap: _isLoading ? null : _handleGoogleSignIn,
                        child: Opacity(
                          opacity: _isLoading ? 0.6 : 1.0,
                          child: SvgPicture.asset(
                            'assets/images/google-sociallogin.svg',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),

                      SizedBox(width: 24),

                      // Botão Apple
                      GestureDetector(
                        onTap: _isLoading ? null : _handleAppleSignIn,
                        child: Opacity(
                          opacity: _isLoading ? 0.6 : 1.0,
                          child: SvgPicture.asset(
                            'assets/images/apple-sociallogin.svg',
                            width: 70,
                            height: 70,
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

  void _handleLogin() async {
    if (_emailController.text.isEmpty) {
      CustomToast.showError(context, message: 'Por favor, digite seu email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomToast.showError(context, message: 'Por favor, digite sua senha');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSuccess) {
        // SALVAR DADOS NO USER MANAGER
        String email = _emailController.text.trim();
        String name = result.user?.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login realizado com sucesso!');
        
        // Navegar diretamente para o feed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreenProvider()),
        );
      } else {
        CustomToast.showError(context, message: result.errorMessage ?? 'Erro no login');
      }
    } catch (e) {
      CustomToast.showError(context, message: 'Erro inesperado: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();

      if (result.isSuccess) {
        // SALVAR DADOS DO GOOGLE NO USER MANAGER
        String email = result.user?.email ?? 'usuario@gmail.com';
        String name = result.user?.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login com Google realizado com sucesso!');
        
        // Navegar diretamente para o feed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreenProvider()),
        );
      } else {
        CustomToast.showError(context, message: result.errorMessage ?? 'Erro no login com Google');
      }
    } catch (e) {
      CustomToast.showError(context, message: 'Erro no login com Google: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithApple();

      if (result.isSuccess) {
        // SALVAR DADOS DO APPLE NO USER MANAGER
        String email = result.user?.email ?? 'usuario@icloud.com';
        String name = result.user?.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login com Apple realizado com sucesso!');
        
        // Navegar diretamente para o feed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreenProvider()),
        );
      } else {
        CustomToast.showError(context, message: result.errorMessage ?? 'Erro no login com Apple');
      }
    } catch (e) {
      CustomToast.showError(context, message: 'Erro no login com Apple: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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