import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/domain/cafe.dart';

/// Interface abstrata do repositório de cafeterias
abstract class CafeRepository {
  Future<List<Cafe>> getAllCafes();
  Future<List<Cafe>> getCafesNearLocation(LatLng location, {double radiusKm = 2.0});
}

/// Implementação mock do repositório (dados estáticos)
class CafeRepositoryImpl implements CafeRepository {
  @override
  Future<List<Cafe>> getAllCafes() async {
    // Simular delay de rede
    await Future.delayed(Duration(milliseconds: 500));

    return [
      Cafe(
        id: '1',
        name: 'Coffeelab',
        address: 'R. Fradique Coutinho, 1340 - Vila Madalena, São Paulo - SP, 05416-001',
        rating: 4.8,
        distance: '200m',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        isOpen: true,
        position: LatLng(-23.5505, -46.6333),
        price: 'R\$ 15-25',
        specialties: ['Espresso', 'Latte Art', 'Doces'],
      ),
      Cafe(
        id: '2',
        name: 'Santo Grão',
        address: 'Av. Rebouças, 456 - Pinheiros, São Paulo',
        rating: 4.6,
        distance: '350m',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        isOpen: true,
        position: LatLng(-23.5515, -46.6343),
        price: 'R\$ 12-20',
        specialties: ['Café Gelado', 'Filtrado', 'Tortas'],
      ),
      Cafe(
        id: '3',
        name: 'Café do Centro',
        address: 'Rua Augusta, 789 - Consolação, São Paulo',
        rating: 4.4,
        distance: '500m',
        imageUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400',
        isOpen: false,
        position: LatLng(-23.5495, -46.6323),
        price: 'R\$ 10-18',
        specialties: ['Cappuccino', 'Prensado', 'Lanches'],
      ),
      Cafe(
        id: '4',
        name: 'Blend Coffee',
        address: 'Rua dos Pinheiros, 321 - Pinheiros, São Paulo',
        rating: 4.9,
        distance: '1.2km',
        imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=400',
        isOpen: true,
        position: LatLng(-23.5525, -46.6353),
        price: 'R\$ 18-30',
        specialties: ['Grãos Especiais', 'V60', 'Chemex'],
      ),
      Cafe(
        id: '5',
        name: 'The Coffee',
        address: 'Rua Harmonia, 123 - Vila Madalena, São Paulo',
        rating: 4.7,
        distance: '800m',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
        isOpen: true,
        position: LatLng(-23.5485, -46.6313),
        price: 'R\$ 14-22',
        specialties: ['Cappuccino', 'Croissant', 'WiFi'],
      ),
      Cafe(
        id: '6',
        name: 'Café Próximo 1',
        address: 'Rua Próxima, 100',
        rating: 4.3,
        distance: '150m',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
        isOpen: true,
        position: LatLng(-23.5508, -46.6330),
        price: 'R\$ 12-18',
        specialties: ['Cappuccino'],
      ),
      Cafe(
        id: '7',
        name: 'Café Próximo 2',
        address: 'Rua Próxima, 200',
        rating: 4.1,
        distance: '180m',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
        isOpen: true,
        position: LatLng(-23.5502, -46.6336),
        price: 'R\$ 10-16',
        specialties: ['Expresso'],
      ),
    ];
  }

  @override
  Future<List<Cafe>> getCafesNearLocation(LatLng location, {double radiusKm = 2.0}) async {
    final allCafes = await getAllCafes();
    
    return allCafes.where((cafe) {
      double distance = _calculateDistanceKm(location, cafe.position);
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        double distanceA = _calculateDistanceKm(location, a.position);
        double distanceB = _calculateDistanceKm(location, b.position);
        return distanceA.compareTo(distanceB);
      });
  }

  double _calculateDistanceKm(LatLng pos1, LatLng pos2) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLng = _degreesToRadians(pos2.longitude - pos1.longitude);

    double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_degreesToRadians(pos1.latitude)) *
            _cos(_degreesToRadians(pos2.latitude)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);

    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (3.14159265359 / 180);
  double _sin(double x) => x - (x * x * x) / 6;
  double _cos(double x) => 1 - (x * x) / 2;
  double _sqrt(double x) => x;
  double _atan2(double y, double x) => y / x;
}