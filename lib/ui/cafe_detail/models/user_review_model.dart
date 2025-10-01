// lib/ui/cafe_detail/models/user_review_model.dart

class UserReview {
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;

  UserReview({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  // Mock data para testes
  static UserReview get mockReview {
    return UserReview(
      userId: '1',
      userName: 'Amanda Klein',
      userAvatar: 'assets/images/default-avatar.svg',
      rating: 5.0,
      comment: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
      date: '03/05/2024',
    );
  }

  // Lista de avaliações mock para testes
  static List<UserReview> get mockReviews {
    return [
      UserReview(
        userId: '1',
        userName: 'Amanda Klein',
        userAvatar: 'assets/images/default-avatar.svg',
        rating: 5.0,
        comment: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
        date: '03/05/2024',
      ),
      UserReview(
        userId: '2',
        userName: 'Carlos Santos',
        userAvatar: 'assets/images/default-avatar.svg',
        rating: 4.0,
        comment: 'Ambiente muito aconchegante e café de qualidade. O atendimento foi excelente, mas achei o preço um pouco alto.',
        date: '28/04/2024',
      ),
      UserReview(
        userId: '3',
        userName: 'Marina Silva',
        userAvatar: 'assets/images/default-avatar.svg',
        rating: 5.0,
        comment: 'Simplesmente perfeito! O espresso estava no ponto ideal e o croissant estava fresquinho. Voltarei com certeza.',
        date: '25/04/2024',
      ),
      UserReview(
        userId: '4',
        userName: 'João Pedro',
        userAvatar: 'assets/images/default-avatar.svg',
        rating: 3.0,
        comment: 'Café bom, mas o tempo de espera foi muito longo. O ambiente é legal, mas pode melhorar na agilidade.',
        date: '20/04/2024',
      ),
      UserReview(
        userId: '5',
        userName: 'Beatriz Oliveira',
        userAvatar: 'assets/images/default-avatar.svg',
        rating: 4.0,
        comment: 'Adorei o cappuccino e os doces disponíveis. O Wi-Fi funciona bem, ótimo para trabalhar.',
        date: '15/04/2024',
      ),
    ];
  }
}