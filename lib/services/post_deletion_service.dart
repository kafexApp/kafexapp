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
      
      final postIdInt = int.parse(postId);
      
      // 4. PRIMEIRO: Buscar IDs dos comentários deste post
      print('🔍 Buscando comentários do post...');
      final comentariosResponse = await SupaClient.client
          .from('comentario')
          .select('id')
          .eq('feed_id', postIdInt);
      
      final comentariosIds = (comentariosResponse as List)
          .map((c) => c['id'] as int)
          .toList();
      
      print('📋 Encontrados ${comentariosIds.length} comentários');
      
      // 5. SEGUNDO: Excluir notificações vinculadas aos comentários
      if (comentariosIds.isNotEmpty) {
        print('🗑️ Excluindo notificações dos comentários...');
        await SupaClient.client
            .from('notificacao')
            .delete()
            .inFilter('comentario_id', comentariosIds);
        
        print('✅ Notificações excluídas');
      }
      
      // 6. TERCEIRO: Excluir notificações vinculadas diretamente ao post
      print('🗑️ Excluindo notificações do post...');
      await SupaClient.client
          .from('notificacao')
          .delete()
          .eq('feed_id', postIdInt);
      
      print('✅ Notificações do post excluídas');
      
      // 7. QUARTO: Excluir os comentários do post
      print('🗑️ Excluindo comentários do post...');
      await SupaClient.client
          .from('comentario')
          .delete()
          .eq('feed_id', postIdInt);
      
      print('✅ Comentários excluídos');
      
      // 8. POR ÚLTIMO: Excluir o post da tabela feed
      print('🗑️ Excluindo post...');
      await SupaClient.client
          .from('feed')
          .delete()
          .eq('id', postIdInt)
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