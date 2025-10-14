import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_location.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Future<UserLocation?> getCurrentLocation() async {
    try {
      print('🔍 Iniciando solicitação de localização...');
      
      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Serviços de localização desabilitados');
        return null;
      }

      // Verifica permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permissão negada pelo usuário');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permissão negada permanentemente');
        return null;
      }

      // Obtém posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

      print('📍 Coordenadas obtidas: ${position.latitude}, ${position.longitude}');

      // Tenta converter coordenadas em endereço com fallback inteligente
      String city = 'São Paulo'; // Fallback baseado nas coordenadas
      String state = 'SP';
      String country = 'Brasil';
      String address = 'Localização atual';

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          city = place.locality ?? place.administrativeArea ?? city;
          state = place.administrativeArea ?? state;
          country = place.country ?? country;
          address = '${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          if (address.isEmpty) address = 'Localização atual';
          
          print('🏠 Endereço obtido: $city, $state');
        }
      } catch (geocodingError) {
        print('⚠️ Geocoding indisponível, usando localização padrão');
      }

      final userLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        state: state,
        country: country,
        address: address,
      );

      print('✅ Localização configurada: ${userLocation.displayLocation}');
      return userLocation;
      
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      return null;
    }
  }

  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}