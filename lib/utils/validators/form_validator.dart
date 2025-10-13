// lib/utils/validators/form_validator.dart

class FormValidator {
  // Validar nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu nome';
    }
    if (value.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, digite um email válido';
    }
    
    return null;
  }

  // Validar telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu telefone';
    }
    
    // Remove caracteres não numéricos
    final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numbersOnly.length < 10) {
      return 'Telefone inválido';
    }
    
    return null;
  }

  // Validar senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite sua senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  // Validar confirmação de senha
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    
    if (value != password) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }

  // Validar termos
  static String? validateTerms(bool accepted) {
    if (!accepted) {
      return 'Você deve aceitar os termos de uso';
    }
    return null;
  }

  // Validar todos os campos do formulário de cadastro
  static Map<String, String?> validateCreateAccountForm({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) {
    return {
      'name': validateName(name),
      'email': validateEmail(email),
      'phone': validatePhone(phone),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(confirmPassword, password),
      'terms': validateTerms(termsAccepted),
    };
  }

  // Verificar se o formulário é válido
  static bool isFormValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  // Obter primeira mensagem de erro
  static String? getFirstError(Map<String, String?> validationResults) {
    for (var error in validationResults.values) {
      if (error != null) return error;
    }
    return null;
  }
}