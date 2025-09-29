import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? avatar,
    @Default('Coffeelover ☕️') String bio,
    @Default(0) int postsCount,
    @Default(0) int favoritesCount,
    @Default(0) int wantToVisitCount,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

// Domain model compatível com o Post existente
@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String authorName,
    String? authorAvatar,
    required DateTime createdAt,
    required String content,
    String? imageUrl,
    @Default(0) int likes,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}