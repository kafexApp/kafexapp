import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

enum PostType {
  traditional,
  coffeeReview,
  newCoffee,
}

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String authorName,
    required String authorAvatar,
    required DateTime createdAt,
    required String content,
    String? imageUrl,
    String? videoUrl,
    required int likes,
    required int comments,
    required bool isLiked,
    required PostType type,
    
    // Review-specific
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    
    // New coffee-specific
    String? coffeeAddress,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}