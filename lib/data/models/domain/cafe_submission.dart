import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:io';

part 'cafe_submission.freezed.dart';
part 'cafe_submission.g.dart';

/// Modelo de domínio para submissão de cafeteria
@freezed
class CafeSubmission with _$CafeSubmission {
  const factory CafeSubmission({
    required String placeId,
    required String name,
    required String address,
    String? phone,
    String? website,
    String? photoUrl,
    double? latitude,
    double? longitude,
    @Default(false) bool isOfficeFriendly,
    @Default(false) bool isPetFriendly,
    @Default(false) bool isVegFriendly,
    String? customPhotoPath, // Path da foto customizada (não serializa para JSON)
  }) = _CafeSubmission;

  factory CafeSubmission.fromJson(Map<String, dynamic> json) =>
      _$CafeSubmissionFromJson(json);
}

/// Modelo para detalhes de lugar do Google Places
@freezed
class PlaceDetails with _$PlaceDetails {
  const factory PlaceDetails({
    required String placeId,
    required String name,
    required String address,
    String? phone,
    String? website,
    String? photoUrl,
    double? latitude,
    double? longitude,
  }) = _PlaceDetails;

  factory PlaceDetails.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailsFromJson(json);
}