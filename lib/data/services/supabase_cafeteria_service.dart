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

        final distance = _calculateDistance(
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

  /// Busca cafeterias por nome (para autocompletar)
  Future<List<Map<String, dynamic>>> searchCafeteriasByName(String query) async {
    try {
      if (query.isEmpty) return [];

      print('🔍 Buscando cafeterias por nome: "$query"');

      final response = await _client
          .from('cafeteria')
          .select()
          .eq('ativo', true)
          .ilike('nome', '%$query%')
          .limit(10);

      final results = List<Map<String, dynamic>>.from(response);
      print('✅ ${results.length} cafeterias encontradas');

      return results;
    } catch (e) {
      print('❌ Erro ao buscar cafeterias por nome: $e');
      return [];
    }
  }

  /// ✅ NOVO: Verifica se uma cafeteria já existe no banco de dados
  /// Retorna um Map com os dados da cafeteria se existir, ou null se não existir
  Future<Map<String, dynamic>?> checkCafeteriaExists({
    String? nome,
    double? latitude,
    double? longitude,
    double radiusKm = 0.1, // 100 metros de raio para considerar duplicata
  }) async {
    try {
      print('══════════════════════════════');
      print('🔍 VERIFICANDO DUPLICATA');
      if (nome != null) print('📝 Nome: $nome');
      if (latitude != null && longitude != null) {
        print('📍 Coordenadas: ($latitude, $longitude)');
        print('📏 Raio de busca: ${radiusKm * 1000}m');
      }
      print('══════════════════════════════');

      // ✅ ESTRATÉGIA 1: Buscar por nome exato (case-insensitive)
      if (nome != null && nome.isNotEmpty) {
        print('🔍 [1/2] Buscando por nome...');
        
        final responseByName = await _client
            .from('cafeteria')
            .select()
            .ilike('nome', nome)
            .maybeSingle();

        if (responseByName != null) {
          print('⚠️ DUPLICATA ENCONTRADA POR NOME!');
          print('🆔 ID: ${responseByName['id']}');
          print('📝 Nome: ${responseByName['nome']}');
          print('📍 Endereço: ${responseByName['endereco']}');
          print('══════════════════════════════');
          return responseByName;
        }
        
        print('✅ Nenhuma duplicata por nome');
      }

      // ✅ ESTRATÉGIA 2: Buscar por proximidade de coordenadas
      if (latitude != null && longitude != null) {
        print('🔍 [2/2] Buscando por proximidade...');
        
        final responseByLocation = await _client
            .from('cafeteria')
            .select()
            .not('lat', 'is', null)
            .not('lng', 'is', null);

        final allCafeterias = List<Map<String, dynamic>>.from(responseByLocation);

        // Verificar proximidade
        for (var cafe in allCafeterias) {
          final cafeLat = cafe['lat'] as double?;
          final cafeLng = cafe['lng'] as double?;

          if (cafeLat == null || cafeLng == null) continue;

          final distance = _calculateDistance(
            latitude,
            longitude,
            cafeLat,
            cafeLng,
          );

          if (distance <= radiusKm) {
            print('⚠️ DUPLICATA ENCONTRADA POR PROXIMIDADE!');
            print('🆔 ID: ${cafe['id']}');
            print('📝 Nome: ${cafe['nome']}');
            print('📍 Endereço: ${cafe['endereco']}');
            print('📏 Distância: ${(distance * 1000).toStringAsFixed(0)}m');
            print('══════════════════════════════');
            return cafe;
          }
        }
        
        print('✅ Nenhuma duplicata por proximidade');
      }

      print('✅ Local NOVO - Pode cadastrar!');
      print('══════════════════════════════');
      return null;
    } catch (e) {
      print('❌ Erro ao verificar duplicata: $e');
      print('══════════════════════════════');
      return null;
    }
  }

  /// Cria uma nova cafeteria no banco de dados
  Future<int?> createCafeteria({
    required String nome,
    required String endereco,
    required double latitude,
    required double longitude,
    required String usuarioUid,
    required int userId,
    String? telefone,
    String? instagram,
    String? urlFoto,
    String? bairro,
    String? cidade,
    String? estado,
    bool petFriendly = false,
    bool opcaoVegana = false,
    bool officeFriendly = false,
  }) async {
    try {
      print('══════════════════════════════');
      print('💾 CRIANDO CAFETERIA NO SUPABASE');
      print('📝 Nome: $nome');
      print('📍 Endereço: $endereco');
      print('🗺️  Coordenadas: ($latitude, $longitude)');
      print('══════════════════════════════');

      final data = {
        'nome': nome,
        'endereco': endereco,
        'lat': latitude,
        'lng': longitude,
        'referencia_mapa': 'LatLng(lat: $latitude, lng: $longitude)',
        'usuario_uid': usuarioUid,
        'user_id': userId,
        'telefone': telefone,
        'instagram': instagram,
        'url_foto': urlFoto,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'pet_friendly': petFriendly,
        'opcao_vegana': opcaoVegana,
        'ativo': false, // ✅ Cafeteria precisa ser aprovada antes de aparecer
        'pontuacao': 0,
        'avaliacoes': 0,
      };

      print('📤 Inserindo dados no banco...');

      final response = await _client
          .from('cafeteria')
          .insert(data)
          .select('id')
          .single();

      final cafeteriaId = response['id'] as int;
      
      print('══════════════════════════════');
      print('✅ CAFETERIA CRIADA COM SUCESSO!');
      print('🆔 ID: $cafeteriaId');
      print('⚠️  Status: INATIVA (aguardando aprovação)');
      print('══════════════════════════════');

      return cafeteriaId;
    } catch (e, stackTrace) {
      print('══════════════════════════════');
      print('❌ ERRO AO CRIAR CAFETERIA');
      print('Erro: $e');
      print('Stack: $stackTrace');
      print('══════════════════════════════');
      rethrow;
    }
  }

  /// Calcula a distância entre dois pontos em km (fórmula de Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Raio da Terra em km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}