import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_toast.dart';
import '../utils/user_manager.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupTextControllerListeners();
  }

  void _setupTextControllerListeners() {
    _nameController.addListener(_onTextChanged);
    _usernameController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _addressController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _loadUserData() {
    final userManager = UserManager.instance;
    
    _nameController.text = userManager.userName;
    _emailController.text = userManager.userEmail;
    // TODO: Carregar dados completos do Supabase
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _hasChanges = true;
        });
        CustomToast.showSuccess(context, message: 'Foto selecionada com sucesso!');
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      CustomToast.showError(context, message: 'Erro ao selecionar imagem');
    }
  }

  Widget _buildProfileImage() {
    final userManager = UserManager.instance;
    final userPhotoUrl = userManager.userPhotoUrl;

    // Se há uma imagem selecionada
    if (_selectedImagePath != null) {
      return Image.file(
        File(_selectedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(_nameController.text);
        },
      );
    }
    
    // Se há foto do usuário no UserManager
    if (userPhotoUrl != null && userPhotoUrl.isNotEmpty) {
      return Image.network(
        userPhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(_nameController.text);
        },
      );
    }
    
    // Fallback para avatar com iniciais
    return _buildFallbackAvatar(_nameController.text);
  }

  Widget _buildFallbackAvatar(String userName) {
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.carbon,
      AppColors.grayScale2,
    ];
    
    final avatarColor = avatarColors[colorIndex];
    
    return Container(
      width: 114,
      height: 114,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: GoogleFonts.albertSans(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implementar salvamento no Supabase
      await Future.delayed(Duration(seconds: 2)); // Simular API call

      // Atualizar UserManager com dados básicos
      UserManager.instance.setUserData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _selectedImagePath ?? UserManager.instance.userPhotoUrl,
      );

      CustomToast.showSuccess(context, message: 'Perfil atualizado com sucesso!');
      
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      CustomToast.showError(context, message: 'Erro ao salvar perfil');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user?.email == null || user!.email!.isEmpty) {
        CustomToast.showError(context, message: 'Email do usuário não encontrado');
        return;
      }

      // Enviar email de redefinição sem ActionCodeSettings
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: user.email!,
      );
      
      CustomToast.showSuccess(
        context, 
        message: 'Email de redefinição enviado para ${user.email}!'
      );
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao enviar email de redefinição';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        case 'network-request-failed':
          errorMessage = 'Erro de conexão. Verifique sua internet';
          break;
        case 'unauthorized-continue-uri':
          errorMessage = 'Configuração de domínio pendente. Tente novamente em alguns minutos';
          break;
        default:
          errorMessage = 'Erro ao enviar email: ${e.message}';
      }
      
      CustomToast.showError(context, message: errorMessage);
      print('Erro FirebaseAuth: ${e.code} - ${e.message}');
      
    } catch (e) {
      CustomToast.showError(context, message: 'Erro inesperado ao enviar email');
      print('Erro geral: $e');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _showDeleteAccountDialog();
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Excluir conta do Firebase
        await user.delete();
        
        // Limpar dados do usuário
        UserManager.instance.clearUserData();
        
        CustomToast.showSuccess(context, message: 'Conta excluída com sucesso');
        
        // Navegar para tela inicial
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        CustomToast.showError(context, message: 'Usuário não encontrado');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao excluir conta';
      
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Para sua segurança, faça login novamente antes de excluir a conta';
          break;
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado';
          break;
        default:
          errorMessage = 'Erro ao excluir conta: ${e.message}';
      }
      
      CustomToast.showError(context, message: errorMessage);
    } catch (e) {
      print('Erro ao excluir conta: $e');
      CustomToast.showError(context, message: 'Erro inesperado ao excluir conta');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _showDeleteAccountDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIcons.warning(),
                color: AppColors.roseClay,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Excluir conta',
                style: GoogleFonts.albertSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.roseClay,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação não pode ser desfeita.',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Todos os seus dados serão permanentemente removidos, incluindo:',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12),
              _buildDeleteItem('• Perfil e informações pessoais'),
              _buildDeleteItem('• Histórico de atividades'),
              _buildDeleteItem('• Posts e comentários'),
              _buildDeleteItem('• Favoritos e preferências'),
              SizedBox(height: 16),
              Text(
                'Tem certeza que deseja continuar?',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grayScale1,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseClay,
                foregroundColor: AppColors.whiteWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Excluir conta',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.albertSans(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: AppBar(
        backgroundColor: AppColors.oatWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurações',
          style: GoogleFonts.albertSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Foto de perfil
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.papayaSensorial,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: _buildProfileImage(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.papayaSensorial,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.whiteWhite,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.camera(),
                            size: 18,
                            color: AppColors.whiteWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Campos do formulário
              _buildTextField(
                controller: _nameController,
                label: 'Nome completo',
                icon: PhosphorIcons.user(),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: PhosphorIcons.at(),
                hint: 'seu_username',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Username é obrigatório';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!)) {
                    return 'Apenas letras, números e underscore';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: PhosphorIcons.envelope(),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email é obrigatório';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: 'Celular',
                icon: PhosphorIcons.phone(),
                keyboardType: TextInputType.phone,
                hint: '(11) 99999-9999',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _addressController,
                label: 'Endereço',
                icon: PhosphorIcons.mapPin(),
                maxLines: 2,
              ),

              SizedBox(height: 32),

              // Redefinir senha
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetPassword,
                  icon: Icon(
                    PhosphorIcons.key(),
                    size: 18,
                    color: AppColors.papayaSensorial,
                  ),
                  label: Text(
                    'Redefinir senha',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.papayaSensorial,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppColors.papayaSensorial,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Salvar
              PrimaryButton(
                text: 'Salvar alterações',
                onPressed: _isLoading ? null : () => _saveProfile(),
                isLoading: _isLoading,
              ),

              SizedBox(height: 32),

              // Seção de zona de perigo
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.roseClay.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.roseClay.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.warning(),
                          color: AppColors.roseClay,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Zona de Perigo',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.roseClay,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Esta ação é irreversível. Todos os seus dados serão permanentemente removidos.',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _deleteAccount,
                        icon: Icon(
                          PhosphorIcons.trash(),
                          size: 18,
                          color: AppColors.roseClay,
                        ),
                        label: Text(
                          'Excluir conta',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.roseClay,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: AppColors.roseClay,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.albertSans(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.grayScale2,
          size: 20,
        ),
        labelStyle: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.grayScale1,
        ),
        hintStyle: GoogleFonts.albertSans(
          fontSize: 16,
          color: AppColors.grayScale2,
        ),
        filled: true,
        fillColor: AppColors.whiteWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.moonAsh,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.moonAsh,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.papayaSensorial,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}