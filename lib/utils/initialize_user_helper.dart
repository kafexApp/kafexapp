// lib/utils/initialize_user_helper.dart
import 'user_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InitializeUserHelper {
  /// Inicializa dados básicos do usuário se ainda não foram configurados
  static Future<void> ensureUserDataInitialized() async {
    final userManager = UserManager.instance;
    await userManager.loadUserData();
    
    // Se não há dados do usuário salvos, tenta obter do Firebase Auth
    if (!userManager.hasUser) {
      await _initializeFromFirebaseAuth();
    }
    
    print('👤 Dados do usuário inicializados:');
    print('   Nome: ${userManager.userName}');
    print('   Email: ${userManager.userEmail}');
    print('   Foto: ${userManager.userPhotoUrl ?? 'Sem foto'}');
  }
  
  /// Tenta obter dados do Firebase Auth se disponível
  static Future<void> _initializeFromFirebaseAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final displayName = user.displayName ?? _extractNameFromEmail(user.email ?? '');
        final email = user.email ?? 'usuario@kafex.com';
        final photoUrl = user.photoURL;
        
        UserManager.instance.setUserData(
          name: displayName,
          email: email,
          photoUrl: photoUrl,
        );
        
        print('✅ Dados obtidos do Firebase Auth');
      } else {
        // Se não há usuário no Firebase, usa dados padrão
        _setDefaultUserData();
      }
    } catch (e) {
      print('⚠️ Erro ao obter dados do Firebase Auth: $e');
      _setDefaultUserData();
    }
  }
  
  /// Define dados padrão do usuário
  static void _setDefaultUserData() {
    UserManager.instance.setUserData(
      name: 'Usuário Kafex',
      email: 'usuario@kafex.com',
      photoUrl: null,
    );
    print('📝 Dados padrão definidos para o usuário');
  }
  
  /// Extrai nome do email
  static String _extractNameFromEmail(String email) {
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
}