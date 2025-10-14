// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get id => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String get authorAvatar => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // ✅ NOVO CAMPO: Firebase UID do autor
  String? get authorUid => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  int get comments => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  DomainPostType get type => throw _privateConstructorUsedError;
  String? get coffeeName => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  String? get coffeeId => throw _privateConstructorUsedError;
  bool? get isFavorited => throw _privateConstructorUsedError;
  bool? get wantToVisit => throw _privateConstructorUsedError;
  String? get coffeeAddress => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call({
    String id,
    String authorName,
    String authorAvatar,
    DateTime createdAt,
    String content,
    String? authorUid,
    String? imageUrl,
    String? videoUrl,
    int likes,
    int comments,
    bool isLiked,
    DomainPostType type,
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    String? coffeeAddress,
  });
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? authorAvatar = null,
    Object? createdAt = null,
    Object? content = null,
    Object? authorUid = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? likes = null,
    Object? comments = null,
    Object? isLiked = null,
    Object? type = null,
    Object? coffeeName = freezed,
    Object? rating = freezed,
    Object? coffeeId = freezed,
    Object? isFavorited = freezed,
    Object? wantToVisit = freezed,
    Object? coffeeAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorAvatar: null == authorAvatar
                ? _value.authorAvatar
                : authorAvatar // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            authorUid: freezed == authorUid
                ? _value.authorUid
                : authorUid // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            videoUrl: freezed == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as int,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as int,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as DomainPostType,
            coffeeName: freezed == coffeeName
                ? _value.coffeeName
                : coffeeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            coffeeId: freezed == coffeeId
                ? _value.coffeeId
                : coffeeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorited: freezed == isFavorited
                ? _value.isFavorited
                : isFavorited // ignore: cast_nullable_to_non_nullable
                      as bool?,
            wantToVisit: freezed == wantToVisit
                ? _value.wantToVisit
                : wantToVisit // ignore: cast_nullable_to_non_nullable
                      as bool?,
            coffeeAddress: freezed == coffeeAddress
                ? _value.coffeeAddress
                : coffeeAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
    _$PostImpl value,
    $Res Function(_$PostImpl) then,
  ) = __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorName,
    String authorAvatar,
    DateTime createdAt,
    String content,
    String? authorUid,
    String? imageUrl,
    String? videoUrl,
    int likes,
    int comments,
    bool isLiked,
    DomainPostType type,
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    String? coffeeAddress,
  });
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
    : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? authorAvatar = null,
    Object? createdAt = null,
    Object? content = null,
    Object? authorUid = freezed,
    Object? imageUrl = freezed,
    Object? videoUrl = freezed,
    Object? likes = null,
    Object? comments = null,
    Object? isLiked = null,
    Object? type = null,
    Object? coffeeName = freezed,
    Object? rating = freezed,
    Object? coffeeId = freezed,
    Object? isFavorited = freezed,
    Object? wantToVisit = freezed,
    Object? coffeeAddress = freezed,
  }) {
    return _then(
      _$PostImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorAvatar: null == authorAvatar
            ? _value.authorAvatar
            : authorAvatar // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        authorUid: freezed == authorUid
            ? _value.authorUid
            : authorUid // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        videoUrl: freezed == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as int,
        comments: null == comments
            ? _value.comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as int,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as DomainPostType,
        coffeeName: freezed == coffeeName
            ? _value.coffeeName
            : coffeeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        coffeeId: freezed == coffeeId
            ? _value.coffeeId
            : coffeeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorited: freezed == isFavorited
            ? _value.isFavorited
            : isFavorited // ignore: cast_nullable_to_non_nullable
                  as bool?,
        wantToVisit: freezed == wantToVisit
            ? _value.wantToVisit
            : wantToVisit // ignore: cast_nullable_to_non_nullable
                  as bool?,
        coffeeAddress: freezed == coffeeAddress
            ? _value.coffeeAddress
            : coffeeAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.content,
    this.authorUid,
    this.imageUrl,
    this.videoUrl,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.type,
    this.coffeeName,
    this.rating,
    this.coffeeId,
    this.isFavorited,
    this.wantToVisit,
    this.coffeeAddress,
  });

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String id;
  @override
  final String authorName;
  @override
  final String authorAvatar;
  @override
  final DateTime createdAt;
  @override
  final String content;
  // ✅ NOVO CAMPO: Firebase UID do autor
  @override
  final String? authorUid;
  @override
  final String? imageUrl;
  @override
  final String? videoUrl;
  @override
  final int likes;
  @override
  final int comments;
  @override
  final bool isLiked;
  @override
  final DomainPostType type;
  @override
  final String? coffeeName;
  @override
  final double? rating;
  @override
  final String? coffeeId;
  @override
  final bool? isFavorited;
  @override
  final bool? wantToVisit;
  @override
  final String? coffeeAddress;

  @override
  String toString() {
    return 'Post(id: $id, authorName: $authorName, authorAvatar: $authorAvatar, createdAt: $createdAt, content: $content, authorUid: $authorUid, imageUrl: $imageUrl, videoUrl: $videoUrl, likes: $likes, comments: $comments, isLiked: $isLiked, type: $type, coffeeName: $coffeeName, rating: $rating, coffeeId: $coffeeId, isFavorited: $isFavorited, wantToVisit: $wantToVisit, coffeeAddress: $coffeeAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorAvatar, authorAvatar) ||
                other.authorAvatar == authorAvatar) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.coffeeName, coffeeName) ||
                other.coffeeName == coffeeName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.coffeeId, coffeeId) ||
                other.coffeeId == coffeeId) &&
            (identical(other.isFavorited, isFavorited) ||
                other.isFavorited == isFavorited) &&
            (identical(other.wantToVisit, wantToVisit) ||
                other.wantToVisit == wantToVisit) &&
            (identical(other.coffeeAddress, coffeeAddress) ||
                other.coffeeAddress == coffeeAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorName,
    authorAvatar,
    createdAt,
    content,
    authorUid,
    imageUrl,
    videoUrl,
    likes,
    comments,
    isLiked,
    type,
    coffeeName,
    rating,
    coffeeId,
    isFavorited,
    wantToVisit,
    coffeeAddress,
  );

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(this);
  }
}

abstract class _Post implements Post {
  const factory _Post({
    required final String id,
    required final String authorName,
    required final String authorAvatar,
    required final DateTime createdAt,
    required final String content,
    final String? authorUid,
    final String? imageUrl,
    final String? videoUrl,
    required final int likes,
    required final int comments,
    required final bool isLiked,
    required final DomainPostType type,
    final String? coffeeName,
    final double? rating,
    final String? coffeeId,
    final bool? isFavorited,
    final bool? wantToVisit,
    final String? coffeeAddress,
  }) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get id;
  @override
  String get authorName;
  @override
  String get authorAvatar;
  @override
  DateTime get createdAt;
  @override
  String get content; // ✅ NOVO CAMPO: Firebase UID do autor
  @override
  String? get authorUid;
  @override
  String? get imageUrl;
  @override
  String? get videoUrl;
  @override
  int get likes;
  @override
  int get comments;
  @override
  bool get isLiked;
  @override
  DomainPostType get type;
  @override
  String? get coffeeName;
  @override
  double? get rating;
  @override
  String? get coffeeId;
  @override
  bool? get isFavorited;
  @override
  bool? get wantToVisit;
  @override
  String? get coffeeAddress;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
