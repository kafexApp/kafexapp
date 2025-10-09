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
