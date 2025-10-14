// lib/services/avaliacao_service.dart
import 'package:kafex/backend/supabase/supabase.dart';
import '../backend/supabase/tables/avaliacao_com_cafeteria.dart';

class AvaliacaoService {
  /// Busca todas as avaliações de uma cafeteria específica
  static Future<List<AvaliacaoComCafeteriaRow>> getAvaliacoesByCafeteria(
    int cafeteriaId,
  ) async {
    try {
      print('🔍 Buscando avaliações da cafeteria ID: $cafeteriaId');

      final response = await SupaClient.client
          .from('avaliacao_com_cafeteria')
          .select()
          .eq('cafeteria_id', cafeteriaId)
          .order('avaliacao_criada_em', ascending: false);

      print('✅ ${(response as List).length} avaliações encontradas');

      // Converte os resultados em objetos tipados
      return (response)
          .map((row) => AvaliacaoComCafeteriaRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar avaliações: $e');
      return [];
    }
  }

  /// Busca uma avaliação específica por ID
  static Future<AvaliacaoComCafeteriaRow?> getAvaliacaoById(
    int avaliacaoId,
  ) async {
    try {
      print('🔍 Buscando avaliação ID: $avaliacaoId');

      final response = await SupaClient.client
          .from('avaliacao_com_cafeteria')
          .select()
          .eq('avaliacao_id', avaliacaoId)
          .single();

      print('✅ Avaliação encontrada');

      return AvaliacaoComCafeteriaRow(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Erro ao buscar avaliação: $e');
      return null;
    }
  }

  /// Busca avaliações de um usuário específico
  static Future<List<AvaliacaoComCafeteriaRow>> getAvaliacoesByUser(
    int userId,
  ) async {
    try {
      print('🔍 Buscando avaliações do usuário ID: $userId');

      final response = await SupaClient.client
          .from('avaliacao_com_cafeteria')
          .select()
          .eq('user_id', userId)
          .order('avaliacao_criada_em', ascending: false);

      print('✅ ${(response as List).length} avaliações encontradas');

      return (response)
          .map((row) => AvaliacaoComCafeteriaRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar avaliações do usuário: $e');
      return [];
    }
  }

  /// Busca as avaliações mais recentes (feed global)
  static Future<List<AvaliacaoComCafeteriaRow>> getRecentAvaliacoes({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('🔍 Buscando avaliações recentes (limit: $limit, offset: $offset)');

      final response = await SupaClient.client
          .from('avaliacao_com_cafeteria')
          .select()
          .order('avaliacao_criada_em', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      print('✅ ${(response as List).length} avaliações encontradas');

      return (response)
          .map((row) => AvaliacaoComCafeteriaRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar avaliações recentes: $e');
      return [];
    }
  }

  /// Calcula a média de avaliações de uma cafeteria
  static Future<Map<String, dynamic>> getAvaliacaoStatsByCafeteria(
    int cafeteriaId,
  ) async {
    try {
      final avaliacoes = await getAvaliacoesByCafeteria(cafeteriaId);

      if (avaliacoes.isEmpty) {
        return {
          'total': 0,
          'media': 0.0,
          'distribuicao': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      // Calcula média
      double soma = 0;
      Map<int, int> distribuicao = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var avaliacao in avaliacoes) {
        final nota = avaliacao.nota ?? 0;
        soma += nota;

        // Conta distribuição por estrela
        final notaArredondada = nota.round();
        if (notaArredondada >= 1 && notaArredondada <= 5) {
          distribuicao[notaArredondada] =
              (distribuicao[notaArredondada] ?? 0) + 1;
        }
      }

      final media = soma / avaliacoes.length;

      return {
        'total': avaliacoes.length,
        'media': media,
        'distribuicao': distribuicao,
      };
    } catch (e) {
      print('❌ Erro ao calcular estatísticas: $e');
      return {
        'total': 0,
        'media': 0.0,
        'distribuicao': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }
}
