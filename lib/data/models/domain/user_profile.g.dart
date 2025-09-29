// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String? ?? 'Coffeelover ☕️',
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favoritesCount'] as num?)?.toInt() ?? 0,
      wantToVisitCount: (json['wantToVisitCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'postsCount': instance.postsCount,
      'favoritesCount': instance.favoritesCount,
      'wantToVisitCount': instance.wantToVisitCount,
    };

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: json['id'] as String,
  authorName: json['authorName'] as String,
  authorAvatar: json['authorAvatar'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorName': instance.authorName,
      'authorAvatar': instance.authorAvatar,
      'createdAt': instance.createdAt.toIso8601String(),
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'likes': instance.likes,
      'commentsCount': instance.commentsCount,
      'isLiked': instance.isLiked,
    };
