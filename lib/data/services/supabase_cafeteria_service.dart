// lib/data/services/supabase_cafeteria_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import '../../backend/supabase/supabase.dart';

/// Service para interagir com a tabela 'cafeteria' no Supabase
class SupabaseCafeteriaService {
  final SupabaseClient _client = SupaClient.client;

  Future<Map<String, dynamic>?> checkCafeteriaByPlaceId(String placeId) async {
    try {
      print('🔍 [Supabase] Buscando por place_id: $placeId');

      final response = await _client
          .from('cafeteria')
          .select()
          .eq('referencia_mapa', placeId)
          .maybeSingle();

      if (response != null) {
        print('⚠️ [Supabase] Cafeteria encontrada com este place_id');
        return response;
      }

      print('✅ [Supabase] Nenhuma cafeteria com este place_id');
      return null;
    } catch (e) {
      print('❌ [Supabase] Erro ao buscar por place_id: $e');
      return null;
    }
  }

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

  Future<Map<String, dynamic>?> getCafeteriaById(int cafeteriaId) async {
    try {
      print('🔍 Buscando cafeteria ID: $cafeteriaId');

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

  Future<List<Map<String, dynamic>>> getCafeteriasNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _client
          .from('cafeteria')
          .select()
          .eq('ativo', true)
          .not('lat', 'is', null)
          .not('lng', 'is', null);

      final allCafeterias = List<Map<String, dynamic>>.from(response);

      final nearbyCafeterias = allCafeterias.where((cafe) {
        final cafeLat = (cafe['lat'] as num?)?.toDouble();
        final cafeLng = (cafe['lng'] as num?)?.toDouble();

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

  Future<Map<String, dynamic>?> checkCafeteriaExists({
    String? nome,
    double? latitude,
    double? longitude,
    double radiusKm = 0.05,
  }) async {
    try {
      print('══════════════════════════════');
      print('🔍 VERIFICANDO DUPLICATA');
      if (nome != null) print('📝 Nome buscado: $nome');
      if (latitude != null && longitude != null) {
        print('📍 Coordenadas: ($latitude, $longitude)');
        print('📏 Raio de busca: ${(radiusKm * 1000).toInt()}m');
      }
      print('══════════════════════════════');

      final response = await _client.from('cafeteria').select();
      final allCafeterias = List<Map<String, dynamic>>.from(response);
      
      print('📊 Total de cafeterias no banco: ${allCafeterias.length}');

      if (latitude == null || longitude == null) {
        print('⚠️ Coordenadas não fornecidas');
        return null;
      }

      print('🔍 Iniciando verificação de proximidade...');
      
      int comLatLng = 0;
      int comReferenciaMapa = 0;
      int cafeteriasVerificadas = 0;

      for (var cafe in allCafeterias) {
        double? cafeLat;
        double? cafeLng;
        
        cafeLat = (cafe['lat'] as num?)?.toDouble();
        cafeLng = (cafe['lng'] as num?)?.toDouble();
        
        if (cafeLat != null && cafeLng != null) {
          comLatLng++;
        }
        
        if ((cafeLat == null || cafeLng == null) && cafe['referencia_mapa'] != null) {
          final refMapa = cafe['referencia_mapa'] as String;
          final coords = _extractCoordinatesFromReferenciaMapa(refMapa);
          if (coords != null) {
            cafeLat = coords['lat'];
            cafeLng = coords['lng'];
            comReferenciaMapa++;
            
            if (cafe['nome'].toString().toLowerCase().contains('andante')) {
              print('🔍 ENCONTREI ANDANTE!');
              print('   Nome: ${cafe['nome']}');
              print('   Ref: $refMapa');
              print('   Lat: $cafeLat, Lng: $cafeLng');
            }
          }
        }

        if (cafeLat == null || cafeLng == null) continue;
        
        cafeteriasVerificadas++;

        final distance = _calculateDistance(latitude, longitude, cafeLat, cafeLng);
        
        if (distance <= 1.0) {
          print('   📍 ${cafe['nome']} - ${(distance * 1000).toInt()}m');
        }

        if (distance <= radiusKm) {
          print('⚠️ DUPLICATA POR PROXIMIDADE!');
          print('🆔 ID: ${cafe['id']}');
          print('📝 Nome: ${cafe['nome']}');
          print('📏 Distância: ${(distance * 1000).toInt()}m');
          print('══════════════════════════════');
          return cafe;
        }
      }

      print('📊 Resumo:');
      print('   Total verificadas: $cafeteriasVerificadas');
      print('   Com lat/lng: $comLatLng');
      print('   Com referencia_mapa: $comReferenciaMapa');
      print('✅ Nenhuma duplicata');
      print('══════════════════════════════');
      return null;
    } catch (e, stack) {
      print('❌ Erro: $e');
      print('Stack: $stack');
      return null;
    }
  }

  Future<int?> createCafeteria({
    required String nome,
    required String endereco,
    required double latitude,
    required double longitude,
    required String usuarioUid,
    required int userId,
    String? referenciaMapa,
    String? ref,
    String? telefone,
    String? instagram,
    String? urlFoto,
    String? bairro,
    String? cidade,
    String? estado,
    String? pais,
    String? cep,
    bool petFriendly = false,
    bool opcaoVegana = false,
    bool officeFriendly = false,
  }) async {
    try {
      final data = {
        'nome': nome,
        'endereco': endereco,
        'lat': latitude,
        'lng': longitude,
        'referencia_mapa': referenciaMapa,
        'ref': ref,
        'usuario_uid': usuarioUid,
        'user_id': userId,
        'telefone': telefone,
        'instagram': instagram,
        'url_foto': urlFoto,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'pais': pais,
        'cep': cep,
        'pet_friendly': petFriendly,
        'opcao_vegana': opcaoVegana,
        'office_friendly': officeFriendly,
        'ativo': false,
        'pontuacao': 0.0,
        'avaliacoes': 0,
      };

      print('📦 Dados sendo inseridos:');
      print('   Nome: $nome');
      print('   Lat/Lng: ($latitude, $longitude)');
      print('   referencia_mapa: $referenciaMapa');
      print('   ref: $ref');
      print('   cep: $cep');

      final response = await _client
          .from('cafeteria')
          .insert(data)
          .select('id')
          .single();

      final cafeteriaId = response['id'] as int;
      print('✅ Cafeteria inserida com ID: $cafeteriaId');
      
      return cafeteriaId;
    } catch (e) {
      print('❌ Erro ao criar cafeteria: $e');
      rethrow;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
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

  double _toRadians(double degrees) => degrees * math.pi / 180;

  Map<String, double>? _extractCoordinatesFromReferenciaMapa(String ref) {
    try {
      final latMatch = RegExp(r'lat:\s*(-?\d+\.?\d*)').firstMatch(ref);
      final lngMatch = RegExp(r'lng:\s*(-?\d+\.?\d*)').firstMatch(ref);
      
      if (latMatch != null && lngMatch != null) {
        return {
          'lat': double.parse(latMatch.group(1)!),
          'lng': double.parse(lngMatch.group(1)!),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}