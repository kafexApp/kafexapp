// lib/ui/cafe_explorer/services/map_camera_service.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../utils/clustering_helper.dart';
import '../utils/geo_calculator.dart';

class MapCameraService {
  /// Move a câmera para um cluster específico com zoom inteligente
  Future<void> animateToCluster(
    GoogleMapController controller,
    PinGroup cluster,
  ) async {
    if (cluster.cafes.length == 1) {
      return;
    }

    // Calcula a distância máxima entre os pontos do cluster
    double maxDistance = _calculateMaxDistanceInCluster(cluster);

    // Zoom baseado na distância máxima
    if (maxDistance < 50) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 19.0),
      );
      return;
    }

    if (maxDistance < 200) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 18.0),
      );
      return;
    }

    // Para clusters maiores, usa bounds com padding
    try {
      final bounds = GeoCalculator.calculateBounds(
        cluster.cafes.map((cafe) => cafe.position).toList(),
      );

      final LatLng southwest = bounds.southwest;
      final LatLng northeast = bounds.northeast;

      // Adiciona padding de 50%
      double latPadding = (northeast.latitude - southwest.latitude) * 0.5;
      double lngPadding = (northeast.longitude - southwest.longitude) * 0.5;

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              southwest.latitude - latPadding,
              southwest.longitude - lngPadding,
            ),
            northeast: LatLng(
              northeast.latitude + latPadding,
              northeast.longitude + lngPadding,
            ),
          ),
          80.0,
        ),
      );
    } catch (e) {
      // Fallback para zoom fixo
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(cluster.position, 17.0),
      );
    }
  }

  /// Move a câmera para uma posição específica
  Future<void> animateToPosition(
    GoogleMapController controller,
    LatLng position, {
    double zoom = 16.0,
  }) async {
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  /// Obtém os cafés visíveis na região atual do mapa
  Future<List<T>> getCafesInViewport<T>({
    required GoogleMapController controller,
    required List<T> allCafes,
    required LatLng Function(T) getPosition,
  }) async {
    try {
      LatLngBounds visibleRegion = await controller.getVisibleRegion();

      return allCafes.where((cafe) {
        LatLng position = getPosition(cafe);
        return position.latitude >= visibleRegion.southwest.latitude &&
            position.latitude <= visibleRegion.northeast.latitude &&
            position.longitude >= visibleRegion.southwest.longitude &&
            position.longitude <= visibleRegion.northeast.longitude;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Calcula a distância máxima entre cafés no cluster
  double _calculateMaxDistanceInCluster(PinGroup cluster) {
    double maxDistance = 0;
    final cafes = cluster.cafes;

    for (int i = 0; i < cafes.length; i++) {
      for (int j = i + 1; j < cafes.length; j++) {
        double distance = GeoCalculator.calculateDistanceMeters(
          cafes[i].position,
          cafes[j].position,
        );
        maxDistance = math.max(maxDistance, distance);
      }
    }

    return maxDistance;
  }
}