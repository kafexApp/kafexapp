// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CafeImpl _$$CafeImplFromJson(Map<String, dynamic> json) => _$CafeImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  rating: (json['rating'] as num).toDouble(),
  distance: json['distance'] as String,
  imageUrl: json['imageUrl'] as String,
  isOpen: json['isOpen'] as bool,
  position: const LatLngConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  price: json['price'] as String,
  specialties: (json['specialties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$CafeImplToJson(_$CafeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'rating': instance.rating,
      'distance': instance.distance,
      'imageUrl': instance.imageUrl,
      'isOpen': instance.isOpen,
      'position': const LatLngConverter().toJson(instance.position),
      'price': instance.price,
      'specialties': instance.specialties,
    };
