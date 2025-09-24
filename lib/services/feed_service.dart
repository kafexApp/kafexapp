import 'package:kafex/backend/supabase/supabase.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';

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
}
