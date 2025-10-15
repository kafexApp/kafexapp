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
        print('🔐 Solicitando permissão de localização...');
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

      print('✅ Permissão concedida, obtendo posição...');

      // Primeiro tenta pegar a última localização conhecida (mais rápido)
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          print('📍 Usando última localização conhecida: ${position.latitude}, ${position.longitude}');
        }
      } catch (e) {
        print('⚠️ Última localização não disponível');
      }

      // Se não tiver última localização, obtém posição atual
      if (position == null) {
        print('🔄 Obtendo posição atual...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 30),
        ).timeout(
          Duration(seconds: 30),
          onTimeout: () {
            print('⏱️ Timeout na obtenção de localização');
            throw TimeoutException('Timeout ao obter localização');
          },
        );
      }

      print('📍 Coordenadas obtidas: ${position.latitude}, ${position.longitude}');

      // Tenta converter coordenadas em endereço (sem bloquear)
      String city = 'São Paulo';
      String state = 'SP';
      String country = 'Brasil';
      String address = 'Localização atual';

      // Faz o geocoding de forma assíncrona, mas não aguarda para não bloquear
      _getAddressAsync(position.latitude, position.longitude).then((placemark) {
        if (placemark != null) {
          print('🏠 Endereço obtido: ${placemark.locality}, ${placemark.administrativeArea}');
        }
      });

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
      
    } on TimeoutException {
      print('❌ Timeout ao obter localização');
      return null;
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
      return null;
    }
  }

  // Método auxiliar para geocoding assíncrono
  Future<Placemark?> _getAddressAsync(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
      return null;
    } catch (e) {
      print('⚠️ Geocoding indisponível: $e');
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

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}