import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'place_suggestion.freezed.dart';
part 'place_suggestion.g.dart';

@freezed
class PlaceSuggestion with _$PlaceSuggestion {
  const PlaceSuggestion._();

  const factory PlaceSuggestion({
    required String placeId,
    required String description,
    required String mainText,
    required String secondaryText,
    @Default([]) List<String> types,
  }) = _PlaceSuggestion;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionFromJson(json);

  // Factory alternativo para API do Google Places
  factory PlaceSuggestion.fromGooglePlacesJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
      mainText: json['structured_formatting']['main_text'],
      secondaryText: json['structured_formatting']['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  // Verificar se é um estabelecimento (café, restaurante, loja, etc.)
  bool get isEstablishment {
    return types.any((type) => [
          'establishment',
          'food',
          'restaurant',
          'cafe',
          'meal_takeaway',
          'meal_delivery',
          'store',
          'point_of_interest'
        ].contains(type));
  }

  // Ícone baseado no tipo (retorna o path do SVG)
  String get iconPath {
    if (isEstablishment) {
      return 'assets/images/search-store.svg';
    } else {
      return 'assets/images/search_location.svg';
    }
  }
}