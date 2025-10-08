// lib/ui/user_profile/viewmodel/user_profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kafex/data/models/domain/user_profile.dart';
import 'package:kafex/data/models/domain/profile_tab_data.dart';
import 'package:kafex/data/repositories/user_profile_repository.dart';
import 'package:kafex/models/cafe_model.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/services/user_profile_service.dart';
import 'package:kafex/backend/supabase/supabase.dart';

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

  // Método para carregar perfil do usuário do Supabase
  Future<Result<void>> _loadUserProfile() async {
    try {
      print('🔍 Carregando perfil do usuário (Firebase UID): $userId');

      // ✅ CORREÇÃO: Buscar perfil no Supabase usando Firebase UID
      final profile = await _getUserFromSupabase(userId);

      if (profile != null) {
        _userProfile = profile;
        notifyListeners();
        print('✅ Perfil carregado do Supabase: ${profile.name}');
        return Result.ok(null);
      }

      // Fallback: usar repository mock se não encontrar no Supabase
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

  // ✅ CORRIGIDO: Busca perfil do usuário no Supabase usando Firebase UID
  Future<UserProfile?> _getUserFromSupabase(String firebaseUid) async {
    try {
      print('🔍 Buscando usuário no Supabase por Firebase UID: $firebaseUid');

      // ✅ CORREÇÃO: Buscar na tabela usuario_perfil pelo campo 'ref' (Firebase UID)
      final response = await SupaClient.client
          .from('usuario_perfil')
          .select('id, ref, nome_exibicao, foto_url, email')
          .eq('ref', firebaseUid) // ✅ Busca pelo Firebase UID
          .maybeSingle();

      if (response != null) {
        print('✅ Usuário encontrado no Supabase: ${response['nome_exibicao']}');

        // Contar posts do usuário
        final postsCount = await _countUserPosts(response['id']);

        // Criar objeto UserProfile
        return UserProfile(
          id: response['id'].toString(),
          name: response['nome_exibicao'] ?? 'Usuário',
          avatar: response['foto_url'],
          bio: 'Coffeelover ☕️', // TODO: Adicionar campo bio na tabela
          postsCount: postsCount,
          favoritesCount: 0, // TODO: Implementar contagem de favoritos
          wantToVisitCount:
              0, // TODO: Implementar contagem de lugares para visitar
        );
      }

      print(
        '⚠️ Usuário não encontrado no Supabase pelo Firebase UID: $firebaseUid',
      );
      return null;
    } catch (e) {
      print('❌ Erro ao buscar usuário no Supabase: $e');
      return null;
    }
  }

  // Conta posts do usuário
  Future<int> _countUserPosts(int userId) async {
    try {
      final response = await SupaClient.client
          .from('feed')
          .select('id')
          .eq('user_id', userId);

      // Contar manualmente os posts
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

  // Método para carregar dados das tabs
  Future<Result<void>> _loadTabData() async {
    try {
      print(
        '🔍 Carregando dados das tabs para usuário (Firebase UID): $userId',
      );

      // Carregar posts do usuário do Supabase
      final posts = await _getUserPostsFromSupabase();

      _tabData = _tabData.copyWith(
        userPosts: posts,
        favoriteCafes: [], // TODO: Implementar busca de cafés favoritos
        wantToVisitCafes: [], // TODO: Implementar busca de cafés para visitar
      );

      notifyListeners();
      print('✅ Dados das tabs carregados - ${posts.length} posts');
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao carregar dados das tabs: $e');

      // Fallback para repository mock
      final result = await _repository.getProfileTabData(userId);

      if (result.isOk) {
        _tabData = result.asOk.value;
        notifyListeners();
        return Result.ok(null);
      }

      return Result.error(Exception('Erro ao carregar dados das tabs: $e'));
    }
  }

  // ✅ CORRIGIDO: Busca posts do usuário no Supabase usando Firebase UID
  Future<List<Post>> _getUserPostsFromSupabase() async {
    try {
      print('🔍 Buscando posts do usuário (Firebase UID): $userId');

      // ✅ CORREÇÃO: Buscar user_id pelo Firebase UID (campo 'ref')
      final userResponse = await SupaClient.client
          .from('usuario_perfil')
          .select('id')
          .eq('ref', userId) // ✅ Busca pelo Firebase UID
          .maybeSingle();

      if (userResponse == null) {
        print('⚠️ Usuário não encontrado para buscar posts');
        return [];
      }

      final userIdInt = userResponse['id'];
      print('✅ ID do usuário encontrado: $userIdInt');

      // Buscar posts do usuário
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

      // Converter para lista de Posts
      final posts = <Post>[];
      for (var postData in response) {
        posts.add(
          Post(
            id: postData['id'].toString(),
            authorName: postData['nome_exibicao'] ?? 'Usuário',
            authorAvatar: postData['foto_url'],
            content: postData['descricao'] ?? '',
            imageUrl: postData['url_foto'],
            createdAt: DateTime.parse(postData['criado_em']),
            likes: 0, // TODO: Implementar contagem de curtidas
            commentsCount: postData['comentarios'] ?? 0,
            isLiked: false, // TODO: Verificar se usuário atual curtiu
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
