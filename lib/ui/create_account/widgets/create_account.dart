// lib/ui/create_account/widgets/create_account.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_text_fields.dart';
import './terms_checkbox.dart';
import './username_selector.dart';
import '../viewmodel/create_account_viewmodel.dart';
import '../../home/widgets/home_screen_provider.dart';
import './complete_profile_screen.dart';
import '../viewmodel/complete_profile_viewmodel.dart';
import '../../../screens/login_screen.dart';
import '../../email_verification/widgets/email_verification_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  
  // Armazena o número completo com código do país
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;

  final CreateAccountViewModel _viewModel = CreateAccountViewModel();

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
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
    _viewModel.addListener(() => setState(() {}));
    
    _nameController.addListener(_onNameChanged);
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _emailController.removeListener(_onEmailChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    print('🔍 Nome digitado: "$name" (${name.length} caracteres)');
    
    if (name.length >= 3) {
      print('✅ Gerando sugestões para: $name');
      _viewModel.generateUsernameSuggestions(name);
    } else {
      print('⚠️ Nome muito curto, limpando sugestões');
      _viewModel.clearUsernameSuggestions();
    }
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      _viewModel.validateEmail(email);
    } else {
      _viewModel.clearEmailError();
    }
  }

  Widget? _buildEmailSuffixIcon() {
    if (_viewModel.isValidatingEmail) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pear),
          ),
        ),
      );
    }
    
    if (_viewModel.emailError != null && _emailController.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(
          Icons.close_rounded,
          color: AppColors.spiced,
          size: 24,
        ),
      );
    }
    
    if (_viewModel.emailError == null &&
        !_viewModel.isValidatingEmail &&
        _emailController.text.isNotEmpty &&
        _emailController.text.contains('@')) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(
          Icons.check_circle_outline,
          color: AppColors.pear,
          size: 24,
        ),
      );
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.oatWhite,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 32),
                      
                      CustomTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hintText: 'Nome completo',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                      ),
                      
                      SizedBox(height: 16),
                      
                      UsernameSelector(
                        suggestions: _viewModel.usernameSuggestions,
                        selectedUsername: _viewModel.selectedUsername,
                        onUsernameSelected: _viewModel.selectUsername,
                        onCustomUsernameChanged: (value) {
                          _viewModel.validateCustomUsername(value);
                        },
                        isLoading: _viewModel.isLoadingUsernames,
                        customUsernameError: _viewModel.customUsernameError,
                        isValidatingCustomUsername: _viewModel.isValidatingCustomUsername,
                      ),
                      
                      SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: AppColors.whiteWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _viewModel.emailError != null
                                    ? AppColors.spiced
                                    : (_emailFocus.hasFocus 
                                        ? AppColors.papayaSensorial 
                                        : AppColors.moonAsh.withOpacity(0.15)),
                                width: _emailFocus.hasFocus ? 2 : 1,
                              ),
                              boxShadow: _emailFocus.hasFocus
                                  ? [
                                      BoxShadow(
                                        color: AppColors.papayaSensorial.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: TextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: _emailFocus.hasFocus
                                      ? AppColors.papayaSensorial
                                      : AppColors.textSecondary,
                                  size: 22,
                                ),
                                suffixIcon: _buildEmailSuffixIcon(),
                                hintText: 'E-mail',
                                hintStyle: GoogleFonts.albertSans(
                                  fontSize: 16,
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          if (_viewModel.emailError != null) ...[
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                _viewModel.emailError!,
                                style: GoogleFonts.albertSans(
                                  fontSize: 13,
                                  color: AppColors.spiced,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // ✅ Campo de telefone com formatação automática por país
                      IntlPhoneField(
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        decoration: InputDecoration(
                          hintText: 'Telefone',
                          hintStyle: GoogleFonts.albertSans(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.whiteWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.oatWhite,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.oatWhite,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.papayaSensorial,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.spiced,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.spiced,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                        ),
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        initialCountryCode: 'BR', // Brasil como padrão
                        languageCode: 'pt', // Idioma em português
                        
                        // ✅ Formatação automática habilitada
                        autovalidateMode: AutovalidateMode.disabled,
                        showCountryFlag: true,
                        showDropdownIcon: true,
                        
                        dropdownTextStyle: GoogleFonts.albertSans(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        searchText: 'Buscar país',
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                        flagsButtonPadding: EdgeInsets.only(left: 8),
                        
                        // ✅ Callback quando o número muda
                        onChanged: (phone) {
                          setState(() {
                            _completePhoneNumber = phone.completeNumber;
                            _isPhoneValid = phone.isValidNumber();
                          });
                          
                          print('📱 Telefone formatado: ${phone.number}');
                          print('📱 Telefone completo: ${phone.completeNumber}');
                          print('📱 Código do país: ${phone.countryCode}');
                          print('✅ Válido: $_isPhoneValid');
                        },
                        
                        // ✅ Callback quando o país muda
                        onCountryChanged: (country) {
                          print('🌎 País: ${country.name}');
                          print('🌎 Código: ${country.dialCode}');
                        },
                        
                        // ✅ Texto de erro personalizado (opcional)
                        invalidNumberMessage: 'Número inválido para este país',
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
                      
                      SizedBox(height: 16),
                      
                      CustomPasswordField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        hintText: 'Confirmar senha',
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      
                      SizedBox(height: 24),
                      
                      TermsCheckbox(
                        isChecked: _acceptTerms,
                        onChanged: () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                      ),
                      
                      SizedBox(height: 32),
                      
                      PrimaryButton(
                        text: 'Criar conta',
                        onPressed: _viewModel.isLoading || 
                                  _viewModel.selectedUsername == null
                            ? null
                            : _handleCreateAccount,
                        isLoading: _viewModel.isLoading,
                      ),
                      
                      SizedBox(height: 32),
                      
                      _buildDivider(),
                      
                      SizedBox(height: 32),
                      
                      _buildSocialButtons(),
                      
                      SizedBox(height: 32),
                      
                      _buildLoginLink(),
                      
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                'Criar conta',
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.moonAsh,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ou continue com',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.moonAsh,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _viewModel.isLoading ? null : _handleGoogleSignIn,
          child: Opacity(
            opacity: _viewModel.isLoading ? 0.6 : 1.0,
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

        if (_isIOS) ...[
          SizedBox(width: 16),
          GestureDetector(
            onTap: _viewModel.isLoading ? null : _handleAppleSignIn,
            child: Opacity(
              opacity: _viewModel.isLoading ? 0.6 : 1.0,
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
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.albertSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: 'Já tem uma conta? '),
              TextSpan(
                text: 'Faça login',
                style: TextStyle(
                  color: AppColors.papayaSensorial,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreateAccount() async {
    // Usar o número completo com código do país
    final result = await _viewModel.createAccount(
      name: _nameController.text,
      email: _emailController.text,
      phone: _completePhoneNumber, // ✅ Número no formato internacional
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      termsAccepted: _acceptTerms,
    );

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      _showErrorMessage(result.errorMessage!);
    }
  }

  void _handleGoogleSignIn() async {
    final result = await _viewModel.signInWithGoogle();

    if (result.success) {
      _showSuccessMessage(result.successMessage!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenProvider()),
      );
    } else {
      _showErrorMessage(result.errorMessage!);
    }
  }

  void _handleAppleSignIn() async {
    final result = await _viewModel.signInWithApple();

    if (result.success) {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        String name = user.displayName ?? '';
        String email = user.email ?? 'usuario@icloud.com';
        
        bool needsProfileCompletion = name.isEmpty || 
                                      name.contains('@privaterelay.appleid.com') ||
                                      name.length < 3;
        
        if (needsProfileCompletion) {
          print('⚠️ Perfil incompleto, redirecionando para completar cadastro');
          
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
      }
      
      _showSuccessMessage(result.successMessage!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenProvider()),
      );
    } else {
      _showErrorMessage(result.errorMessage!);
    }
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
      ),
    );
  }
}