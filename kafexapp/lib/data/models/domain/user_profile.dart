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