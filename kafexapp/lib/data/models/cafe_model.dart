import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modelo antigo de Cafe (compatibilidade)
/// Usado pelos widgets que ainda não foram refatorados
class CafeModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String distance;
  final String imageUrl;
  final bool isOpen;
  final LatLng position;
  final String price;
  final List<String> specialties;

  CafeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.isOpen,
    required this.position,
    required this.price,
    required this.specialties,
  });
}