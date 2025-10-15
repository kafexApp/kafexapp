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

      try {
        final googleSuggestions = await _placesService.getPlaceSuggestions(query);
        
        if (googleSuggestions.isNotEmpty) {
          print('✅ [Google Places] ${googleSuggestions.length} lugares encontrados');

          for (final suggestion in googleSuggestions) {
            if (suggestion.isEstablishment) {
              results.add(PlaceDetails(
                placeId: suggestion.placeId,
                name: suggestion.mainText,
                address: suggestion.secondaryText,
                phone: null,
                website: null,
                photoUrl: null,
                latitude: null,
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
      print('══════════════════════════════');
      print('🔍 VALIDANDO LOCAL SELECIONADO');
      print('🔑 Place ID: $placeId');
      print('══════════════════════════════');
      
      // PASSO 1: Buscar coordenadas
      print('🌐 [Google Places] Buscando coordenadas...');
      
      final coordinates = await _placesService.getPlaceCoordinates(placeId);

      if (coordinates == null) {
        print('⚠️ [Google Places] Coordenadas não encontradas');
        print('══════════════════════════════');
        return null;
      }

      print('✅ [Google Places] Coordenadas: (${coordinates.latitude}, ${coordinates.longitude})');
      
      // PASSO 2: Buscar componentes do endereço
      print('🏠 [Google Places] Buscando componentes do endereço...');
      
      final addressComponents = await _placesService.getAddressComponents(placeId);
      
      if (addressComponents != null) {
        print('✅ [Google Places] Componentes obtidos:');
        print('   Rua: ${addressComponents.street}');
        print('   Número: ${addressComponents.streetNumber}');
        print('   Bairro: ${addressComponents.neighborhood}');
        print('   Cidade: ${addressComponents.city}');
        print('   Estado: ${addressComponents.state}');
        print('   País: ${addressComponents.country}');
      } else {
        print('⚠️ [Google Places] Não foi possível obter componentes do endereço');
      }
      
      // PASSO 3: Verificar duplicata no Supabase
      print('🔍 [Supabase] Verificando duplicata por coordenadas...');
      
      final existing = await _cafeteriaService.checkCafeteriaExists(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        radiusKm: 0.05,
      );

      if (existing != null) {
        print('⚠️ [Supabase] DUPLICATA DETECTADA!');
        print('   Nome: ${existing['nome']}');
        print('   Endereço: ${existing['endereco']}');
        print('   ID: ${existing['id']}');
        print('══════════════════════════════');
        
        return PlaceDetails(
          placeId: 'cafe_${existing['id']}',
          name: existing['nome'] as String? ?? 'Sem nome',
          address: _buildFullAddress(existing),
          phone: existing['telefone'] as String?,
          website: existing['instagram'] as String?,
          photoUrl: existing['url_foto'] as String?,
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        );
      }

      print('✅ [Supabase] Local novo - não existe no banco');
      print('✅ Local validado - pode cadastrar!');
      print('══════════════════════════════');

      return PlaceDetails(
        placeId: placeId,
        name: '',
        address: addressComponents?.formattedAddress ?? '',
        phone: null,
        website: null,
        photoUrl: null,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        street: addressComponents?.street,
        streetNumber: addressComponents?.streetNumber,
        neighborhood: addressComponents?.neighborhood,
        city: addressComponents?.city,
        state: addressComponents?.state,
        country: addressComponents?.country,
        postalCode: addressComponents?.postalCode,
      );
    } catch (e) {
      print('❌ [Place Details] Erro: $e');
      print('══════════════════════════════');
      return null;
    }
  }

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