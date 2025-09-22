// lib/utils/user_manager.dart
// Classe simples para gerenciar dados do usuário logado

class UserManager {
  static UserManager? _instance;
  UserManager._internal();
  
  static UserManager get instance {
    _instance ??= UserManager._internal();
    return _instance!;
  }

  // Dados do usuário atual
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;

  // Getters
  String get userName => _userName ?? 'Usuário Kafex';
  String get userEmail => _userEmail ?? 'usuario@kafex.com';
  String? get userPhotoUrl => _userPhotoUrl;

  // Setter para salvar dados do usuário
  void setUserData({
    required String name,
    required String email,
    String? photoUrl,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
    
    print('✅ Dados do usuário salvos: $name - $email');
  }

  // Método para extrair nome do email
  String extractNameFromEmail(String email) {
    if (email.contains('@')) {
      String emailPrefix = email.split('@')[0];
      
      // Se tem pontos ou underscores, separa e capitaliza
      if (emailPrefix.contains('.') || emailPrefix.contains('_')) {
        return emailPrefix
            .replaceAll('_', '.')
            .split('.')
            .map((word) => word.isNotEmpty 
                ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
                : '')
            .join(' ')
            .trim();
      } else {
        // Apenas capitaliza a primeira letra
        return emailPrefix.isNotEmpty 
            ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1).toLowerCase()
            : 'Usuário Kafex';
      }
    }
    return 'Usuário Kafex';
  }

  // Limpar dados do usuário (logout)
  void clearUserData() {
    _userName = null;
    _userEmail = null;
    _userPhotoUrl = null;
    print('🚪 Dados do usuário limpos');
  }

  // Verificar se há usuário logado
  bool get hasUser => _userName != null && _userEmail != null;
}