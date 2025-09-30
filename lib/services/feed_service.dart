import 'package:kafex/backend/supabase/supabase.dart';
import '../backend/supabase/tables/feed_com_usuario.dart';

class FeedService {
  /// Busca posts do feed ordenados por data de criação
  static Future<List<FeedComUsuarioRow>> getFeed({
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final response = await SupaClient.client
          .from('feed_com_usuario')
          .select()
          .order('criado_em', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // Converte os resultados em objetos tipados
      return (response as List)
          .map((row) => FeedComUsuarioRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar feed: $e');
      return [];
    }
  }

  /// Exclui um post do feed
  static Future<bool> deletePost(String postId) async {
    try {
      print('🗑️ Iniciando exclusão do post ID: $postId');
      
      // Converte string para int se necessário
      final int? id = int.tryParse(postId);
      if (id == null) {
        print('❌ ID do post inválido: $postId');
        return false;
      }

      // Exclui da tabela 'feed' (não da view 'feed_com_usuario')
      final response = await SupaClient.client
          .from('feed')
          .delete()
          .eq('id', id)
          .select();

      print('🗑️ Resposta da exclusão: $response');
      
      // Se chegou até aqui sem erro, a exclusão foi bem-sucedida
      print('✅ Post excluído com sucesso do banco de dados');
      return true;
      
    } catch (e) {
      print('❌ Erro ao excluir post: $e');
      
      // Se for erro de autenticação, não redireciona para login
      // Apenas retorna false para mostrar mensagem de erro
      return false;
    }
  }

  /// Verifica se o usuário atual é dono do post
  static Future<bool> canDeletePost(String postId, String currentUserUid) async {
    try {
      final response = await SupaClient.client
          .from('feed')
          .select('usuario_uid')
          .eq('id', int.parse(postId))
          .single();

      final postOwnerUid = response['usuario_uid'] as String?;
      return postOwnerUid == currentUserUid;
      
    } catch (e) {
      print('❌ Erro ao verificar permissão do post: $e');
      return false;
    }
  }
}