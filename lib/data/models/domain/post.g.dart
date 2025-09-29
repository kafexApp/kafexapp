// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: json['id'] as String,
  authorName: json['authorName'] as String,
  authorAvatar: json['authorAvatar'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  likes: (json['likes'] as num).toInt(),
  comments: (json['comments'] as num).toInt(),
  isLiked: json['isLiked'] as bool,
  type: $enumDecode(_$DomainPostTypeEnumMap, json['type']),
  coffeeName: json['coffeeName'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  coffeeId: json['coffeeId'] as String?,
  isFavorited: json['isFavorited'] as bool?,
  wantToVisit: json['wantToVisit'] as bool?,
  coffeeAddress: json['coffeeAddress'] as String?,
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorName': instance.authorName,
      'authorAvatar': instance.authorAvatar,
      'createdAt': instance.createdAt.toIso8601String(),
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'likes': instance.likes,
      'comments': instance.comments,
      'isLiked': instance.isLiked,
      'type': _$DomainPostTypeEnumMap[instance.type]!,
      'coffeeName': instance.coffeeName,
      'rating': instance.rating,
      'coffeeId': instance.coffeeId,
      'isFavorited': instance.isFavorited,
      'wantToVisit': instance.wantToVisit,
      'coffeeAddress': instance.coffeeAddress,
    };

const _$DomainPostTypeEnumMap = {
  DomainPostType.traditional: 'traditional',
  DomainPostType.coffeeReview: 'coffeeReview',
  DomainPostType.newCoffee: 'newCoffee',
};
