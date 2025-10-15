// lib/data/services/google_places_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/place_suggestion.dart';

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyB3s5D0-HxAGvqK9UlVfYeooYUsjbIZcJM';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  static const List<String> _corsProxies = [
    'https://corsproxy.io/?',
    'https://api.codetabs.com/v1/proxy?quest=',
    'https://api.allorigins.win/raw?url=',
  ];

  Future<http.Response?> _makeRequestWithRetry(String url) async {
    final urlPreview = url.length > 100 ? '${url.substring(0, 100)}...' : url;
    print('🌐 Fazendo requisição: $urlPreview');

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
        
        if (i < _corsProxies.length - 1) {
          await Future.delayed(Duration(milliseconds: 300));
          continue;
        }
      }
    }

    print('❌ Todas as tentativas falharam');
    return null;
  }

  Future<List<PlaceSuggestion>> getPlaceSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    print('🔍 [Google Places] Buscando lugares GLOBALMENTE: "$input"');
    print('ℹ️ [Limitação API] Máximo de 5 resultados (padrão Google Places Autocomplete)');

    final String url = '$_baseUrl/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&types=establishment'
        '&language=pt-BR'
        '&key=$_apiKey';

    try {
      final response = await _makeRequestWithRetry(url);

      if (response == null) {
        print('❌ [Google Places] Nenhum resultado ou timeout');
        return [];
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
        
        List<PlaceSuggestion> suggestions = [];
        for (var prediction in predictions) {
          suggestions.add(PlaceSuggestion.fromGooglePlacesJson(prediction));
        }
        
        print('✅ [Google Places] ${suggestions.length} lugares encontrados GLOBALMENTE');
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

  /// NOVO: Obter componentes detalhados do endereço
  Future<AddressComponents?> getAddressComponents(String placeId) async {
    print('🏠 [Google Places] Buscando componentes do endereço para: $placeId');

    final String url = '$_baseUrl/details/json'
        '?place_id=$placeId'
        '&fields=address_components,formatted_address'
        '&language=pt-BR'
        '&key=$_apiKey';

    try {
      final response = await _makeRequestWithRetry(url);

      if (response == null) {
        print('❌ Não foi possível obter componentes do endereço');
        return null;
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final result = data['result'];
        final components = result['address_components'] as List;
        
        String? street;
        String? streetNumber;
        String? neighborhood;
        String? city;
        String? state;
        String? country;
        String? postalCode;

        for (var component in components) {
          final types = List<String>.from(component['types']);
          final longName = component['long_name'] as String;
          final shortName = component['short_name'] as String;

          if (types.contains('route')) {
            street = longName;
          } else if (types.contains('street_number')) {
            streetNumber = longName;
          } else if (types.contains('sublocality') || types.contains('sublocality_level_1')) {
            neighborhood = longName;
          } else if (types.contains('administrative_area_level_2') || types.contains('locality')) {
            city = longName;
          } else if (types.contains('administrative_area_level_1')) {
            state = shortName;
          } else if (types.contains('country')) {
            country = longName;
          } else if (types.contains('postal_code')) {
            postalCode = longName;
          }
        }

        // Montar endereço formatado
        String fullAddress = '';
        if (street != null) {
          fullAddress = street;
          if (streetNumber != null) {
            fullAddress += ', $streetNumber';
          }
        }

        final addressComponents = AddressComponents(
          street: street,
          streetNumber: streetNumber,
          neighborhood: neighborhood,
          city: city,
          state: state,
          country: country,
          postalCode: postalCode,
          formattedAddress: result['formatted_address'] as String?,
          fullAddress: fullAddress.isNotEmpty ? fullAddress : null,
        );

        print('✅ Componentes obtidos:');
        print('   Rua: ${addressComponents.street}');
        print('   Número: ${addressComponents.streetNumber}');
        print('   Bairro: ${addressComponents.neighborhood}');
        print('   Cidade: ${addressComponents.city}');
        print('   Estado: ${addressComponents.state}');
        print('   País: ${addressComponents.country}');

        return addressComponents;
      } else {
        print('⚠️ Status: ${data['status']}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter componentes do endereço: $e');
      return null;
    }
  }

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

/// Classe para armazenar componentes do endereço
class AddressComponents {
  final String? street;
  final String? streetNumber;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? formattedAddress;
  final String? fullAddress;

  AddressComponents({
    this.street,
    this.streetNumber,
    this.neighborhood,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.formattedAddress,
    this.fullAddress,
  });

  /// Retorna endereço completo (rua + número)
  String get streetWithNumber {
    if (street == null) return '';
    if (streetNumber != null) {
      return '$street, $streetNumber';
    }
    return street!;
  }

  /// Retorna cidade com estado (ex: "São Paulo - SP")
  String get cityWithState {
    if (city == null) return '';
    if (state != null) {
      return '$city - $state';
    }
    return city!;
  }
}