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
      print('Erro ao buscar sugestões: $e');
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
      print('Erro ao obter coordenadas: $e');
    }

    return null;
  }
}