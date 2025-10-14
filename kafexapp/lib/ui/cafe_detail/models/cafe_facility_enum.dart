// lib/ui/cafe_detail/models/cafe_facility_enum.dart

enum CafeFacility {
  officeFriendly,
  petFriendly,
  vegFriendly,
}

extension CafeFacilityExtension on CafeFacility {
  String get iconPath {
    switch (this) {
      case CafeFacility.officeFriendly:
        return 'assets/images/icon-office-friendly.svg';
      case CafeFacility.petFriendly:
        return 'assets/images/icon-pet-friendly.svg';
      case CafeFacility.vegFriendly:
        return 'assets/images/icon-veg-friendly.svg';
    }
  }

  String get label {
    switch (this) {
      case CafeFacility.officeFriendly:
        return 'Office Friendly';
      case CafeFacility.petFriendly:
        return 'Pet Friendly';
      case CafeFacility.vegFriendly:
        return 'Veg Friendly';
    }
  }
}