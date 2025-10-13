// lib/ui/create_account/widgets/create_account.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_text_fields.dart';
import './terms_checkbox.dart';
import '../viewmodel/create_account_viewmodel.dart';
import '../../home/widgets/home_screen_provider.dart';
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
  }

  @override
  void dispose() {
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
                    
                    CustomTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
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