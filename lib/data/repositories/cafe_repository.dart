// lib/data/repositories/cafe_repository.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../models/domain/cafe.dart';
import '../services/supabase_cafeteria_service.dart';

/// Interface abstrata do repositório de cafeterias
abstract class CafeRepository {
  Future<List<Cafe>> getAllCafes();
  Future<List<Cafe>> getCafesNearLocation(LatLng location, {double radiusKm = 2.0});
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

      return cafes;
    } catch (e) {
      print('❌ Erro ao buscar cafeterias: $e');
      // Retornar lista vazia em caso de erro
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

      // Converter e calcular distância
      final cafes = cafeteriasData
          .map((data) => _mapSupabaseToCafe(data, referenceLocation: location))
          .where((cafe) => cafe != null)
          .cast<Cafe>()
          .toList();

      // Ordenar por distância (mais próximo primeiro)
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

  /// Mapeia dados do Supabase para o modelo Cafe de domínio
  Cafe? _mapSupabaseToCafe(
    Map<String, dynamic> data, {
    LatLng? referenceLocation,
  }) {
    try {
      final id = data['id']?.toString();
      final nome = data['nome'] as String?;
      
      // Tentar pegar lat/lng diretamente
      double? lat = data['lat'] as double?;
      double? lng = data['lng'] as double?;

      // Se lat/lng estiverem null, tentar extrair de referencia_mapa
      if ((lat == null || lng == null) && data['referencia_mapa'] != null) {
        final coordsFromRef = _extractCoordinatesFromReferenceMap(data['referencia_mapa']);
        if (coordsFromRef != null) {
          lat = coordsFromRef.latitude;
          lng = coordsFromRef.longitude;
        }
      }

      // Campos obrigatórios
      if (id == null || nome == null || lat == null || lng == null) {
        print('⚠️ Cafeteria sem coordenadas válidas: id=$id, nome=$nome');
        return null;
      }

      final position = LatLng(lat, lng);

      // Calcular distância se tiver localização de referência
      String distance = '0m';
      if (referenceLocation != null) {
        final distanceKm = _calculateDistanceKm(referenceLocation, position);
        distance = _formatDistance(distanceKm);
      }

      // Montar endereço completo
      final endereco = data['endereco'] as String?;
      final bairro = data['bairro'] as String?;
      final cidade = data['cidade'] as String?;
      final estado = data['estado'] as String?;
      
      String fullAddress = '';
      if (endereco != null) fullAddress += endereco;
      if (bairro != null) fullAddress += fullAddress.isEmpty ? bairro : ', $bairro';
      if (cidade != null) fullAddress += fullAddress.isEmpty ? cidade : ', $cidade';
      if (estado != null) fullAddress += fullAddress.isEmpty ? estado : ' - $estado';

      // Rating e avaliações
      final pontuacao = (data['pontuacao'] as num?)?.toDouble() ?? 0.0;
      final avaliacoes = (data['avaliacoes'] as num?)?.toInt() ?? 0;

      // Foto
      final urlFoto = data['url_foto'] as String?;
      final imageUrl = urlFoto ?? 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400';

      // Características especiais para as specialties
      List<String> specialties = [];
      if (data['pet_friendly'] == true) specialties.add('Pet Friendly');
      if (data['opcao_vegana'] == true) specialties.add('Opções Veganas');
      if (data['office_friendly'] == true) specialties.add('Office Friendly');
      
      // Se não tiver nenhuma característica, adicionar genérico
      if (specialties.isEmpty) {
        specialties.add('Café');
      }

      // Status (considera ativo e com coordenadas como "aberto")
      final ativo = data['ativo'] == true;
      final isOpen = ativo;

      // Preço (pode ser implementado depois com base em dados reais)
      final price = 'R\$ 10-25';

      return Cafe(
        id: id,
        name: nome,
        address: fullAddress.isEmpty ? 'Endereço não informado' : fullAddress,
        rating: pontuacao,
        distance: distance,
        imageUrl: imageUrl,
        isOpen: isOpen,
        position: position,
        price: price,
        specialties: specialties,
      );
    } catch (e) {
      print('❌ Erro ao mapear cafeteria: $e');
      print('   Dados: $data');
      return null;
    }
  }

  /// Calcula distância em km entre duas coordenadas (Haversine)
  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // Raio da Terra em km

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

  /// Formata distância para exibição
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Extrai coordenadas do campo referencia_mapa
  /// Exemplo: "LatLng(lat: -23.5719459, lng: -46.6553994)"
  LatLng? _extractCoordinatesFromReferenceMap(dynamic referenciaMapaValue) {
    try {
      String referenciaMapaStr;
      
      // Pode vir como String ou como objeto
      if (referenciaMapaValue is String) {
        referenciaMapaStr = referenciaMapaValue;
      } else {
        referenciaMapaStr = referenciaMapaValue.toString();
      }

      // Extrair lat e lng da string "LatLng(lat: -23.5719459, lng: -46.6553994)"
      final latMatch = RegExp(r'lat:\s*([-\d.]+)').firstMatch(referenciaMapaStr);
      final lngMatch = RegExp(r'lng:\s*([-\d.]+)').firstMatch(referenciaMapaStr);

      if (latMatch != null && lngMatch != null) {
        final lat = double.parse(latMatch.group(1)!);
        final lng = double.parse(lngMatch.group(1)!);
        return LatLng(lat, lng);
      }

      return null;
    } catch (e) {
      print('❌ Erro ao extrair coordenadas de referencia_mapa: $e');
      return null;
    }
  }
}