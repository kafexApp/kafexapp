// lib/data/services/google_places_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/place_suggestion.dart';

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyB3s5D0-HxAGvqK9UlVfYeooYUsjbIZcJM';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // ✅ PROXIES ALTERNATIVOS (em ordem de prioridade)
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?',
    'https://api.codetabs.com/v1/proxy?quest=',
    'https://api.allorigins.win/raw?url=',
  ];

  /// ✅ MÉTODO AUXILIAR: Fazer requisição com retry e múltiplos proxies
  Future<http.Response?> _makeRequestWithRetry(String url) async {
    final urlPreview = url.length > 100 ? '${url.substring(0, 100)}...' : url;
    print('🌐 Fazendo requisição: $urlPreview');

    // ✅ TENTAR SEM PROXY PRIMEIRO (Android/iOS)
    if (!kIsWeb) {
      try {
        print('📱 Tentando requisição direta (sem proxy)...');
        final response = await http.get(Uri.parse(url)).timeout(
          Duration(seconds: 8),
        );
        if (response.statusCode == 200) {
          print('✅ Requisição direta bem-sucedida');
          return response;
        }
      } catch (e) {
        print('⚠️ Requisição direta falhou: $e');
      }
    }

    // ✅ TENTAR COM PROXIES (principalmente para Web)
    for (int i = 0; i < _corsProxies.length; i++) {
      final proxy = _corsProxies[i];
      final proxiedUrl = '$proxy${Uri.encodeComponent(url)}';
      
      try {
        final proxyPreview = proxy.length > 30 ? '${proxy.substring(0, 30)}...' : proxy;
        print('🔄 Tentativa ${i + 1}/${_corsProxies.length} com proxy: $proxyPreview');
        
        final response = await http.get(Uri.parse(proxiedUrl)).timeout(
          Duration(seconds: 8),
        );
        
        if (response.statusCode == 200) {
          print('✅ Proxy ${i + 1} funcionou!');
          return response;
        }
        
        print('⚠️ Proxy ${i + 1} retornou status ${response.statusCode}');
      } catch (e) {
        final errorStr = e.toString();
        final errorPreview = errorStr.length > 100 ? '${errorStr.substring(0, 100)}...' : errorStr;
        print('❌ Proxy ${i + 1} falhou: $errorPreview');
        
        // Se não for o último proxy, continuar tentando
        if (i < _corsProxies.length - 1) {
          await Future.delayed(Duration(milliseconds: 300));
          continue;
        }
      }
    }

    print('❌ Todas as tentativas falharam');
    return null;
  }

  /// Buscar sugestões de endereços e estabelecimentos
  Future<List<PlaceSuggestion>> getPlaceSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    print('🔍 [Google Places] Buscando lugares: "$input"');

    final String url = '$_baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&types=establishment|geocode'
        '&components=country:br'
        '&language=pt-BR'
        '&key=$_apiKey';

    try {
      final response = await _makeRequestWithRetry(url);

      if (response == null) {
        print('! [Google Places] Nenhum resultado ou timeout');
        return [];
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
        
        List<PlaceSuggestion> suggestions = [];
        for (var prediction in predictions) {
          suggestions.add(PlaceSuggestion.fromGooglePlacesJson(prediction));
        }
        
        print('✅ [Google Places] ${suggestions.length} lugares encontrados');
        return suggestions;
      } else {
        print('⚠️ [Google Places] Status: ${data['status']}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar sugestões: $e');
      return [];
    }
  }

  /// Obter coordenadas de um place_id
  Future<LatLng?> getPlaceCoordinates(String placeId) async {
    print('📍 [Google Places] Buscando coordenadas para: $placeId');

    final String url = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$_apiKey';

    try {
      final response = await _makeRequestWithRetry(url);

      if (response == null) {
        print('❌ Não foi possível obter coordenadas');
        return null;
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final coords = LatLng(location['lat'], location['lng']);
        print('✅ Coordenadas: ${coords.latitude}, ${coords.longitude}');
        return coords;
      } else {
        print('⚠️ Status: ${data['status']}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter coordenadas: $e');
      return null;
    }
  }

  /// Obter detalhes completos de um lugar, incluindo foto
  Future<Map<String, dynamic>?> getPlaceDetailsWithPhoto(String placeId) async {
    print('📄 [Google Places] Buscando detalhes completos para: $placeId');

    final String url = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=name,formatted_address,formatted_phone_number,website,geometry,photos'
        '&language=pt-BR'
        '&key=$_apiKey';

    try {
      final response = await _makeRequestWithRetry(url);

      if (response == null) {
        print('❌ Não foi possível obter detalhes');
        return null;
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final result = data['result'];
        
        String? photoUrl;
        if (result['photos'] != null && (result['photos'] as List).isNotEmpty) {
          final photoReference = result['photos'][0]['photo_reference'];
          photoUrl = '$_baseUrl/photo'
              '?maxwidth=400'
              '&photo_reference=$photoReference'
              '&key=$_apiKey';
        }

        final details = {
          'name': result['name'],
          'address': result['formatted_address'],
          'phone': result['formatted_phone_number'],
          'website': result['website'],
          'latitude': result['geometry']['location']['lat'],
          'longitude': result['geometry']['location']['lng'],
          'photoUrl': photoUrl,
        };

        print('✅ Detalhes obtidos com sucesso');
        return details;
      } else {
        print('⚠️ Status: ${data['status']}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter detalhes: $e');
      return null;
    }
  }
}