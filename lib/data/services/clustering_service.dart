import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/cafe.dart';

/// Grupo de pins (cluster ou individual)
class PinGroup {
  final List<Cafe> cafes;
  final LatLng position;
  final bool isCluster;

  PinGroup.single(Cafe cafe)
      : cafes = [cafe],
        position = cafe.position,
        isCluster = false;

  PinGroup.cluster(this.cafes)
      : position = _calculateCenterPosition(cafes),
        isCluster = true;

  static LatLng _calculateCenterPosition(List<Cafe> cafes) {
    double lat = cafes.map((c) => c.position.latitude).reduce((a, b) => a + b) / cafes.length;
    double lng = cafes.map((c) => c.position.longitude).reduce((a, b) => a + b) / cafes.length;
    return LatLng(lat, lng);
  }

  int get count => cafes.length;
}

/// Serviço de clustering otimizado para pins no mapa
class ClusteringService {
  static const double _clusterDistanceKm = 0.2; // 200 metros
  static const double _minZoomForClustering = 18.0;

  /// Agrupar cafés em clusters baseado no zoom atual
  List<PinGroup> groupCafes(List<Cafe> cafes, double currentZoom) {
    // Se zoom alto, mostrar pins individuais
    if (currentZoom >= _minZoomForClustering) {
      return cafes.map((cafe) => PinGroup.single(cafe)).toList();
    }

    // Fazer clustering
    List<PinGroup> groups = [];
    List<Cafe> remaining = List.from(cafes);

    while (remaining.isNotEmpty) {
      Cafe center = remaining.removeAt(0);
      List<Cafe> nearby = [center];

      // Encontrar cafés próximos
      remaining.removeWhere((cafe) {
        double distance = _calculateDistanceKm(center.position, cafe.position);
        if (distance <= _clusterDistanceKm) {
          nearby.add(cafe);
          return true;
        }
        return false;
      });

      // Criar grupo
      if (nearby.length > 1) {
        groups.add(PinGroup.cluster(nearby));
      } else {
        groups.add(PinGroup.single(center));
      }
    }

    return groups;
  }

  /// Calcular distância entre dois pontos em km
  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(pos1.latitude)) *
            math.cos(_degreesToRadians(pos2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}