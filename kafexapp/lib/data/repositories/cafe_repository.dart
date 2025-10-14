// lib/data/repositories/cafe_repository.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../models/domain/cafe.dart';
import '../services/supabase_cafeteria_service.dart';

/// Interface abstrata do repositório de cafeterias
abstract class CafeRepository {
  Future<List<Cafe>> getAllCafes();
  Future<List<Cafe>> getCafesNearLocation(LatLng location, {double radiusKm = 2.0});
  Future<Map<String, dynamic>?> getCafeById(int cafeId);
}

/// Implementação REAL do repositório usando Supabase
class CafeRepositoryImpl implements CafeRepository {
  final SupabaseCafeteriaService _service;

  CafeRepositoryImpl({SupabaseCafeteriaService? service})
      : _service = service ?? SupabaseCafeteriaService();

  @override
  Future<List<Cafe>> getAllCafes() async {
    try {
      print('🔍 Buscando cafeterias no Supabase...');
      
      final cafeteriasData = await _service.getAllCafeterias();
      
      print('✅ ${cafeteriasData.length} cafeterias encontradas no Supabase');
      
      // Converter dados do Supabase para modelo de domínio
      final cafes = cafeteriasData
          .map((data) => _mapSupabaseToCafe(data))
          .where((cafe) => cafe != null)
          .cast<Cafe>()
          .toList();

      print('✅ ${cafes.length} cafeterias mapeadas com sucesso');
      return cafes;
    } catch (e) {
      print('❌ Erro ao buscar cafeterias: $e');
      return [];
    }
  }

  @override
  Future<List<Cafe>> getCafesNearLocation(
    LatLng location, {
    double radiusKm = 2.0,
  }) async {
    try {
      print('📍 Buscando cafeterias próximas a: (${location.latitude}, ${location.longitude})');
      
      final cafeteriasData = await _service.getCafeteriasNearLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: radiusKm,
      );

      print('✅ ${cafeteriasData.length} cafeterias encontradas no raio de ${radiusKm}km');

      final cafes = cafeteriasData
          .map((data) => _mapSupabaseToCafe(data, referenceLocation: location))
          .where((cafe) => cafe != null)
          .cast<Cafe>()
          .toList();

      cafes.sort((a, b) {
        double distA = _calculateDistanceKm(location, a.position);
        double distB = _calculateDistanceKm(location, b.position);
        return distA.compareTo(distB);
      });

      return cafes;
    } catch (e) {
      print('❌ Erro ao buscar cafeterias próximas: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getCafeById(int cafeId) async {
    try {
      print('🔍 Buscando cafeteria por ID: $cafeId');
      
      final cafeData = await _service.getCafeteriaById(cafeId);
      
      if (cafeData == null) {
        print('⚠️ Cafeteria não encontrada');
        return null;
      }

      print('✅ Cafeteria encontrada: ${cafeData['nome']}');
      return cafeData;
    } catch (e) {
      print('❌ Erro ao buscar cafeteria por ID: $e');
      return null;
    }
  }

  /// Mapeia dados do Supabase para o modelo Cafe de domínio
  Cafe? _mapSupabaseToCafe(
    Map<String, dynamic> data, {
    LatLng? referenceLocation,
  }) {
    try {
      final id = data['id']?.toString();
      final nome = data['nome'] as String?;

      if (id == null || nome == null) {
        return null;
      }

      // EXTRAIR COORDENADAS DO CAMPO referencia_mapa
      double? lat;
      double? lng;
      
      final referenciaMapa = data['referencia_mapa'];
      if (referenciaMapa != null) {
        if (referenciaMapa is String) {
          // Parse string: "LatLng(lat: -23.5505, lng: -46.6333)"
          final regex = RegExp(r'lat:\s*([-\d.]+).*?lng:\s*([-\d.]+)');
          final match = regex.firstMatch(referenciaMapa);
          if (match != null) {
            lat = double.tryParse(match.group(1) ?? '');
            lng = double.tryParse(match.group(2) ?? '');
          }
        } else if (referenciaMapa is Map) {
          lat = referenciaMapa['lat'] as double?;
          lng = referenciaMapa['lng'] as double?;
        }
      }

      // Fallback: tentar pegar de lat/lng direto (caso existam)
      if (lat == null || lng == null) {
        lat = data['lat'] as double?;
        lng = data['lng'] as double?;
      }

      // Se ainda não tiver coordenadas, pular esta cafeteria
      if (lat == null || lng == null || (lat == 0 && lng == 0)) {
        print('⚠️ Cafeteria sem coordenadas válidas: $nome');
        return null;
      }

      // Calcular distância
      String distance = '0 km';
      if (referenceLocation != null) {
        final distKm = _calculateDistanceKm(
          referenceLocation,
          LatLng(lat, lng),
        );
        distance = distKm < 1 
            ? '${(distKm * 1000).round()} m'
            : '${distKm.toStringAsFixed(1)} km';
      }

      // Montar endereço
      final endereco = data['endereco'] as String? ?? '';
      final bairro = data['bairro'] as String? ?? '';
      final cidade = data['cidade'] as String? ?? '';
      
      String enderecoCompleto = endereco;
      if (bairro.isNotEmpty && !enderecoCompleto.contains(bairro)) {
        enderecoCompleto += enderecoCompleto.isNotEmpty ? ', $bairro' : bairro;
      }
      if (cidade.isNotEmpty && !enderecoCompleto.contains(cidade)) {
        enderecoCompleto += enderecoCompleto.isNotEmpty ? ' - $cidade' : cidade;
      }
      
      if (enderecoCompleto.isEmpty) {
        enderecoCompleto = 'Endereço não disponível';
      }

      // URL da foto
      String imageUrl = data['url_foto'] as String? ?? '';
      if (imageUrl.isEmpty) {
        imageUrl = 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400';
      }

      return Cafe(
        id: id,
        name: nome,
        address: enderecoCompleto,
        rating: (data['pontuacao'] as num?)?.toDouble() ?? 0.0,
        imageUrl: imageUrl,
        distance: distance,
        isOpen: true,
        position: LatLng(lat, lng),
        price: 'R\$ 15,00',
        specialties: [],
      );
    } catch (e) {
      print('❌ Erro ao mapear cafeteria: $e');
      return null;
    }
  }

  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const earthRadius = 6371.0;
    
    final dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    final dLng = _degreesToRadians(pos2.longitude - pos1.longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}