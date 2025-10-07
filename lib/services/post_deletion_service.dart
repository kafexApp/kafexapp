// lib/services/post_deletion_service.dart
import 'package:kafex/backend/supabase/supabase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDeletionService {
  /// Exclui um post do feed se o usuário for o autor
  /// IMPORTANTE: Busca o usuario_uid do post no banco e compara com o usuário atual
  static Future<bool> deletePost({required String postId}) async {
    try {
      // Obter o Firebase UID do usuário atual
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Usuário não está autenticado');
        return false;
      }

      final currentUserUid = currentUser.uid;

      print('🗑️ Verificando permissões para excluir post ID: $postId');
      print('   Current User UID: $currentUserUid');

      // Buscar o post para verificar se o usuario_uid corresponde ao usuário atual
      final postData = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .single();

      final postAuthorUid = postData['usuario_uid'] as String?;
      print('   Post Author UID: $postAuthorUid');

      // Verificar se o usuário atual é o autor
      if (postAuthorUid != currentUserUid) {
        print('❌ Usuário não autorizado a excluir este post');
        print('   O post pertence a outro usuário');
        return false;
      }

      print('✅ Permissão confirmada - excluindo post');

      // Exclui o post da tabela feed
      await SupaClient.client
          .from('feed')
          .delete()
          .eq('id', int.parse(postId))
          .eq('usuario_uid', currentUserUid); // Dupla verificação de segurança

      print('✅ Post excluído com sucesso');
      return true;
    } catch (e) {
      print('❌ Erro ao excluir post: $e');
      return false;
    }
  }

  /// Verifica se o usuário atual pode excluir o post
  /// Busca no banco e compara o usuario_uid
  static Future<bool> canDeletePost(String postId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final postData = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .single();

      final postAuthorUid = postData['usuario_uid'] as String?;
      return postAuthorUid == currentUser.uid;
    } catch (e) {
      print('❌ Erro ao verificar permissão: $e');
      return false;
    }
  }
}
