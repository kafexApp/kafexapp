// lib/ui/cafe_detail/models/user_review_model.dart

import '../../../backend/supabase/tables/avaliacao_com_cafeteria.dart';

class UserReview {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> images;
  final int likes;
  final bool isLiked;

  UserReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.images = const [],
    this.likes = 0,
    this.isLiked = false,
  });

  /// Converte dados do Supabase (AvaliacaoComCafeteriaRow) para UserReview
  factory UserReview.fromSupabase(AvaliacaoComCafeteriaRow avaliacao) {
    // Monta lista de imagens se houver foto_url
    List<String> images = [];
    if (avaliacao.fotoUrl != null && avaliacao.fotoUrl!.isNotEmpty) {
      images.add(avaliacao.fotoUrl!);
    }

    return UserReview(
      id: avaliacao.avaliacaoId?.toString() ?? '0',
      userName: avaliacao.nomeExibicao ?? 'Usuário Anônimo',
      userAvatar: '', // TODO: Buscar avatar do usuário se necessário
      rating: avaliacao.nota ?? 0.0,
      comment: avaliacao.descricao ?? '',
      date: avaliacao.avaliacaoCriadaEm ?? DateTime.now(),
      images: images,
      likes: (avaliacao.curtidasAvaliacao ?? 0).toInt(),
      isLiked: false, // TODO: Verificar se o usuário atual curtiu
    );
  }

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'images': images,
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  UserReview copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? date,
    List<String>? images,
    int? likes,
    bool? isLiked,
  }) {
    return UserReview(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Mock data para testes (manter temporariamente para compatibilidade)
  static List<UserReview> get mockReviews => [
    UserReview(
      id: '1',
      userName: 'Ana Silva',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      rating: 5.0,
      comment:
          'Café excepcional! O ambiente é acolhedor e o atendimento impecável. Voltarei com certeza.',
      date: DateTime.now().subtract(Duration(days: 2)),
      images: [],
      likes: 12,
    ),
    UserReview(
      id: '2',
      userName: 'Carlos Santos',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      rating: 4.5,
      comment:
          'Muito bom! O cappuccino é delicioso e o local é perfeito para trabalhar.',
      date: DateTime.now().subtract(Duration(days: 5)),
      images: [],
      likes: 8,
    ),
    UserReview(
      id: '3',
      userName: 'Maria Oliveira',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      rating: 4.0,
      comment:
          'Ótima experiência! Só achei o preço um pouco alto, mas vale a pena.',
      date: DateTime.now().subtract(Duration(days: 10)),
      images: [],
      likes: 5,
    ),
  ];
}
