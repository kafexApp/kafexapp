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

  /// Verifica se uma cafeteria já existe nas coordenadas
  /// Considera duplicata se houver cafeteria num raio de 50 metros
  Future<Map<String, dynamic>?> checkCafeteriaExists({
    required double latitude,
    required double longitude,
  }) async {
    try {
      print('');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║         🔍 VERIFICAÇÃO DE DUPLICATA - INÍCIO               ║');
      print('╚════════════════════════════════════════════════════════════╝');
      print('📍 Buscando coordenadas: ($latitude, $longitude)');
      print('⚡ Raio de verificação: 50 metros');
      print('');

      // Buscar todas as cafeterias (ativas e inativas para evitar duplicatas)
      print('📦 Consultando banco de dados...');
      final response = await _client
          .from('cafeteria')
          .select()
          .not('lat', 'is', null)
          .not('lng', 'is', null);

      final allCafeterias = List<Map<String, dynamic>>.from(response);
      print('✅ ${allCafeterias.length} cafeterias encontradas no banco');
      print('');
      print('🔄 Calculando distâncias...');
      print('─────────────────────────────────────────────────────────────');

      // Buscar cafeterias num raio de 50 metros (0.05 km)
      const radiusKm = 0.05;
      int checkedCount = 0;
      
      for (final cafe in allCafeterias) {
        final cafeLat = cafe['lat'] as double?;
        final cafeLng = cafe['lng'] as double?;

        if (cafeLat == null || cafeLng == null) continue;

        checkedCount++;

        final distance = _calculateDistance(
          latitude,
          longitude,
          cafeLat,
          cafeLng,
        );

        final distanceMeters = distance * 1000;

        // Mostrar todas cafeterias num raio de 5km para debug
        if (distance < 5.0) {
          final distStr = distanceMeters < 1000 
              ? '${distanceMeters.toStringAsFixed(0)}m'
              : '${distance.toStringAsFixed(2)}km';
          print('   📍 ${cafe['nome']}: $distStr');
        }

        // VERIFICAR SE ESTÁ DENTRO DO RAIO DE 50M
        if (distance <= radiusKm) {
          print('');
          print('╔════════════════════════════════════════════════════════════╗');
          print('║            ⚠️  DUPLICATA DETECTADA! ⚠️                     ║');
          print('╚════════════════════════════════════════════════════════════╝');
          print('📏 Distância: ${distanceMeters.toStringAsFixed(2)}m');
          print('📝 Nome: ${cafe['nome']}');
          print('🆔 ID: ${cafe['id']}');
          print('📊 Status: ${cafe['ativo'] ? '🟢 ATIVA' : '🟡 INATIVA'}');
          print('🗺️  Coordenadas DB: (${cafeLat}, ${cafeLng})');
          print('🗺️  Coordenadas Google: ($latitude, $longitude)');
          print('📌 Ref: ${cafe['referencia_mapa']}');
          print('════════════════════════════════════════════════════════════');
          print('');
          return cafe;
        }
      }

      print('');
      print('─────────────────────────────────────────────────────────────');
      print('✅ Verificação completa: $checkedCount cafeterias analisadas');
      print('✅ Nenhuma duplicata encontrada no raio de 50m');
      print('✅ Local LIBERADO para cadastro');
      print('╚════════════════════════════════════════════════════════════╝');
      print('');
      
      return null;
    } catch (e) {
      print('');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║                   ❌ ERRO NA VERIFICAÇÃO                   ║');
      print('╚════════════════════════════════════════════════════════════╝');
      print('Erro: $e');
      print('════════════════════════════════════════════════════════════');
      print('');
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
      print('══════════════');
      print('💾 Criando cafeteria no Supabase');
      print('📝 Nome: $nome');
      print('📍 Endereço: $endereco');
      print('══════════════');

      // ✅ VALIDAR SE JÁ EXISTE (raio de 50m)
      final existing = await checkCafeteriaExists(
        latitude: latitude,
        longitude: longitude,
      );

      if (existing != null) {
        print('❌ Cafeteria já cadastrada: ${existing['nome']}');
        throw Exception('Ops! Já existe uma cafeteria cadastrada nesta localização: ${existing['nome']}');
      }

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
        // 'work_friendly': officeFriendly, // ❌ Coluna não existe no banco
        'ativo': false, // ✅ Cafeteria precisa ser aprovada antes de aparecer
        'pontuacao': 0,
        'avaliacoes': 0,
      };

      final response = await _client
          .from('cafeteria')
          .insert(data)
          .select('id')
          .single();

      final cafeteriaId = response['id'] as int;
      
      print('✅ Cafeteria criada com sucesso!');
      print('🆔 ID: $cafeteriaId');
      print('⚠️ Status: INATIVA (aguardando aprovação)');
      print('══════════════');

      return cafeteriaId;
    } catch (e, stackTrace) {
      print('❌ Erro ao criar cafeteria: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow; // ← IMPORTANTE: propagar o erro para ser tratado na UI
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