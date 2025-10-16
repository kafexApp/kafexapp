// lib/ui/cafe_explorer/utils/map_style.dart

class MapStyle {
  static String get lightStyle => '''[
    {
      "featureType": "administrative",
      "elementType": "labels.text",
      "stylers": [{"visibility": "simplified"}]
    },
    {
      "featureType": "administrative.country",
      "elementType": "geometry.stroke",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "administrative.province",
      "elementType": "geometry.stroke",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [{"color": "#f8f8f8"}]
    },
    {
      "featureType": "poi",
      "elementType": "all",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.business",
      "elementType": "all",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#e8f5e8"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#666666"},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#ffffff"},
        {"weight": 2},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#e6e6e6"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#555555"},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#ffffff"},
        {"weight": 2},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [{"color": "#f0f0f0"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#666666"},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#ffffff"},
        {"weight": 2},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {"color": "#777777"},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"color": "#ffffff"},
        {"weight": 2},
        {"visibility": "on"}
      ]
    },
    {
      "featureType": "transit",
      "elementType": "all",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#d4e7f7"}]
    },
    {
      "featureType": "water",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    }
  ]''';
}