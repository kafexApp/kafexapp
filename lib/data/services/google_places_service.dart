// lib/data/services/google_places_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/place_suggestion.dart';

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyB3s5D0-HxAGvqK9UlVfYeooYUsjbIZcJM';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _corsProxy = 'https://api.allorigins.win/raw?url=';

  /// Buscar sugestões de endereços e estabelecimentos
  Future<List<PlaceSuggestion>> getPlaceSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    final String originalUrl = '$_baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&types=establishment|geocode'
        '&components=country:br'
        '&language=pt-BR'
        '&key=$_apiKey';

    final String url = kIsWeb 
        ? '$_corsProxy${Uri.encodeComponent(originalUrl)}' 
        : originalUrl;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<PlaceSuggestion> suggestions = [];
          for (var prediction in data['predictions']) {
            suggestions.add(PlaceSuggestion.fromGooglePlacesJson(prediction));
          }
          return suggestions;
        }
      }
    } catch (e) {
      print('❌ Erro ao buscar sugestões: $e');
    }

    return [];
  }

  /// Obter coordenadas de um place_id
  Future<LatLng?> getPlaceCoordinates(String placeId) async {
    final String originalUrl = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$_apiKey';

    final String url = kIsWeb 
        ? '$_corsProxy${Uri.encodeComponent(originalUrl)}' 
        : originalUrl;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      print('❌ Erro ao obter coordenadas: $e');
    }

    return null;
  }

  /// Obter detalhes completos de um lugar, incluindo foto
  Future<Map<String, dynamic>?> getPlaceDetailsWithPhoto(String placeId) async {
    final String originalUrl = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_address,formatted_phone_number,website,geometry,photos'
        '&language=pt-BR'
        '&key=$_apiKey';

    final String url = kIsWeb 
        ? '$_corsProxy${Uri.encodeComponent(originalUrl)}' 
        : originalUrl;

    try {
      print('🔍 Buscando detalhes do lugar: $placeId');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          
          // Extrair coordenadas
          final geometry = result['geometry'];
          final location = geometry?['location'];
          
          // Extrair primeira foto (se existir)
          String? photoUrl;
          final photos = result['photos'];
          if (photos != null && photos is List && photos.isNotEmpty) {
            final photoReference = photos[0]['photo_reference'];
            if (photoReference != null) {
              photoUrl = getPhotoUrl(photoReference, maxWidth: 800);
              print('📸 Foto encontrada: $photoUrl');
            }
          } else {
            print('⚠️ Nenhuma foto disponível para este lugar');
          }

          return {
            'name': result['name'],
            'address': result['formatted_address'],
            'phone': result['formatted_phone_number'],
            'website': result['website'],
            'latitude': location?['lat'],
            'longitude': location?['lng'],
            'photoUrl': photoUrl,
          };
        } else {
          print('⚠️ Status da API: ${data['status']}');
        }
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao obter detalhes com foto: $e');
    }

    return null;
  }

  /// Gera URL da foto a partir do photo_reference
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    // URL direta da API do Google Places Photos
    final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$_apiKey';
    
    // Nota: Em ambiente web, pode ser necessário usar o CORS proxy
    // Para apps nativos, a URL funciona diretamente
    return kIsWeb 
        ? '$_corsProxy${Uri.encodeComponent(photoUrl)}'
        : photoUrl;
  }
}