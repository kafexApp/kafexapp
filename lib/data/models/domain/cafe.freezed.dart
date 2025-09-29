// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cafe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cafe _$CafeFromJson(Map<String, dynamic> json) {
  return _Cafe.fromJson(json);
}

/// @nodoc
mixin _$Cafe {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String get distance => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  bool get isOpen => throw _privateConstructorUsedError;
  @LatLngConverter()
  LatLng get position => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  List<String> get specialties => throw _privateConstructorUsedError;

  /// Serializes this Cafe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cafe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CafeCopyWith<Cafe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CafeCopyWith<$Res> {
  factory $CafeCopyWith(Cafe value, $Res Function(Cafe) then) =
      _$CafeCopyWithImpl<$Res, Cafe>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    double rating,
    String distance,
    String imageUrl,
    bool isOpen,
    @LatLngConverter() LatLng position,
    String price,
    List<String> specialties,
  });
}

/// @nodoc
class _$CafeCopyWithImpl<$Res, $Val extends Cafe>
    implements $CafeCopyWith<$Res> {
  _$CafeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cafe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? rating = null,
    Object? distance = null,
    Object? imageUrl = null,
    Object? isOpen = null,
    Object? position = null,
    Object? price = null,
    Object? specialties = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            distance: null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            isOpen: null == isOpen
                ? _value.isOpen
                : isOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as LatLng,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            specialties: null == specialties
                ? _value.specialties
                : specialties // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CafeImplCopyWith<$Res> implements $CafeCopyWith<$Res> {
  factory _$$CafeImplCopyWith(
    _$CafeImpl value,
    $Res Function(_$CafeImpl) then,
  ) = __$$CafeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    double rating,
    String distance,
    String imageUrl,
    bool isOpen,
    @LatLngConverter() LatLng position,
    String price,
    List<String> specialties,
  });
}

/// @nodoc
class __$$CafeImplCopyWithImpl<$Res>
    extends _$CafeCopyWithImpl<$Res, _$CafeImpl>
    implements _$$CafeImplCopyWith<$Res> {
  __$$CafeImplCopyWithImpl(_$CafeImpl _value, $Res Function(_$CafeImpl) _then)
    : super(_value, _then);

  /// Create a copy of Cafe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? rating = null,
    Object? distance = null,
    Object? imageUrl = null,
    Object? isOpen = null,
    Object? position = null,
    Object? price = null,
    Object? specialties = null,
  }) {
    return _then(
      _$CafeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        distance: null == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        isOpen: null == isOpen
            ? _value.isOpen
            : isOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as LatLng,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        specialties: null == specialties
            ? _value._specialties
            : specialties // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CafeImpl implements _Cafe {
  const _$CafeImpl({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.isOpen,
    @LatLngConverter() required this.position,
    required this.price,
    required final List<String> specialties,
  }) : _specialties = specialties;

  factory _$CafeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CafeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final double rating;
  @override
  final String distance;
  @override
  final String imageUrl;
  @override
  final bool isOpen;
  @override
  @LatLngConverter()
  final LatLng position;
  @override
  final String price;
  final List<String> _specialties;
  @override
  List<String> get specialties {
    if (_specialties is EqualUnmodifiableListView) return _specialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialties);
  }

  @override
  String toString() {
    return 'Cafe(id: $id, name: $name, address: $address, rating: $rating, distance: $distance, imageUrl: $imageUrl, isOpen: $isOpen, position: $position, price: $price, specialties: $specialties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CafeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isOpen, isOpen) || other.isOpen == isOpen) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(
              other._specialties,
              _specialties,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    address,
    rating,
    distance,
    imageUrl,
    isOpen,
    position,
    price,
    const DeepCollectionEquality().hash(_specialties),
  );

  /// Create a copy of Cafe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CafeImplCopyWith<_$CafeImpl> get copyWith =>
      __$$CafeImplCopyWithImpl<_$CafeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CafeImplToJson(this);
  }
}

abstract class _Cafe implements Cafe {
  const factory _Cafe({
    required final String id,
    required final String name,
    required final String address,
    required final double rating,
    required final String distance,
    required final String imageUrl,
    required final bool isOpen,
    @LatLngConverter() required final LatLng position,
    required final String price,
    required final List<String> specialties,
  }) = _$CafeImpl;

  factory _Cafe.fromJson(Map<String, dynamic> json) = _$CafeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  double get rating;
  @override
  String get distance;
  @override
  String get imageUrl;
  @override
  bool get isOpen;
  @override
  @LatLngConverter()
  LatLng get position;
  @override
  String get price;
  @override
  List<String> get specialties;

  /// Create a copy of Cafe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CafeImplCopyWith<_$CafeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
