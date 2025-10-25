// lib/ui/subscription/viewmodel/invitation_box_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../../services/user_profile_service.dart';

class InvitationBoxViewModel extends ChangeNotifier {
  final SubscriptionRepository _subscriptionRepository;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+55 (##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  
  String? errorMessage;
  bool _isLoading = true;
  
  InvitationBoxViewModel({
    SubscriptionRepository? subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository ?? SubscriptionRepositoryImpl() {
    _initializeCommands();
    _loadUserData();
  }

  void _initializeCommands() {
    submitWaitlist = Command0(_submitWaitlist);
  }

  late Command0<void> submitWaitlist;

  bool get isLoading => _isLoading;

  MaskTextInputFormatter get phoneMaskFormatter => _phoneMaskFormatter;

  /// Carrega dados do usuário do Supabase e preenche os campos
  Future<void> _loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ Nenhum usuário logado');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('🔍 Carregando dados do usuário: ${firebaseUser.uid}');

      // Buscar perfil no Supabase
      final profile = await UserProfileService.getUserProfile(firebaseUser.uid);

      if (profile != null) {
        // Preencher campos com dados do Supabase
        emailController.text = profile.email ?? firebaseUser.email ?? '';
        
        // Aplicar máscara no telefone vindo do banco
        if (profile.telefone != null && profile.telefone!.isNotEmpty) {
          final unmaskedPhone = profile.telefone!.replaceAll(RegExp(r'[^0-9]'), '');
          phoneController.text = _phoneMaskFormatter.maskText(unmaskedPhone);
        }
        
        print('✅ Dados carregados do Supabase');
        print('   Email: ${emailController.text}');
        print('   Telefone: ${phoneController.text}');
      } else {
        // Usar dados do Firebase como fallback
        emailController.text = firebaseUser.email ?? '';
        print('⚠️ Perfil não encontrado, usando dados do Firebase');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar dados do usuário: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submete interesse na lista de espera
  Future<Result<void>> _submitWaitlist() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        errorMessage = 'Você precisa estar logado para continuar';
        return Result.error(Exception(errorMessage));
      }

      // Validar campos
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      if (email.isEmpty) {
        errorMessage = 'Por favor, preencha seu email';
        return Result.error(Exception(errorMessage));
      }

      if (!_isValidEmail(email)) {
        errorMessage = 'Por favor, insira um email válido';
        return Result.error(Exception(errorMessage));
      }

      print('📝 Salvando interesse na lista de espera...');
      print('   User: ${firebaseUser.uid}');
      print('   Email: $email');
      print('   Phone: $phone');

      // 1. Atualizar cadastro do usuário no Supabase (se modificou email ou telefone)
      await _updateUserProfileIfNeeded(firebaseUser.uid, email, phone);

      // 2. Salvar interesse na tabela subscription_interest
      final result = await _subscriptionRepository.registerInterest(
        userRef: firebaseUser.uid,
      );

      if (result.isOk) {
        print('✅ Interesse registrado com sucesso!');
        errorMessage = null;
        return Result.ok(null);
      } else {
        errorMessage = 'Erro ao salvar interesse. Tente novamente.';
        print('❌ Erro ao registrar interesse: ${result.asError.error}');
        return Result.error(result.asError.error);
      }
    } catch (e) {
      errorMessage = 'Erro ao salvar interesse. Tente novamente.';
      print('❌ Erro ao submeter lista de espera: $e');
      return Result.error(Exception(errorMessage));
    }
  }

  /// Atualiza perfil do usuário no Supabase se email ou telefone foram modificados
  Future<void> _updateUserProfileIfNeeded(String firebaseUid, String email, String phone) async {
    try {
      // Buscar perfil atual
      final currentProfile = await UserProfileService.getUserProfile(firebaseUid);
      
      bool needsUpdate = false;
      
      // Verificar se email foi modificado
      if (currentProfile?.email != email && email.isNotEmpty) {
        needsUpdate = true;
        print('📧 Email foi modificado, atualizando...');
      }
      
      // Verificar se telefone foi modificado
      if (currentProfile?.telefone != phone && phone.isNotEmpty) {
        needsUpdate = true;
        print('📱 Telefone foi modificado, atualizando...');
      }

      if (needsUpdate) {
        final success = await UserProfileService.updateUserProfile(
          firebaseUid: firebaseUid,
          telefone: phone.isNotEmpty ? phone : null,
        );

        if (success) {
          print('✅ Perfil atualizado no Supabase');
        } else {
          print('⚠️ Falha ao atualizar perfil no Supabase');
        }
      } else {
        print('ℹ️ Nenhuma atualização necessária no perfil');
      }
    } catch (e) {
      print('⚠️ Erro ao atualizar perfil: $e');
      // Não bloqueia o fluxo se atualização de perfil falhar
    }
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}