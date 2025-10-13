// lib/data/repositories/places_submission_repository.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/cafe_submission.dart';
import '../services/supabase_cafeteria_service.dart';
import '../services/google_places_service.dart';

/// Interface abstrata para busca de lugares (Google Places)
abstract class PlacesSubmissionRepository {
  Future<List<PlaceDetails>> searchPlaces(String query);
  Future<PlaceDetails?> getPlaceDetails(String placeId);
}

/// Implementação REAL usando Supabase + Google Places API
class PlacesSubmissionRepositoryImpl implements PlacesSubmissionRepository {
  final SupabaseCafeteriaService _cafeteriaService;
  final GooglePlacesService _placesService;

  PlacesSubmissionRepositoryImpl({
    SupabaseCafeteriaService? cafeteriaService,
    GooglePlacesService? placesService,
  })  : _cafeteriaService = cafeteriaService ?? SupabaseCafeteriaService(),
        _placesService = placesService ?? GooglePlacesService();

  @override
  Future<List<PlaceDetails>> searchPlaces(String query) async {
    try {
      if (query.isEmpty) return [];

      print('🔍 Buscando lugares: "$query"');

      final results = <PlaceDetails>[];

      // 1️⃣ BUSCAR NO SUPABASE (cafeterias já cadastradas)
      print('📦 Buscando cafeterias no Supabase...');
      final cafeterias = await _cafeteriaService.searchCafeteriasByName(query);
      print('✅ ${cafeterias.length} cafeterias encontradas no Supabase');

      // Converter cafeterias do Supabase para PlaceDetails
      for (final cafe in cafeterias) {
        results.add(PlaceDetails(
          placeId: 'cafe_${cafe['id']}',
          name: cafe['nome'] as String? ?? 'Sem nome',
          address: _buildFullAddress(cafe),
          phone: cafe['telefone'] as String?,
          website: cafe['instagram'] as String?,
          photoUrl: cafe['url_foto'] as String?,
          latitude: cafe['lat'] as double?,
          longitude: cafe['lng'] as double?,
        ));
      }

      // 2️⃣ BUSCAR NO GOOGLE PLACES API (lugares novos)
      print('🌐 Buscando no Google Places API...');
      final googleSuggestions = await _placesService.getPlaceSuggestions(query);
      print('✅ ${googleSuggestions.length} lugares encontrados no Google');

      // Converter sugestões do Google para PlaceDetails (sem coordenadas ainda)
      for (final suggestion in googleSuggestions) {
        // Apenas adicionar se for um estabelecimento (café, restaurante, etc)
        if (suggestion.isEstablishment) {
          results.add(PlaceDetails(
            placeId: suggestion.placeId,
            name: suggestion.mainText,
            address: suggestion.secondaryText,
            phone: null,
            website: null,
            photoUrl: null,
            latitude: null, // Será buscado depois no getPlaceDetails
            longitude: null,
          ));
        }
      }

      print('✅ Total: ${results.length} resultados (Supabase + Google)');
      return results;
    } catch (e) {
      print('❌ Erro ao buscar lugares: $e');
      return [];
    }
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      // Verificar se é uma cafeteria do Supabase (placeId começa com 'cafe_')
      if (placeId.startsWith('cafe_')) {
        final cafeIdStr = placeId.replaceFirst('cafe_', '');
        final cafeId = int.tryParse(cafeIdStr);

        if (cafeId == null) {
          print('❌ ID inválido: $placeId');
          return null;
        }

        print('🔍 Buscando detalhes da cafeteria ID: $cafeId');

        final cafe = await _cafeteriaService.getCafeteriaById(cafeId);

        if (cafe == null) {
          print('⚠️ Cafeteria não encontrada');
          return null;
        }

        return PlaceDetails(
          placeId: placeId,
          name: cafe['nome'] as String? ?? 'Sem nome',
          address: _buildFullAddress(cafe),
          phone: cafe['telefone'] as String?,
          website: cafe['instagram'] as String?,
          photoUrl: cafe['url_foto'] as String?,
          latitude: cafe['lat'] as double?,
          longitude: cafe['lng'] as double?,
        );
      }

      // Se não for cafeteria, buscar coordenadas no Google Places
      print('🌐 Buscando coordenadas no Google Places: $placeId');
      final coordinates = await _placesService.getPlaceCoordinates(placeId);

      if (coordinates == null) {
        print('⚠️ Coordenadas não encontradas');
        return null;
      }

      // Retornar PlaceDetails com coordenadas
      // Nota: nome e endereço virão do searchPlaces anterior
      return PlaceDetails(
        placeId: placeId,
        name: '',  // Será preenchido pela seleção anterior
        address: '',
        phone: null,
        website: null,
        photoUrl: null,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );
    } catch (e) {
      print('❌ Erro ao buscar detalhes: $e');
      return null;
    }
  }

  /// Constrói endereço completo a partir dos dados da cafeteria
  String _buildFullAddress(Map<String, dynamic> cafe) {
    final parts = <String>[];

    final endereco = cafe['endereco'] as String?;
    final bairro = cafe['bairro'] as String?;
    final cidade = cafe['cidade'] as String?;
    final estado = cafe['estado'] as String?;

    if (endereco != null && endereco.isNotEmpty) {
      parts.add(endereco);
    }

    if (bairro != null && bairro.isNotEmpty) {
      parts.add(bairro);
    }

    if (cidade != null && cidade.isNotEmpty) {
      if (estado != null && estado.isNotEmpty) {
        parts.add('$cidade - $estado');
      } else {
        parts.add(cidade);
      }
    }

    return parts.isEmpty ? 'Endereço não informado' : parts.join(', ');
  }
}