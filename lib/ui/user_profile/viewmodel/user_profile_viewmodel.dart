// lib/ui/user_profile/viewmodel/user_profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kafex/data/models/domain/user_profile.dart';
import 'package:kafex/data/models/domain/profile_tab_data.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/data/repositories/user_profile_repository.dart';
import 'package:kafex/models/cafe_model.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/services/user_profile_service.dart';
import 'package:kafex/services/quero_visitar_service.dart';
import 'package:kafex/services/favorito_service.dart';
import 'package:kafex/backend/supabase/supabase.dart';

class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;
  final String userId;
  final QueroVisitarService _queroVisitarService = QueroVisitarService();
  final FavoritoService _favoritoService = FavoritoService();

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

  Future<Result<void>> _loadUserProfile() async {
    try {
      print('🔍 Carregando perfil do usuário (Firebase UID): $userId');

      final profile = await _getUserFromSupabase(userId);

      if (profile != null) {
        _userProfile = profile;
        notifyListeners();
        print('✅ Perfil carregado do Supabase: ${profile.name}');
        return Result.ok(null);
      }

      final result = await _repository.getUserProfile(userId);

      if (result.isOk) {
        _userProfile = result.asOk.value;
        notifyListeners();
        print('⚠️ Perfil carregado do repository mock');
        return Result.ok(null);
      }

      return Result.error(result.asError.error);
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
      return Result.error(Exception('Erro ao carregar perfil: $e'));
    }
  }

  Future<UserProfile?> _getUserFromSupabase(String firebaseUid) async {
    try {
      print('🔍 Buscando usuário no Supabase por Firebase UID: $firebaseUid');

      final response = await SupaClient.client
          .from('usuario_perfil')
          .select('id, ref, nome_exibicao, foto_url, email')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response != null) {
        print('✅ Usuário encontrado no Supabase: ${response['nome_exibicao']}');

        final postsCount = await _countUserPosts(response['id']);
        final favoritesCount = await _favoritoService.countUserFavoritos(firebaseUid);
        final wantToVisitCount = await _queroVisitarService.countQueroVisitar(firebaseUid);

        print('⭐ Usuário tem $favoritesCount favoritos');
        print('📍 Usuário tem $wantToVisitCount cafés em "Quero Visitar"');

        return UserProfile(
          id: response['id'].toString(),
          name: response['nome_exibicao'] ?? 'Usuário',
          avatar: response['foto_url'],
          bio: 'Coffeelover ☕️',
          postsCount: postsCount,
          favoritesCount: favoritesCount,
          wantToVisitCount: wantToVisitCount,
        );
      }

      print('⚠️ Usuário não encontrado no Supabase pelo Firebase UID: $firebaseUid');
      return null;
    } catch (e) {
      print('❌ Erro ao buscar usuário no Supabase: $e');
      return null;
    }
  }

  Future<int> _countUserPosts(int userId) async {
    try {
      final response = await SupaClient.client
          .from('feed_com_usuario')
          .select('id')
          .eq('user_id', userId);

      if (response is List) {
        print('✅ Usuário tem ${response.length} posts');
        return response.length;
      }

      return 0;
    } catch (e) {
      print('❌ Erro ao contar posts: $e');
      return 0;
    }
  }

  Future<Result<void>> _loadTabData() async {
    try {
      print('🔍 Carregando dados das tabs para usuário (Firebase UID): $userId');

      final posts = await _getUserPostsFromSupabase();
      final favoriteCafes = await _getFavoriteCafes();
      final wantToVisitCafes = await _getWantToVisitCafes();

      print('⭐ ${favoriteCafes.length} cafés favoritos carregados');
      print('📍 ${wantToVisitCafes.length} cafés carregados em "Quero Visitar"');

      _tabData = _tabData.copyWith(
        userPosts: posts,
        favoriteCafes: favoriteCafes,
        wantToVisitCafes: wantToVisitCafes,
      );

      notifyListeners();
      print('✅ Dados das tabs carregados - ${posts.length} posts');
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao carregar dados das tabs: $e');

      final result = await _repository.getProfileTabData(userId);

      if (result.isOk) {
        _tabData = result.asOk.value;
        notifyListeners();
        return Result.ok(null);
      }

      return Result.error(Exception('Erro ao carregar dados das tabs: $e'));
    }
  }

  Future<List<CafeModel>> _getFavoriteCafes() async {
    try {
      print('🔍 Buscando cafés Favoritos');
      
      final favoritosList = await _favoritoService.getUserFavoritosList(userId);
      
      if (favoritosList.isEmpty) {
        print('⚠️ Lista de Favoritos vazia');
        return [];
      }
      
      final cafes = <CafeModel>[];
      
      for (var item in favoritosList) {
        final cafeteriaId = item['cafeteria_id'];
        if (cafeteriaId == null) continue;
        
        final cafeData = await SupaClient.client
            .from('cafeteria')
            .select('*')
            .eq('id', cafeteriaId)
            .maybeSingle();
        
        if (cafeData == null) continue;
        
        cafes.add(CafeModel(
          id: cafeData['id'].toString(),
          name: cafeData['nome'] ?? '',
          address: '${cafeData['endereco'] ?? ''}, ${cafeData['cidade'] ?? ''}',
          rating: (cafeData['pontuacao'] as num?)?.toDouble() ?? 0.0,
          distance: '0 km',
          imageUrl: cafeData['url_foto'] ?? '',
          isOpen: true,
          position: LatLng(
            (cafeData['latitude'] as num?)?.toDouble() ?? 0.0,
            (cafeData['longitude'] as num?)?.toDouble() ?? 0.0,
          ),
          price: '\$\$',
          specialties: [],
        ));
      }
      
      print('✅ ${cafes.length} cafés favoritos carregados');
      return cafes;
    } catch (e) {
      print('❌ Erro ao buscar cafés Favoritos: $e');
      return [];
    }
  }

  Future<List<CafeModel>> _getWantToVisitCafes() async {
    try {
      print('🔍 Buscando cafés "Quero Visitar"');
      
      final queroVisitarList = await _queroVisitarService.getUserQueroVisitarList(userId);
      
      if (queroVisitarList.isEmpty) {
        print('⚠️ Lista "Quero Visitar" vazia');
        return [];
      }
      
      final cafes = <CafeModel>[];
      
      for (var item in queroVisitarList) {
        final cafeteriaId = item['cafeteria_id'];
        if (cafeteriaId == null) continue;
        
        final cafeData = await SupaClient.client
            .from('cafeteria')
            .select('*')
            .eq('id', cafeteriaId)
            .maybeSingle();
        
        if (cafeData == null) continue;
        
        cafes.add(CafeModel(
          id: cafeData['id'].toString(),
          name: cafeData['nome'] ?? '',
          address: '${cafeData['endereco'] ?? ''}, ${cafeData['cidade'] ?? ''}',
          rating: (cafeData['pontuacao'] as num?)?.toDouble() ?? 0.0,
          distance: '0 km',
          imageUrl: cafeData['url_foto'] ?? '',
          isOpen: true,
          position: LatLng(
            (cafeData['latitude'] as num?)?.toDouble() ?? 0.0,
            (cafeData['longitude'] as num?)?.toDouble() ?? 0.0,
          ),
          price: '\$\$',
          specialties: [],
        ));
      }
      
      print('✅ ${cafes.length} cafés "Quero Visitar" carregados');
      return cafes;
    } catch (e) {
      print('❌ Erro ao buscar cafés "Quero Visitar": $e');
      return [];
    }
  }

  Future<List<Post>> _getUserPostsFromSupabase() async {
    try {
      print('🔍 Buscando posts do usuário (Firebase UID): $userId');

      final userResponse = await SupaClient.client
          .from('usuario_perfil')
          .select('id, ref')
          .eq('ref', userId)
          .maybeSingle();

      if (userResponse == null) {
        print('⚠️ Usuário não encontrado para buscar posts');
        return [];
      }

      final userIdInt = userResponse['id'];
      final userFirebaseUid = userResponse['ref'];
      print('✅ ID do usuário encontrado: $userIdInt');

      final response = await SupaClient.client
          .from('feed_com_usuario')
          .select()
          .eq('user_id', userIdInt)
          .order('criado_em', ascending: false);

      if (response == null) {
        print('⚠️ Nenhum post encontrado');
        return [];
      }

      print('✅ ${response.length} posts encontrados');

      final posts = <Post>[];
      for (var postData in response) {
        final tipoCalculado = postData['tipo_calculado']?.toString().toLowerCase() ?? '';
        
        DomainPostType postType;
        if (tipoCalculado.contains('avalia')) {
          postType = DomainPostType.coffeeReview;
        } else if (tipoCalculado.contains('cafeteria') || tipoCalculado.contains('nova')) {
          postType = DomainPostType.newCoffee;
        } else {
          postType = DomainPostType.traditional;
        }

        posts.add(
          Post(
            id: postData['id'].toString(),
            authorName: postData['nome_exibicao'] ?? 'Usuário',
            authorAvatar: postData['foto_url'] ?? '',
            authorUid: userFirebaseUid,
            content: postData['descricao'] ?? '',
            imageUrl: postData['url_foto'],
            videoUrl: postData['url_video'],
            createdAt: DateTime.parse(postData['criado_em']),
            likes: 0,
            comments: int.tryParse(postData['comentarios']?.toString() ?? '0') ?? 0,
            isLiked: false,
            type: postType,
            coffeeName: postData['nome_cafeteria'],
            rating: postData['pontuacao']?.toDouble(),
            coffeeId: postData['id_cafeteria']?.toString(),
            coffeeAddress: postData['endereco'],
          ),
        );
      }

      return posts;
    } catch (e) {
      print('❌ Erro ao buscar posts do usuário: $e');
      return [];
    }
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
    print('Abrir comentários do post: $postId');
    return Result.ok(null);
  }

  String getDefaultAvatar(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    return initial;
  }

  Color getAvatarColor(String userName) {
    const avatarColors = [
      Color(0xFFE57373),
      Color(0xFF81C784),
      Color(0xFF64B5F6),
      Color(0xFFFFB74D),
      Color(0xFFBA68C8),
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