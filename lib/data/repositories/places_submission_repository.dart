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

      print('🔍 [Google Places] Buscando lugares: "$query"');

      final results = <PlaceDetails>[];

      // ✅ BUSCAR APENAS NO GOOGLE PLACES (rápido e direto)
      try {
        final googleSuggestions = await _placesService.getPlaceSuggestions(query);
        
        if (googleSuggestions.isNotEmpty) {
          print('✅ [Google Places] ${googleSuggestions.length} lugares encontrados');

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
        } else {
          print('⚠️ [Google Places] Nenhum resultado ou timeout');
        }
      } catch (e) {
        print('❌ [Google Places] Erro ao buscar: $e');
        return [];
      }

      print('✅ Total: ${results.length} resultados');
      return results;
    } catch (e) {
      print('❌ Erro geral na busca: $e');
      return [];
    }
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      print('🔍 [Google Places] Buscando detalhes: $placeId');
      
      // ✅ PASSO 1: BUSCAR COORDENADAS NO GOOGLE PLACES
      final coordinates = await _placesService.getPlaceCoordinates(placeId);

      if (coordinates == null) {
        print('⚠️ [Google Places] Coordenadas não encontradas');
        return null;
      }

      print('✅ [Google Places] Coordenadas obtidas: (${coordinates.latitude}, ${coordinates.longitude})');

      // ✅ PASSO 2: VERIFICAR SE JÁ EXISTE NO SUPABASE (duplicata)
      print('🔍 [Supabase] Verificando duplicata...');
      print('');
      
      final existing = await _cafeteriaService.checkCafeteriaExists(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );

      if (existing != null) {
        print('⚠️ [Supabase] DUPLICATA CONFIRMADA: ${existing['nome']}');
        print('');
        
        // Retornar com flag de duplicata usando prefixo 'cafe_'
        return PlaceDetails(
          placeId: 'cafe_${existing['id']}', // ⚠️ Marca como duplicata
          name: existing['nome'] as String? ?? 'Sem nome',
          address: _buildFullAddress(existing),
          phone: existing['telefone'] as String?,
          website: existing['instagram'] as String?,
          photoUrl: existing['url_foto'] as String?,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        );
      }

      print('✅ [Supabase] Nenhuma duplicata - local novo, pode cadastrar');
      print('');

      // Retornar PlaceDetails com coordenadas (local novo)
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
      print('❌ [Place Details] Erro: $e');
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