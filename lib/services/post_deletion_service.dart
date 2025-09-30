// lib/services/post_deletion_service.dart
import 'package:kafex/backend/supabase/supabase.dart';
import '../utils/user_manager.dart';

class PostDeletionService {
  /// Exclui um post do feed se o usuário for o autor
  static Future<bool> deletePost({
    required String postId,
    required String authorEmail,
  }) async {
    try {
      final userManager = UserManager.instance;
      final currentUserEmail = userManager.userEmail;
      
      // Verifica se o usuário atual é o autor do post
      if (currentUserEmail != authorEmail) {
        print('❌ Usuário não autorizado a excluir este post');
        print('   Usuário atual: $currentUserEmail');
        print('   Autor do post: $authorEmail');
        return false;
      }
      
      print('🗑️ Excluindo post ID: $postId');
      print('   Autor: $authorEmail');
      
      // Exclui o post da tabela feed
      final response = await SupaClient.client
          .from('feed')
          .delete()
          .eq('id', int.parse(postId))
          .eq('usuario_uid', authorEmail); // Dupla verificação de segurança
      
      print('✅ Post excluído com sucesso');
      return true;
      
    } catch (e) {
      print('❌ Erro ao excluir post: $e');
      return false;
    }
  }
  
  /// Verifica se o usuário atual pode excluir o post
  static bool canDeletePost(String authorEmail) {
    final userManager = UserManager.instance;
    final currentUserEmail = userManager.userEmail;
    return currentUserEmail == authorEmail;
  }
}