// lib/services/auth_state_handler.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/user_manager.dart';
import '../utils/sync_user_photo_helper.dart';

class AuthStateHandler {
  static Future<void> syncUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      print('🔄 Sincronizando dados do usuário...');
      
      // Recarregar dados do Firebase Auth
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      
      if (updatedUser != null) {
        // Atualizar UserManager com dados mais recentes
        UserManager.instance.setUserData(
          uid: updatedUser.uid,
          name: updatedUser.displayName ?? 'Usuário Kafex',
          email: updatedUser.email ?? '',
          photoUrl: updatedUser.photoURL,
        );
        
        // Limpar cache de imagens antigas
        if (updatedUser.photoURL != null) {
          await CachedNetworkImage.evictFromCache(updatedUser.photoURL!);
        }
        
        print('✅ Dados sincronizados com sucesso');
        print('   Nome: ${updatedUser.displayName}');
        print('   Email: ${updatedUser.email}');
        if (updatedUser.photoURL != null) {
          print('   Foto: ${updatedUser.photoURL!.substring(0, 50)}...');
        }
      }
    } else {
      print('⚠️ Nenhum usuário logado para sincronizar');
    }
  }
  
  static Future<void> clearAllCache() async {
    try {
      await CachedNetworkImage.evictFromCache('');
      print('🗑️ Cache de imagens limpo');
    } catch (e) {
      print('⚠️ Erro ao limpar cache: $e');
    }
  }
}