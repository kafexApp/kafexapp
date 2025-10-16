// lib/ui/cafe_explorer/utils/clustering_helper.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/domain/cafe.dart';
import 'geo_calculator.dart';

class ClusteringHelper {
  static const double minZoomForClustering = 17.0;

  /// Retorna a distância de agrupamento baseada no zoom
  static double getClusterDistance(double zoom) {
    if (zoom >= 16) return 0.1;
    if (zoom >= 15) return 0.3;
    if (zoom >= 14) return 0.5;
    if (zoom >= 13) return 1.0;
    if (zoom >= 12) return 2.0;
    return 5.0;
  }

  /// Verifica se deve agrupar cafés no zoom atual
  static bool shouldCluster(double zoom) {
    return zoom < minZoomForClustering;
  }

  /// Agrupa cafés próximos em clusters
  static List<PinGroup> clusterCafes(
    List<Cafe> cafes,
    double clusterDistanceKm,
  ) {
    if (cafes.isEmpty) return [];

    List<PinGroup> groups = [];
    List<bool> processed = List.filled(cafes.length, false);

    for (int i = 0; i < cafes.length; i++) {
      if (processed[i]) continue;

      Cafe center = cafes[i];
      List<Cafe> cluster = [center];
      processed[i] = true;

      for (int j = i + 1; j < cafes.length; j++) {
        if (processed[j]) continue;

        double distance = GeoCalculator.calculateDistanceKm(
          center.position,
          cafes[j].position,
        );

        if (distance <= clusterDistanceKm) {
          cluster.add(cafes[j]);
          processed[j] = true;
        }
      }

      if (cluster.length > 1) {
        groups.add(PinGroup.cluster(cluster));
      } else {
        groups.add(PinGroup.single(center));
      }
    }

    return groups;
  }

  /// Gera grupos de pins otimizados baseado no zoom
  static List<PinGroup> getOptimizedPinGroups(
    List<Cafe> cafes,
    double currentZoom,
  ) {
    if (!shouldCluster(currentZoom)) {
      return cafes.map((cafe) => PinGroup.single(cafe)).toList();
    }

    final clusterDistance = getClusterDistance(currentZoom);
    return clusterCafes(cafes, clusterDistance);
  }
}

/// Representa um grupo de pins (pode ser um cluster ou pin único)
class PinGroup {
  final List<Cafe> cafes;
  final bool isCluster;
  late final LatLng position;

  PinGroup.cluster(this.cafes) : isCluster = true {
    position = _calculateCenterPosition();
  }

  PinGroup.single(Cafe cafe)
      : cafes = [cafe],
        isCluster = false {
    position = cafe.position;
  }

  int get count => cafes.length;

  LatLng _calculateCenterPosition() {
    return GeoCalculator.calculateCenter(
      cafes.map((cafe) => cafe.position).toList(),
    );
  }
}