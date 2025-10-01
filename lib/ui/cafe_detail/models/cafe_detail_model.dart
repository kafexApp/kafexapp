// lib/ui/cafe_detail/models/cafe_detail_model.dart

import 'cafe_facility_enum.dart';
import 'user_review_model.dart';

class CafeDetailModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isOpen;
  final String openingHours;
  final String instagramHandle;
  final List<CafeFacility> facilities;
  final List<UserReview> reviews;
  final double latitude;
  final double longitude;
  
  // Dados do usuário criador
  final String? creatorName;
  final String? creatorAvatar;
  final String? creatorInstagram;

  CafeDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.isOpen,
    required this.openingHours,
    required this.instagramHandle,
    required this.facilities,
    required this.reviews,
    required this.latitude,
    required this.longitude,
    this.creatorName,
    this.creatorAvatar,
    this.creatorInstagram,
  });

  factory CafeDetailModel.fromJson(Map<String, dynamic> json) {
    return CafeDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
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
      creatorName: json['creatorName'],
      creatorAvatar: json['creatorAvatar'],
      creatorInstagram: json['creatorInstagram'],
    );
  }

  /// Converte dados do Supabase para CafeDetailModel
  factory CafeDetailModel.fromSupabase(Map<String, dynamic> data) {
    // Extrair dados do usuário criador (vem do JOIN)
    final usuarioPerfil = data['usuario_perfil'] as Map<String, dynamic>?;
    
    // Montar endereço completo
    final endereco = data['endereco'] as String? ?? '';
    final bairro = data['bairro'] as String? ?? '';
    final cidade = data['cidade'] as String? ?? '';
    final estado = data['estado'] as String? ?? '';
    
    String enderecoCompleto = endereco;
    if (bairro.isNotEmpty) {
      enderecoCompleto += ', $bairro';
    }
    if (cidade.isNotEmpty) {
      enderecoCompleto += ' - $cidade';
    }
    if (estado.isNotEmpty) {
      enderecoCompleto += ', $estado';
    }

    // Mapear facilities baseado nos campos booleanos
    List<CafeFacility> facilities = [];
    if (data['pet_friendly'] == true) {
      facilities.add(CafeFacility.petFriendly);
    }
    if (data['opcao_vegana'] == true) {
      facilities.add(CafeFacility.vegFriendly);
    }
    if (data['office_friendly'] == true) {
      facilities.add(CafeFacility.officeFriendly);
    }

    // Extrair Instagram (remover @ se existir)
    String instagram = data['instagram'] as String? ?? '';
    if (instagram.isNotEmpty && !instagram.startsWith('@')) {
      instagram = '@$instagram';
    }

    return CafeDetailModel(
      id: data['id']?.toString() ?? '',
      name: data['nome'] as String? ?? 'Cafeteria',
      address: enderecoCompleto.isNotEmpty 
          ? enderecoCompleto 
          : 'Endereço não disponível',
      rating: (data['pontuacao'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['avaliacoes'] as num?)?.toInt() ?? 0,
      imageUrl: data['url_foto'] as String? ?? '',
      isOpen: true, // TODO: Implementar lógica de horário de funcionamento
      openingHours: 'Horário não disponível', // TODO: Buscar horários reais
      instagramHandle: instagram,
      facilities: facilities,
      reviews: UserReview.mockReviews, // TODO: Buscar avaliações reais
      latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['lng'] as num?)?.toDouble() ?? 0.0,
      creatorName: usuarioPerfil?['nome_exibicao'] as String?,
      creatorAvatar: usuarioPerfil?['foto_url'] as String?,
      creatorInstagram: usuarioPerfil?['instagram'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'openingHours': openingHours,
      'instagramHandle': instagramHandle,
      'facilities': facilities.map((e) => e.index).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'creatorInstagram': creatorInstagram,
    };
  }

  // Conversão do CafeModel para CafeDetailModel (compatibilidade)
  static CafeDetailModel fromCafeModel(dynamic cafeModel) {
    return CafeDetailModel(
      id: cafeModel.id,
      name: cafeModel.name,
      address: cafeModel.address,
      rating: cafeModel.rating,
      reviewCount: 0,
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