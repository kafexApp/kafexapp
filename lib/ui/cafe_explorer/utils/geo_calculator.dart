// lib/ui/cafe_explorer/utils/geo_calculator.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class GeoCalculator {
  static const double earthRadiusKm = 6371.0;
  static const double earthRadiusMeters = 6371000.0;

  /// Calcula distância em quilômetros entre duas coordenadas
  static double calculateDistanceKm(LatLng pos1, LatLng pos2) {
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calcula distância em metros entre duas coordenadas
  static double calculateDistanceMeters(LatLng pos1, LatLng pos2) {
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Converte graus para radianos
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Calcula o centro geográfico de uma lista de coordenadas
  static LatLng calculateCenter(List<LatLng> positions) {
    if (positions.isEmpty) {
      return LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (var position in positions) {
      totalLat += position.latitude;
      totalLng += position.longitude;
    }

    return LatLng(
      totalLat / positions.length,
      totalLng / positions.length,
    );
  }

  /// Calcula os limites (bounds) de uma lista de coordenadas
  static LatLngBounds calculateBounds(List<LatLng> positions) {
    if (positions.isEmpty) {
      return LatLngBounds(
        southwest: LatLng(0, 0),
        northeast: LatLng(0, 0),
      );
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var position in positions) {
      minLat = math.min(minLat, position.latitude);
      maxLat = math.max(maxLat, position.latitude);
      minLng = math.min(minLng, position.longitude);
      maxLng = math.max(maxLng, position.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}