import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.papayaSensorial,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Espaço superior
                SizedBox(height: 60),
                
                // Área principal com fundo oatWhite
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.oatWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          
                          // Título
                          Text(
                            'Digite seus dados abaixo',
                            style: GoogleFonts.albertSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Campos de entrada
                          _buildTextField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hintText: 'Nome',
                            keyboardType: TextInputType.name,
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            hintText: 'Telefone',
                            keyboardType: TextInputType.phone,
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildPasswordField(
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
                          
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            hintText: 'Confirmação de senha',
                            isVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Checkbox de termos
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptTerms = !_acceptTerms;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _acceptTerms ? AppColors.papayaSensorial : Colors.transparent,
                                    border: Border.all(
                                      color: AppColors.papayaSensorial,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _acceptTerms
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color: AppColors.whiteWhite,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aceito os termos de uso e política de privacidade.',
                                  style: GoogleFonts.albertSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Aviso sobre exclusão de conta
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.grayScale2.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.grayScale1,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.albertSans(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Após a criação da conta, você poderá excluir sua conta,se desejar, à qualquer momento acessando Minha conta em seguida clique em ',
                                        ),
                                        TextSpan(
                                          text: 'Deletar conta',
                                          style: GoogleFonts.albertSans(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Texto "Ou continue com:"
                          Text(
                            'Ou continue com:',
                            style: GoogleFonts.albertSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Botões de login social
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botão Google
                              GestureDetector(
                                onTap: () {
                                  print('🔍 Iniciando login com Google...');
                                  // TODO: Implementar login com Google
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
                                  print('🍎 Iniciando login com Apple...');
                                  // TODO: Implementar login com Apple
                                },
                                child: SvgPicture.asset(
                                  'assets/images/apple-sociallogin.svg',
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                            ],
                          ),
                          
                          Spacer(),
                          
                          // Botões inferiores
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    side: BorderSide(
                                      color: AppColors.papayaSensorial,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    'Voltar',
                                    style: GoogleFonts.albertSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.papayaSensorial,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _acceptTerms ? () {
                                    _handleCreateAccount();
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.papayaSensorial,
                                    disabledBackgroundColor: AppColors.grayScale2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Criar conta',
                                    style: GoogleFonts.albertSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return Container(
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
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: AppColors.whiteWhite,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
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
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.albertSans(
            fontSize: 16,
            color: AppColors.grayScale2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: AppColors.whiteWhite,
          suffixIcon: GestureDetector(
            onTap: onToggleVisibility,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grayScale2,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreateAccount() {
    // Validações básicas
    if (_nameController.text.isEmpty) {
      _showErrorMessage('Por favor, digite seu nome');
      return;
    }
    
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showErrorMessage('Por favor, digite um email válido');
      return;
    }
    
    if (_phoneController.text.isEmpty) {
      _showErrorMessage('Por favor, digite seu telefone');
      return;
    }
    
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showErrorMessage('A senha deve ter pelo menos 6 caracteres');
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('As senhas não coincidem');
      return;
    }
    
    if (!_acceptTerms) {
      _showErrorMessage('Você deve aceitar os termos de uso');
      return;
    }

    // TODO: Implementar criação da conta
    print('Criando conta...');
    print('Nome: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Telefone: ${_phoneController.text}');
    
    // Simular sucesso na criação da conta
    _showSuccessMessage('Conta criada com sucesso!');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.spiced,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.forestInk,
      ),
    );
  }
}