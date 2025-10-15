// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafe_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CafeSubmissionImpl _$$CafeSubmissionImplFromJson(Map<String, dynamic> json) =>
    _$CafeSubmissionImpl(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      photoUrl: json['photoUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isOfficeFriendly: json['isOfficeFriendly'] as bool? ?? false,
      isPetFriendly: json['isPetFriendly'] as bool? ?? false,
      isVegFriendly: json['isVegFriendly'] as bool? ?? false,
      customPhotoPath: json['customPhotoPath'] as String?,
      street: json['street'] as String?,
      streetNumber: json['streetNumber'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$$CafeSubmissionImplToJson(
  _$CafeSubmissionImpl instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'website': instance.website,
  'photoUrl': instance.photoUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'isOfficeFriendly': instance.isOfficeFriendly,
  'isPetFriendly': instance.isPetFriendly,
  'isVegFriendly': instance.isVegFriendly,
  'customPhotoPath': instance.customPhotoPath,
  'street': instance.street,
  'streetNumber': instance.streetNumber,
  'neighborhood': instance.neighborhood,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'postalCode': instance.postalCode,
};

_$PlaceDetailsImpl _$$PlaceDetailsImplFromJson(Map<String, dynamic> json) =>
    _$PlaceDetailsImpl(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      photoUrl: json['photoUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      street: json['street'] as String?,
      streetNumber: json['streetNumber'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
    );

Map<String, dynamic> _$$PlaceDetailsImplToJson(_$PlaceDetailsImpl instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'website': instance.website,
      'photoUrl': instance.photoUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'street': instance.street,
      'streetNumber': instance.streetNumber,
      'neighborhood': instance.neighborhood,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postalCode': instance.postalCode,
    };
