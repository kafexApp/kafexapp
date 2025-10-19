import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/user_manager.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_text_fields.dart';
import '../widgets/custom_toast.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'welcome_screen.dart';
import '../ui/home/widgets/home_screen_provider.dart';
import '../ui/create_account/widgets/complete_profile_screen.dart';
import '../ui/create_account/viewmodel/complete_profile_viewmodel.dart';

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

  bool get _isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  bool get _showGoogleText {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

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
            Container(
              width: double.infinity,
              height: 280,
              child: SvgPicture.asset(
                'assets/images/background-coffees.svg',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/kafex_logo_positive.svg',
                    width: 144,
                    height: 48,
                  ),
                  
                  SizedBox(height: 40),

                  CustomTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  SizedBox(height: 16),

                  CustomPasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    hintText: 'Senha',
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  SizedBox(height: 32),

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

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.grayScale1,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text(
                              'Voltar',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grayScale1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
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
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.grayScale1,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text(
                              'Recuperar senha',
                              style: GoogleFonts.albertSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grayScale1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  Text(
                    'Ou continue com:',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.grayScale2,
                    ),
                  ),

                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Google
                      GestureDetector(
                        onTap: _isLoading ? null : _handleGoogleSignIn,
                        child: Opacity(
                          opacity: _isLoading ? 0.6 : 1.0,
                          child: _showGoogleText 
                            ? Container(
                                height: 78,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 78,
                                      height: 78,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/images/icon-google-social-login.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 24, left: 8),
                                      child: Text(
                                        'Entrar com o Google',
                                        style: GoogleFonts.albertSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.grayScale1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/icon-google-social-login.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                        ),
                      ),

                      // Botão Apple (apenas iOS)
                      if (_isIOS) ...[
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: _isLoading ? null : _handleAppleSignIn,
                          child: Opacity(
                            opacity: _isLoading ? 0.6 : 1.0,
                            child: Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                color: AppColors.carbon,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/icon-apple-social-login.svg',
                                  width: 28,
                                  height: 28,
                                ),
                              ),
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

      if (result.isSuccess && result.user != null) {
        String uid = result.user!.uid;
        String email = _emailController.text.trim();
        String name = result.user?.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          uid: uid,
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login realizado com sucesso!');
        
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

      if (result.isSuccess && result.user != null) {
        String uid = result.user!.uid;
        String email = result.user?.email ?? 'usuario@gmail.com';
        String name = result.user?.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          uid: uid,
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login com Google realizado com sucesso!');
        
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

      if (result.isSuccess && result.user != null) {
        String uid = result.user!.uid;
        String email = result.user?.email ?? 'usuario@icloud.com';
        String name = result.user?.displayName ?? '';
        
        // Verificar se o nome está vazio ou é um email criptografado
        bool needsProfileCompletion = name.isEmpty || 
                                      name.contains('@privaterelay.appleid.com') ||
                                      name.length < 3;
        
        if (needsProfileCompletion) {
          print('⚠️ Perfil incompleto, redirecionando para completar cadastro');
          
          setState(() {
            _isLoading = false;
          });
          
          // Redirecionar para tela de completar perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => CompleteProfileViewModel(),
                child: CompleteProfileScreen(initialEmail: email),
              ),
            ),
          );
          return;
        }
        
        // Perfil completo, continuar normalmente
        UserManager.instance.setUserData(
          uid: uid,
          name: name,
          email: email,
          photoUrl: result.user?.photoURL,
        );

        CustomToast.showSuccess(context, message: 'Login com Apple realizado com sucesso!');
        
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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