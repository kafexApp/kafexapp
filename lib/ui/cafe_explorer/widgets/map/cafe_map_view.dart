// lib/ui/cafe_explorer/widgets/map/cafe_map_view.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../../data/models/domain/cafe.dart';
import '../../services/map_marker_service.dart';
import '../../services/map_camera_service.dart';
import '../../utils/clustering_helper.dart';
import '../../utils/map_style.dart';

class CafeMapView extends StatefulWidget {
  final List<Cafe> cafes;
  final LatLng initialPosition;
  final double initialZoom;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;
  final Function() onCameraIdle;
  final Function(int cafeIndex) onPinTap;
  final VoidCallback? onMapTap;

  const CafeMapView({
    Key? key,
    required this.cafes,
    required this.initialPosition,
    this.initialZoom = 15.0,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onPinTap,
    this.onMapTap,
  }) : super(key: key);

  @override
  State<CafeMapView> createState() => _CafeMapViewState();
}

class _CafeMapViewState extends State<CafeMapView> {
  final MapMarkerService _markerService = MapMarkerService();
  final MapCameraService _cameraService = MapCameraService();
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  double _currentZoom = 15.0;
  bool _isMapMoving = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  @override
  void dispose() {
    _markerService.clearCache();
    super.dispose();
  }

  @override
  void didUpdateWidget(CafeMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cafes != widget.cafes) {
      _updateMarkers();
    }
  }

  Future<void> _loadMarkers() async {
    await _markerService.loadCustomPin();
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    if (!_markerService.isCustomPinLoaded) return;

    final markers = await _markerService.generateMarkers(
      cafes: widget.cafes,
      currentZoom: _currentZoom,
      onPinTap: widget.onPinTap,
      onClusterTap: _onClusterTapped,
    );

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onClusterTapped(PinGroup cluster) async {
    if (_mapController == null) return;
    await _cameraService.animateToCluster(_mapController!, cluster);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated(controller);
    _updateMarkers();
  }

  void _onCameraMove(CameraPosition position) {
    _isMapMoving = true;
    _currentZoom = position.zoom;
    widget.onCameraMove(position);
  }

  void _onCameraIdle() {
    _isMapMoving = false;
    _updateMarkers();
    widget.onCameraIdle();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      style: MapStyle.lightStyle,
      onTap: (_) => widget.onMapTap?.call(),
    );
  }
}