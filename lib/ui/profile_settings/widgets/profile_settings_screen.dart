import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:kafex/utils/app_colors.dart';
import 'package:kafex/widgets/custom_buttons.dart';
import 'package:kafex/widgets/custom_toast.dart';
import 'package:kafex/data/models/domain/profile_settings.dart';
import 'package:kafex/ui/profile_settings/viewmodel/profile_settings_viewmodel.dart';
import 'package:kafex/ui/create_account/widgets/username_selector.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  
  String _selectedUsername = '';
  bool _isValidatingUsername = false;
  String? _customUsernameError;

  @override
  void initState() {
    super.initState();
    _setupTextControllerListeners();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileSettingsViewModel>().loadSettings.execute();
    });
  }

  void _setupTextControllerListeners() {
    _nameController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _cepController.addListener(_onTextChanged);
    _addressController.addListener(_onTextChanged);
    _cityController.addListener(_onTextChanged);
    _stateController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final viewModel = context.read<ProfileSettingsViewModel>();
    if (viewModel.settings != null) {
      final updatedSettings = viewModel.settings!.copyWith(hasChanges: true);
      viewModel.updateSettings.execute(updatedSettings);
    }
  }

  void _updateControllersFromSettings(ProfileSettings settings) {
    _nameController.text = settings.nomeExibicao;
    _selectedUsername = settings.nomeUsuario;
    _phoneController.text = settings.telefone ?? '';
    _cepController.text = settings.cep ?? '';
    _addressController.text = settings.endereco ?? '';
    _cityController.text = settings.cidade ?? '';
    _stateController.text = settings.estado ?? '';
  }

  Widget _buildProfileImage(ProfileSettingsViewModel viewModel) {
    final imagePath = viewModel.getProfileImagePath();
    
    if (viewModel.selectedImagePath != null) {
      return Container(
        width: 114,
        height: 114,
        decoration: BoxDecoration(
          color: AppColors.papayaSensorial.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          PhosphorIcons.image(),
          size: 40,
          color: AppColors.papayaSensorial,
        ),
      );
    }
    
    if (imagePath.isNotEmpty && imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return viewModel.buildFallbackAvatar(_nameController.text);
        },
      );
    }
    
    return viewModel.buildFallbackAvatar(_nameController.text);
  }

  Future<void> _saveProfile(ProfileSettingsViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedUsername.isEmpty) {
      CustomToast.showError(context, message: 'Selecione um username');
      return;
    }

    final settings = viewModel.settings!.copyWith(
      nomeExibicao: _nameController.text.trim(),
      nomeUsuario: _selectedUsername,
      telefone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      cep: _cepController.text.trim().isEmpty ? null : _cepController.text.trim(),
      endereco: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      cidade: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      estado: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
    );

    await viewModel.saveSettings.execute(settings);
    
    if (viewModel.state.errorMessage == null) {
      CustomToast.showSuccess(context, message: 'Perfil atualizado com sucesso!');
    } else {
      CustomToast.showError(context, message: viewModel.state.errorMessage!);
    }
  }

  Future<void> _resetPassword(ProfileSettingsViewModel viewModel) async {
    await viewModel.resetPassword.execute();
    
    await Future.delayed(Duration(milliseconds: 100));
    
    if (viewModel.state.errorMessage != null) {
      CustomToast.showError(context, message: viewModel.state.errorMessage!);
    } else {
      CustomToast.showSuccess(
        context, 
        message: 'Email de redefinição de senha enviado!'
      );
    }
  }

  Future<void> _deleteAccount(ProfileSettingsViewModel viewModel) async {
    final confirmed = await _showDeleteAccountDialog();
    if (confirmed != true) return;

    await viewModel.deleteAccount.execute();
    
    await Future.delayed(Duration(milliseconds: 100));
    
    if (viewModel.state.errorMessage != null) {
      CustomToast.showError(context, message: viewModel.state.errorMessage!);
    } else if (!viewModel.isSaving) {
      CustomToast.showSuccess(context, message: 'Conta excluída com sucesso');
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                'Todos os seus dados serão permanentemente removidos do Supabase e Firebase.',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSettingsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.settings != null && 
            _nameController.text.isEmpty && 
            !viewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllersFromSettings(viewModel.settings!);
          });
        }

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
          body: viewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: _buildProfileImage(viewModel),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => viewModel.selectImage.execute(),
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

                        // Nome completo
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

                        // Username Selector
                        Text(
                          'Username',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        UsernameSelector(
                          suggestions: _selectedUsername.isEmpty && _nameController.text.isNotEmpty
                              ? [
                                  '${_nameController.text.toLowerCase().replaceAll(' ', '_')}',
                                  '${_nameController.text.toLowerCase().replaceAll(' ', '')}'
                                ]
                              : _selectedUsername.isNotEmpty
                                  ? [_selectedUsername]
                                  : ['usuario'],
                          selectedUsername: _selectedUsername,
                          onUsernameSelected: (username) {
                            setState(() {
                              _selectedUsername = username;
                              _customUsernameError = null;
                            });
                            _onTextChanged();
                          },
                          onCustomUsernameChanged: (username) async {
                            setState(() {
                              _isValidatingUsername = true;
                              _customUsernameError = null;
                            });
                            
                            await Future.delayed(Duration(milliseconds: 500));
                            
                            if (username.length < 3) {
                              setState(() {
                                _customUsernameError = 'Username deve ter no mínimo 3 caracteres';
                                _isValidatingUsername = false;
                              });
                              return;
                            }
                            
                            if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
                              setState(() {
                                _customUsernameError = 'Use apenas letras minúsculas, números e underscore';
                                _isValidatingUsername = false;
                              });
                              return;
                            }
                            
                            setState(() {
                              _selectedUsername = username;
                              _isValidatingUsername = false;
                            });
                            _onTextChanged();
                          },
                          isValidatingCustomUsername: _isValidatingUsername,
                          customUsernameError: _customUsernameError,
                        ),

                        SizedBox(height: 16),

                        // Telefone
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

                        SizedBox(height: 24),

                        // Seção de Endereço
                        Text(
                          'Endereço',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        SizedBox(height: 16),

                        // CEP
                        _buildTextField(
                          controller: _cepController,
                          label: 'CEP',
                          icon: PhosphorIcons.mapPin(),
                          hint: '00000-000',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),

                        SizedBox(height: 16),

                        // Endereço
                        _buildTextField(
                          controller: _addressController,
                          label: 'Rua / Avenida',
                          icon: PhosphorIcons.roadHorizon(),
                        ),

                        SizedBox(height: 16),

                        // Cidade e Estado
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'Cidade',
                                icon: PhosphorIcons.buildings(),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'Estado',
                                icon: PhosphorIcons.flag(),
                                hint: 'SP',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32),

                        // Redefinir senha
                        Container(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _resetPassword(viewModel),
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
                          onPressed: viewModel.isSaving ? null : () => _saveProfile(viewModel),
                          isLoading: viewModel.isSaving,
                        ),

                        SizedBox(height: 32),

                        // Zona de Perigo
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
                                  onPressed: viewModel.isSaving ? null : () => _deleteAccount(viewModel),
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
      },
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
    _phoneController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }
}