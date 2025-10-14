import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/place_suggestion.dart';
import '../services/google_places_service.dart';

/// Interface abstrata do repositório de lugares
abstract class PlacesRepository {
  Future<List<PlaceSuggestion>> searchPlaces(String query);
  Future<LatLng?> getCoordinatesFromPlaceId(String placeId);
}

/// Implementação do repositório usando Google Places API
class PlacesRepositoryImpl implements PlacesRepository {
  final GooglePlacesService _placesService;

  PlacesRepositoryImpl({GooglePlacesService? placesService})
      : _placesService = placesService ?? GooglePlacesService();

  @override
  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    return await _placesService.getPlaceSuggestions(query);
  }

  @override
  Future<LatLng?> getCoordinatesFromPlaceId(String placeId) async {
    return await _placesService.getPlaceCoordinates(placeId);
  }
}