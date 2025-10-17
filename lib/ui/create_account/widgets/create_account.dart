// lib/ui/create_account/widgets/create_account.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final CreateAccountViewModel _viewModel = CreateAccountViewModel();

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
    _viewModel.addListener(() => setState(() {}));
    
    // Listener para gerar sugestões de username quando o nome mudar
    _nameController.addListener(_onNameChanged);
    
    // Listener para validar email
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

  // Método chamado quando o nome muda
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

  // Método chamado quando o email muda
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
                    
                    // Seletor de Username
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
                    
                    // Campo de Email com validação
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
                                  : AppColors.moonAsh.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
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
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 16),
                                        Icon(
                                          Icons.email_outlined,
                                          size: 18,
                                          color: AppColors.carbon,
                                        ),
                                        SizedBox(width: 12),
                                      ],
                                    ),
                                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                                    suffixIcon: _buildEmailSuffixIcon(),
                                    hintText: 'seu@email.com',
                                    hintStyle: GoogleFonts.albertSans(
                                      fontSize: 16,
                                      color: AppColors.textSecondary.withOpacity(0.5),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_viewModel.emailError != null) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: AppColors.spiced,
                              ),
                              SizedBox(width: 6),
                              Expanded(
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
                          ),
                        ],
                        if (_viewModel.emailError == null &&
                            !_viewModel.isValidatingEmail &&
                            _emailController.text.isNotEmpty &&
                            _emailController.text.contains('@')) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: AppColors.carbon,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Email disponível',
                                style: GoogleFonts.albertSans(
                                  fontSize: 13,
                                  color: AppColors.carbon,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      hintText: 'Telefone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
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
                    
                    SizedBox(height: 12),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Após criar sua conta, se decidir sair, é só acessar Configurações no app e tocar em Deletar conta.',
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    PrimaryButton(
                      text: 'Criar conta',
                      onPressed: _viewModel.isLoading ? null : _handleCreateAccount,
                      isLoading: _viewModel.isLoading,
                    ),
                    
                    SizedBox(height: 24),
                    
                    _buildDivider(),
                    
                    SizedBox(height: 24),
                    
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Criar conta',
            style: GoogleFonts.albertSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Preencha os campos abaixo para começar',
            style: GoogleFonts.albertSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
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
            color: AppColors.moonAsh.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou continue com',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.moonAsh.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          asset: 'assets/images/google-sociallogin.svg',
          onTap: _viewModel.isLoading ? null : _handleGoogleSignIn,
        ),
        SizedBox(width: 20),
        _buildSocialButton(
          asset: 'assets/images/apple-sociallogin.svg',
          onTap: _viewModel.isLoading ? null : _handleAppleSignIn,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String asset,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: _viewModel.isLoading ? 0.5 : 1.0,
        child: SvgPicture.asset(
          asset,
          width: 56,
          height: 56,
        ),
      ),
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

  // Métodos de ação usando o ViewModel
  void _handleCreateAccount() async {
    final result = await _viewModel.createAccount(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      termsAccepted: _acceptTerms,
    );

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
      // Buscar o usuário atual do Firebase
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        String name = user.displayName ?? '';
        String email = user.email ?? 'usuario@icloud.com';
        
        // Verificar se o nome está vazio ou é um email criptografado
        bool needsProfileCompletion = name.isEmpty || 
                                      name.contains('@privaterelay.appleid.com') ||
                                      name.length < 3;
        
        if (needsProfileCompletion) {
          print('⚠️ Perfil incompleto, redirecionando para completar cadastro');
          
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
      }
      
      // Perfil completo, continuar normalmente
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