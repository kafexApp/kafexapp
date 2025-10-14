// lib/services/post_deletion_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kafex/backend/supabase/supabase.dart';

class PostDeletionService {
  /// Exclui um post do feed se o usuário for o autor
  /// Agora recebe apenas postId e busca o usuario_uid do banco
  static Future<bool> deletePost(String postId) async {
    try {
      // 1. Obter o Firebase UID do usuário atual
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ Usuário não autenticado');
        return false;
      }
      
      final currentUserUid = currentUser.uid;
      print('🔍 Verificando permissão para excluir post');
      print('   Post ID: $postId');
      print('   Current User UID: $currentUserUid');
      
      // 2. Buscar o usuario_uid do post no banco
      final postResponse = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .maybeSingle();
      
      if (postResponse == null) {
        print('❌ Post não encontrado');
        return false;
      }
      
      final postAuthorUid = postResponse['usuario_uid'] as String?;
      print('   Post Author UID: $postAuthorUid');
      
      // 3. Verificar se o usuário atual é o autor do post
      if (postAuthorUid != currentUserUid) {
        print('❌ Usuário não autorizado a excluir este post');
        return false;
      }
      
      print('✅ Permissão verificada, excluindo post...');
      
      // 4. Excluir o post da tabela feed
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
  /// Busca o usuario_uid do post no banco e compara com o Firebase UID atual
  static Future<bool> canDeletePost(String postId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;
      
      final postResponse = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .maybeSingle();
      
      if (postResponse == null) return false;
      
      final postAuthorUid = postResponse['usuario_uid'] as String?;
      return postAuthorUid == currentUser.uid;
      
    } catch (e) {
      print('❌ Erro ao verificar permissão: $e');
      return false;
    }
  }
}