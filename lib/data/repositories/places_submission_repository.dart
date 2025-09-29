import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/cafe_submission.dart';

/// Interface abstrata para busca de lugares (Google Places)
abstract class PlacesSubmissionRepository {
  Future<List<PlaceDetails>> searchPlaces(String query);
  Future<PlaceDetails?> getPlaceDetails(String placeId);
}

/// Implementação mock do repositório de lugares
class PlacesSubmissionRepositoryImpl implements PlacesSubmissionRepository {
  @override
  Future<List<PlaceDetails>> searchPlaces(String query) async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 800));

    // Mock data
    return [
      PlaceDetails(
        placeId: 'mock_1',
        name: 'Starbucks',
        address: 'Rua Augusta, São Paulo - SP',
        phone: '(11) 99999-9999',
        website: 'https://instagram.com/starbucks',
        photoUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        latitude: -23.5505,
        longitude: -46.6333,
      ),
      PlaceDetails(
        placeId: 'mock_2',
        name: 'Coffee Lab',
        address: 'Vila Madalena, São Paulo - SP',
        phone: '(11) 88888-8888',
        website: 'https://instagram.com/coffeelab',
        photoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        latitude: -23.5515,
        longitude: -46.6343,
      ),
    ];
  }

  @override
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 1000));

    // Buscar detalhes específicos
    final places = await searchPlaces('');
    return places.firstWhere(
      (place) => place.placeId == placeId,
      orElse: () => places.first,
    );
  }
}