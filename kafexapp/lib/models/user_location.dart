class UserLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String country;
  final String address;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
      'address': address,
    };
  }

  String get displayLocation {
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    } else if (city.isNotEmpty) {
      return city;
    } else if (state.isNotEmpty) {
      return state;
    }
    return 'Localização não disponível';
  }

  @override
  String toString() {
    return 'UserLocation(lat: $latitude, lng: $longitude, city: $city, state: $state)';
  }
}