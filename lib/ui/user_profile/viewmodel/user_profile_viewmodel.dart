import 'package:flutter/material.dart';
import 'package:kafex/data/models/domain/user_profile.dart';
import 'package:kafex/data/models/domain/profile_tab_data.dart';
import 'package:kafex/data/repositories/user_profile_repository.dart';
import 'package:kafex/models/cafe_model.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';

class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;
  final String userId;

  UserProfileViewModel({
    required UserProfileRepository repository,
    required this.userId,
  }) : _repository = repository;

  // Estados
  UserProfile? _userProfile;
  ProfileTabData _tabData = const ProfileTabData();
  int _currentTabIndex = 0;

  // Getters
  UserProfile? get userProfile => _userProfile;
  ProfileTabData get tabData => _tabData;
  int get currentTabIndex => _currentTabIndex;
  
  List<Post> get userPosts => _tabData.userPosts;
  List<CafeModel> get favoriteCafes => _tabData.favoriteCafes;
  List<CafeModel> get wantToVisitCafes => _tabData.wantToVisitCafes;

  // Commands
  late final Command0<void> loadUserProfile = Command0(_loadUserProfile);
  late final Command0<void> loadTabData = Command0(_loadTabData);
  late final Command1<void, int> changeTab = Command1(_changeTab);
  late final Command1<void, String> likePost = Command1(_likePost);
  late final Command1<void, String> openComments = Command1(_openComments);

  // Métodos dos Commands
  Future<Result<void>> _loadUserProfile() async {
    final result = await _repository.getUserProfile(userId);
    
    if (result.isOk) {
      _userProfile = result.asOk.value;
      notifyListeners();
      return Result.ok(null);
    }
    
    return Result.error(result.asError.error);
  }

  Future<Result<void>> _loadTabData() async {
    final result = await _repository.getProfileTabData(userId);
    
    if (result.isOk) {
      _tabData = result.asOk.value;
      notifyListeners();
      return Result.ok(null);
    }
    
    return Result.error(result.asError.error);
  }

  Future<Result<void>> _changeTab(int tabIndex) async {
    _currentTabIndex = tabIndex;
    notifyListeners();
    return Result.ok(null);
  }

  Future<Result<void>> _likePost(String postId) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      
      final updatedPosts = _tabData.userPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likes: post.isLiked ? post.likes - 1 : post.likes + 1,
          );
        }
        return post;
      }).toList();
      
      _tabData = _tabData.copyWith(userPosts: updatedPosts);
      notifyListeners();
      
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao curtir post: $e'));
    }
  }

  Future<Result<void>> _openComments(String postId) async {
    // Aqui você pode implementar navegação para comentários
    print('Abrir comentários do post: $postId');
    return Result.ok(null);
  }

  // Avatar padrão
  String getDefaultAvatar(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    return initial;
  }

  Color getAvatarColor(String userName) {
    const avatarColors = [
      Color(0xFFE57373), // vermelho claro
      Color(0xFF81C784), // verde claro  
      Color(0xFF64B5F6), // azul claro
      Color(0xFFFFB74D), // laranja claro
      Color(0xFFBA68C8), // roxo claro
    ];
    
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    return avatarColors[colorIndex];
  }

  @override
  void dispose() {
    loadUserProfile.dispose();
    loadTabData.dispose();
    changeTab.dispose();
    likePost.dispose();
    openComments.dispose();
    super.dispose();
  }
}