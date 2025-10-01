// lib/ui/cafe_detail/models/cafe_detail_model.dart

import 'cafe_facility_enum.dart';
import 'user_review_model.dart';

class CafeDetailModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final bool isOpen;
  final String openingHours;
  final String instagramHandle;
  final List<CafeFacility> facilities;
  final List<UserReview> reviews;
  final double latitude;
  final double longitude;

  CafeDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.isOpen,
    required this.openingHours,
    required this.instagramHandle,
    required this.facilities,
    required this.reviews,
    required this.latitude,
    required this.longitude,
  });

  factory CafeDetailModel.fromJson(Map<String, dynamic> json) {
    return CafeDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isOpen: json['isOpen'] ?? false,
      openingHours: json['openingHours'] ?? '',
      instagramHandle: json['instagramHandle'] ?? '',
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => CafeFacility.values[e])
          .toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => UserReview.fromJson(e))
          .toList() ?? [],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'instagramHandle': instagramHandle,
      'facilities': facilities.map((e) => e.index).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Conversão do CafeModel para CafeDetailModel (compatibilidade)
  static CafeDetailModel fromCafeModel(dynamic cafeModel) {
    return CafeDetailModel(
      id: cafeModel.id,
      name: cafeModel.name,
      address: cafeModel.address,
      rating: cafeModel.rating,
      imageUrl: cafeModel.imageUrl,
      isOpen: cafeModel.isOpen,
      openingHours: cafeModel.isOpen ? 'Abre ter. às 18:00' : 'Fechado',
      instagramHandle: '@${cafeModel.name.toLowerCase().replaceAll(' ', '')}',
      facilities: [
        CafeFacility.officeFriendly,
        CafeFacility.petFriendly,
        CafeFacility.vegFriendly,
      ],
      reviews: UserReview.mockReviews,
      latitude: cafeModel.position.latitude,
      longitude: cafeModel.position.longitude,
    );
  }
}