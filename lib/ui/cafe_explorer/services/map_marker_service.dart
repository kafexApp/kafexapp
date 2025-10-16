// lib/ui/cafe_explorer/services/map_marker_service.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../../utils/app_colors.dart';
import '../../../data/models/domain/cafe.dart';
import '../utils/clustering_helper.dart';

class MapMarkerService {
  BitmapDescriptor? _customPin;
  final Map<String, BitmapDescriptor> _clusterIconCache = {};

  /// Carrega o ícone personalizado do pin
  Future<void> loadCustomPin() async {
    _customPin = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 12.0),
      'assets/images/pin_kafex.png',
    );
  }

  /// Verifica se o pin customizado está carregado
  bool get isCustomPinLoaded => _customPin != null;

  /// Gera todos os markers para o mapa
  Future<Set<Marker>> generateMarkers({
    required List<Cafe> cafes,
    required double currentZoom,
    required Function(int cafeIndex) onPinTap,
    required Function(PinGroup cluster) onClusterTap,
  }) async {
    if (_customPin == null) return {};

    final groups = ClusteringHelper.getOptimizedPinGroups(cafes, currentZoom);
    Set<Marker> markers = {};

    for (int i = 0; i < groups.length; i++) {
      PinGroup group = groups[i];

      if (group.isCluster) {
        BitmapDescriptor clusterIcon = await _getClusterIcon(group.count);

        markers.add(
          Marker(
            markerId: MarkerId('cluster_$i'),
            position: group.position,
            icon: clusterIcon,
            onTap: () => onClusterTap(group),
          ),
        );
      } else {
        final cafe = group.cafes.first;
        int cafeIndex = cafes.indexWhere((c) => c.id == cafe.id);

        markers.add(
          Marker(
            markerId: MarkerId(cafe.id),
            position: cafe.position,
            icon: _customPin!,
            onTap: () => onPinTap(cafeIndex),
          ),
        );
      }
    }

    return markers;
  }

  /// Obtém o ícone de cluster (com cache)
  Future<BitmapDescriptor> _getClusterIcon(int count) async {
    String cacheKey = 'cluster_$count';

    if (_clusterIconCache.containsKey(cacheKey)) {
      return _clusterIconCache[cacheKey]!;
    }

    BitmapDescriptor icon = await _createClusterIcon(count);
    _clusterIconCache[cacheKey] = icon;

    return icon;
  }

  /// Cria o ícone visual do cluster
  Future<BitmapDescriptor> _createClusterIcon(int count) async {
    final String clusterText = count > 99 ? "99+" : count.toString();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Tamanhos 30% maiores
    const double canvasSize = 156.0; // 120 * 1.3
    const double centerOffset = 78.0; // 60 * 1.3
    const double outerRadius = 65.0; // 50 * 1.3
    const double innerRadius = 42.0; // 32 * 1.3

    // Círculo externo (transparente)
    final Paint outerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Círculo interno (sólido)
    final Paint innerCirclePaint = Paint()
      ..color = AppColors.papayaSensorial
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerOffset, centerOffset),
      outerRadius,
      outerCirclePaint,
    );
    canvas.drawCircle(
      Offset(centerOffset, centerOffset),
      innerRadius,
      innerCirclePaint,
    );

    // Texto do contador
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: clusterText,
        style: TextStyle(
          fontSize: count > 99 ? 24 : 28, // 18 * 1.3 e 22 * 1.3
          fontWeight: FontWeight.bold,
          color: AppColors.whiteWhite,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerOffset - textPainter.width / 2,
        centerOffset - textPainter.height / 2,
      ),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image img = await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Limpa o cache de ícones de cluster
  void clearCache() {
    _clusterIconCache.clear();
  }
}