import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

enum DomainPostType {
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
    
    // ✅ NOVO CAMPO: Firebase UID do autor
    String? authorUid,
    
    String? imageUrl,
    String? videoUrl,
    required int likes,
    required int comments,
    required bool isLiked,
    required DomainPostType type,
    
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    String? coffeeAddress,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}