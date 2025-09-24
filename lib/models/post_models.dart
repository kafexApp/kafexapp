import 'comment_models.dart';

enum PostType {
  traditional,
  coffeeReview,
  newCoffee,
}

class PostData {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String date;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<PostComment> recentComments;
  
  // Novo campo para tipo de post
  final PostType type;
  
  // Campos específicos para posts de review
  final String? coffeeName;
  final double? rating;
  final String? coffeeId;
  final bool? isFavorited;
  final bool? wantToVisit;
  
  // Campos específicos para posts de nova cafeteria
  final String? coffeeAddress;

  PostData({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.recentComments,
    this.type = PostType.traditional,
    this.coffeeName,
    this.rating,
    this.coffeeId,
    this.isFavorited,
    this.wantToVisit,
    this.coffeeAddress,
  });

  // Factory para criar post tradicional
  factory PostData.traditional({
    required String id,
    required String authorName,
    required String authorAvatar,
    required String date,
    required String content,
    String? imageUrl,
    String? videoUrl,
    required int likes,
    required int comments,
    required bool isLiked,
    required List<PostComment> recentComments,
  }) {
    return PostData(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      date: date,
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      likes: likes,
      comments: comments,
      isLiked: isLiked,
      recentComments: recentComments,
      type: PostType.traditional,
    );
  }

  // Factory para criar post de review
  factory PostData.review({
    required String id,
    required String authorName,
    required String authorAvatar,
    required String date,
    required String content,
    required String coffeeName,
    required double rating,
    required String coffeeId,
    String? imageUrl,
    String? videoUrl,
    required int likes,
    required int comments,
    required bool isLiked,
    bool isFavorited = false,
    bool wantToVisit = false,
    required List<PostComment> recentComments,
  }) {
    return PostData(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      date: date,
      content: content,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      likes: likes,
      comments: comments,
      isLiked: isLiked,
      recentComments: recentComments,
      type: PostType.coffeeReview,
      coffeeName: coffeeName,
      rating: rating,
      coffeeId: coffeeId,
      isFavorited: isFavorited,
      wantToVisit: wantToVisit,
    );
  }

  // Factory para criar post de nova cafeteria
  factory PostData.newCoffee({
    required String id,
    required String authorName,
    required String authorAvatar,
    required String date,
    required String coffeeName,
    required String coffeeAddress,
    required String coffeeId,
    String? imageUrl,
    required int likes,
    required int comments,
    required bool isLiked,
    required List<PostComment> recentComments,
  }) {
    return PostData(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      date: date,
      content: 'Descobri uma nova cafeteria incrível: $coffeeName! 🎉',
      imageUrl: imageUrl,
      likes: likes,
      comments: comments,
      isLiked: isLiked,
      recentComments: recentComments,
      type: PostType.newCoffee,
      coffeeName: coffeeName,
      coffeeAddress: coffeeAddress,
      coffeeId: coffeeId,
    );
  }

  // Método copyWith para facilitar atualizações
  PostData copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? date,
    String? content,
    String? imageUrl,
    String? videoUrl,
    int? likes,
    int? comments,
    bool? isLiked,
    List<PostComment>? recentComments,
    PostType? type,
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    String? coffeeAddress,
  }) {
    return PostData(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      date: date ?? this.date,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      recentComments: recentComments ?? this.recentComments,
      type: type ?? this.type,
      coffeeName: coffeeName ?? this.coffeeName,
      rating: rating ?? this.rating,
      coffeeId: coffeeId ?? this.coffeeId,
      isFavorited: isFavorited ?? this.isFavorited,
      wantToVisit: wantToVisit ?? this.wantToVisit,
      coffeeAddress: coffeeAddress ?? this.coffeeAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'date': date,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'type': type.toString().split('.').last,
      'coffeeName': coffeeName,
      'rating': rating,
      'coffeeId': coffeeId,
      'isFavorited': isFavorited,
      'wantToVisit': wantToVisit,
      'coffeeAddress': coffeeAddress,
    };
  }

  factory PostData.fromMap(Map<String, dynamic> map) {
    PostType type = PostType.traditional;
    if (map['type'] != null) {
      switch (map['type']) {
        case 'coffeeReview':
          type = PostType.coffeeReview;
          break;
        case 'newCoffee':
          type = PostType.newCoffee;
          break;
        default:
          type = PostType.traditional;
      }
    }

    return PostData(
      id: map['id'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      date: map['date'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      recentComments: [],
      type: type,
      coffeeName: map['coffeeName'],
      rating: map['rating']?.toDouble(),
      coffeeId: map['coffeeId'],
      isFavorited: map['isFavorited'],
      wantToVisit: map['wantToVisit'],
      coffeeAddress: map['coffeeAddress'],
    );
  }
}

class PostComment {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? date;

  PostComment({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.date,
  });
}