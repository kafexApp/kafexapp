import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kafex/data/models/domain/user_profile.dart';
import 'package:kafex/models/cafe_model.dart';

part 'profile_tab_data.freezed.dart';

@freezed
class ProfileTabData with _$ProfileTabData {
  const factory ProfileTabData({
    @Default([]) List<Post> userPosts,
    @Default([]) List<CafeModel> favoriteCafes,
    @Default([]) List<CafeModel> wantToVisitCafes,
    @Default(false) bool isLoadingPosts,
    @Default(false) bool isLoadingFavorites,
    @Default(false) bool isLoadingWantToVisit,
  }) = _ProfileTabData;
}