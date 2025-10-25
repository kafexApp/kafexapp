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
  
  // Formatter para máscara de telefone brasileiro
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+55 (##) #####-####',
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
        
        // Formatar telefone corretamente (remove duplicatas de código do país)
        final rawPhone = profile.telefone ?? '';
        phoneController.text = _formatPhoneNumber(rawPhone);
        
        print('✅ Dados carregados do Supabase');
        print('   Email: ${emailController.text}');
        print('   Telefone raw: $rawPhone');
        print('   Telefone formatado: ${phoneController.text}');
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
      
      // Formatar telefone para salvar no banco (apenas números com código do país)
      String? phoneToSave;
      if (phone.isNotEmpty) {
        // Remove tudo exceto números
        String numbersOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
        
        // Adiciona +55 se não tiver
        if (!numbersOnly.startsWith('55')) {
          numbersOnly = '55$numbersOnly';
        }
        
        phoneToSave = numbersOnly;
        print('📱 Telefone para salvar no banco: $phoneToSave');
      }
      
      // Verificar se telefone foi modificado
      if (phoneToSave != null) {
        // Comparar apenas números
        final currentPhoneNumbers = currentProfile?.telefone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
        if (currentPhoneNumbers != phoneToSave) {
          needsUpdate = true;
          print('📱 Telefone foi modificado, atualizando...');
        }
      }

      if (needsUpdate) {
        final success = await UserProfileService.updateUserProfile(
          firebaseUid: firebaseUid,
          telefone: phoneToSave,
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

  /// Formata número de telefone removendo duplicatas de código do país
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';

    // Remove todos os caracteres não numéricos e o +
    String numbersOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    print('📞 Formatando telefone:');
    print('   Original: $phone');
    print('   Apenas números: $numbersOnly');

    // Se começa com 55 (código do Brasil)
    if (numbersOnly.startsWith('55')) {
      // Remove o primeiro 55 (código do país)
      numbersOnly = numbersOnly.substring(2);
      print('   Removeu código do país, restante: $numbersOnly');
    }

    // Aplicar máscara brasileira
    // Formato esperado: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX
    if (numbersOnly.length == 11) {
      // Celular com 9 dígitos: (XX) XXXXX-XXXX
      return '+55 (${numbersOnly.substring(0, 2)}) ${numbersOnly.substring(2, 7)}-${numbersOnly.substring(7)}';
    } else if (numbersOnly.length == 10) {
      // Telefone fixo ou celular antigo: (XX) XXXX-XXXX
      return '+55 (${numbersOnly.substring(0, 2)}) ${numbersOnly.substring(2, 6)}-${numbersOnly.substring(6)}';
    } else if (numbersOnly.length > 11) {
      // Se tiver mais de 11 dígitos, pega os últimos 11
      numbersOnly = numbersOnly.substring(numbersOnly.length - 11);
      return '+55 (${numbersOnly.substring(0, 2)}) ${numbersOnly.substring(2, 7)}-${numbersOnly.substring(7)}';
    } else {
      // Número incompleto, retorna só os números
      return numbersOnly;
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