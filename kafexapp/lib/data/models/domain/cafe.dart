import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'cafe.freezed.dart';
part 'cafe.g.dart';

// Converter para LatLng
class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng latLng) {
    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }
}

@freezed
class Cafe with _$Cafe {
  const factory Cafe({
    required String id,
    required String name,
    required String address,
    required double rating,
    required String distance,
    required String imageUrl,
    required bool isOpen,
    @LatLngConverter() required LatLng position,
    required String price,
    required List<String> specialties,
  }) = _Cafe;

  factory Cafe.fromJson(Map<String, dynamic> json) => _$CafeFromJson(json);
}