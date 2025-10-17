// lib/ui/create_account/widgets/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_text_fields.dart';
import '../../../widgets/custom_buttons.dart';
import './username_selector.dart';
import '../viewmodel/complete_profile_viewmodel.dart';
import '../../home/widgets/home_screen_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String initialEmail;
  
  const CompleteProfileScreen({
    Key? key,
    required this.initialEmail,
  }) : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final viewModel = context.read<CompleteProfileViewModel>();
    final name = _nameController.text.trim();
    
    if (name.length >= 3) {
      viewModel.generateUsernameSuggestions(name);
    }
  }

  Future<void> _handleComplete() async {
    final viewModel = context.read<CompleteProfileViewModel>();
    
    if (_nameController.text.trim().isEmpty) {
      _showErrorMessage('Por favor, digite seu nome completo');
      return;
    }

    if (viewModel.selectedUsername == null) {
      _showErrorMessage('Por favor, selecione um username');
      return;
    }

    final success = await viewModel.completeProfile(
      name: _nameController.text.trim(),
      email: widget.initialEmail,
    );

    if (success) {
      _showSuccessMessage('Perfil completado com sucesso!');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenProvider()),
      );
    } else {
      _showErrorMessage('Erro ao completar perfil. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SafeArea(
        child: Consumer<CompleteProfileViewModel>(
          builder: (context, viewModel, _) {
            return Column(
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
                          suggestions: viewModel.usernameSuggestions,
                          selectedUsername: viewModel.selectedUsername,
                          onUsernameSelected: viewModel.selectUsername,
                          onCustomUsernameChanged: (value) {
                            viewModel.validateCustomUsername(value);
                          },
                          isLoading: viewModel.isLoadingUsernames,
                          customUsernameError: viewModel.customUsernameError,
                          isValidatingCustomUsername: viewModel.isValidatingCustomUsername,
                        ),
                        
                        SizedBox(height: 32),
                        
                        PrimaryButton(
                          text: 'Continuar',
                          onPressed: viewModel.isLoading ? null : _handleComplete,
                          isLoading: viewModel.isLoading,
                        ),
                        
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 40,
              color: AppColors.papayaSensorial,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Complete seu perfil',
            style: GoogleFonts.albertSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Para finalizar, precisamos de algumas informações',
            style: GoogleFonts.albertSans(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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