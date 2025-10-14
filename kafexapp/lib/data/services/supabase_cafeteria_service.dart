// lib/data/services/supabase_cafeteria_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import '../../backend/supabase/supabase.dart';

/// Service para interagir com a tabela 'cafeteria' no Supabase
class SupabaseCafeteriaService {
  final SupabaseClient _client = SupaClient.client;

  /// Busca todas as cafeterias ativas
  Future<List<Map<String, dynamic>>> getAllCafeterias() async {
    try {
      final response = await _client
          .from('cafeteria')
          .select()
          .eq('ativo', true)
          .order('criado_em', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar cafeterias: $e');
      rethrow;
    }
  }

  /// Busca uma cafeteria específica por ID com dados do usuário criador
  Future<Map<String, dynamic>?> getCafeteriaById(int cafeteriaId) async {
    try {
      print('🔍 Buscando cafeteria ID: $cafeteriaId');

      // Buscar cafeteria com JOIN no usuario_perfil
      final response = await _client
          .from('cafeteria')
          .select('''
            *,
            usuario_perfil!cafeteria_user_id_fkey (
              id,
              nome_exibicao,
              foto_url,
              instagram,
              cidade
            )
          ''')
          .eq('id', cafeteriaId)
          .eq('ativo', true)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Cafeteria não encontrada ou inativa');
        return null;
      }

      print('✅ Cafeteria encontrada: ${response['nome']}');
      return response;
    } catch (e) {
      print('❌ Erro ao buscar cafeteria por ID: $e');
      return null;
    }
  }

  /// Busca cafeterias próximas a uma localização (raio em km)
  Future<List<Map<String, dynamic>>> getCafeteriasNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      // Buscar todas as cafeterias ativas
      final response = await _client
          .from('cafeteria')
          .select()
          .eq('ativo', true)
          .not('lat', 'is', null)
          .not('lng', 'is', null);

      final allCafeterias = List<Map<String, dynamic>>.from(response);

      // Filtrar por proximidade usando cálculo de distância
      final nearbyCafeterias = allCafeterias.where((cafe) {
        final cafeLat = cafe['lat'] as double?;
        final cafeLng = cafe['lng'] as double?;

        if (cafeLat == null || cafeLng == null) return false;

        final distance = _calculateDistanceKm(
          latitude,
          longitude,
          cafeLat,
          cafeLng,
        );

        return distance <= radiusKm;
      }).toList();

      return nearbyCafeterias;
    } catch (e) {
      print('❌ Erro ao buscar cafeterias próximas: $e');
      rethrow;
    }
  }

  /// Busca cafeterias por nome (para autocomplete/busca)
  Future<List<Map<String, dynamic>>> searchCafeteriasByName(
      String query) async {
    try {
      final response = await _client
          .from('cafeteria')
          .select()
          .eq('ativo', true)
          .or('nome.ilike.%$query%,endereco.ilike.%$query%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar cafeterias por nome: $e');
      return [];
    }
  }

  /// Calcula distância entre dois pontos em km (fórmula de Haversine)
  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}