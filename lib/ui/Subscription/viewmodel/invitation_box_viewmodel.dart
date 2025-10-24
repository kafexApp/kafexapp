import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/user_manager.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class InvitationBoxViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  String? errorMessage;
  
  late Command0<void> loadUserData;
  late Command0<void> submitWaitlist;
  
  InvitationBoxViewModel() {
    loadUserData = Command0(_loadUserData)..execute();
    submitWaitlist = Command0(_submitWaitlist);
  }
  
  Future<Result<void>> _loadUserData() async {
    final userManager = UserManager.instance;
    final userId = userManager.userUid;

    if (userId.isEmpty) {
      return Result.ok(null);
    }

    try {
      final response = await Supabase.instance.client
          .from('usuario_perfil')
          .select('email, telefone')
          .eq('usuario_uid', userId)
          .maybeSingle();

      if (response != null) {
        emailController.text = response['email'] ?? '';
        phoneController.text = response['telefone'] ?? '';
        print('✅ Dados carregados: email=${emailController.text}, telefone=${phoneController.text}');
        notifyListeners();
      }
      
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao carregar dados do usuário: $e');
      return Result.error(Exception('Erro ao carregar dados'));
    }
  }
  
  Future<Result<void>> _submitWaitlist() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      errorMessage = 'Por favor, preencha email e telefone';
      notifyListeners();
      return Result.error(Exception(errorMessage));
    }

    errorMessage = null;

    try {
      final userManager = UserManager.instance;
      final userId = userManager.userUid;

      await Supabase.instance.client
          .from('usuario_perfil')
          .update({
            'email': email,
            'telefone': phone,
          })
          .eq('usuario_uid', userId);

      print('✅ Cadastro na lista de espera realizado com sucesso');
      return Result.ok(null);
      
    } catch (e) {
      print('❌ Erro ao salvar na lista de espera: $e');
      errorMessage = 'Erro ao salvar. Tente novamente.';
      notifyListeners();
      return Result.error(Exception(errorMessage));
    }
  }
  
  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}