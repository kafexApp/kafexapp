// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceSuggestionImpl _$$PlaceSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$PlaceSuggestionImpl(
  placeId: json['placeId'] as String,
  description: json['description'] as String,
  mainText: json['mainText'] as String,
  secondaryText: json['secondaryText'] as String,
  types:
      (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$PlaceSuggestionImplToJson(
  _$PlaceSuggestionImpl instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'description': instance.description,
  'mainText': instance.mainText,
  'secondaryText': instance.secondaryText,
  'types': instance.types,
};
