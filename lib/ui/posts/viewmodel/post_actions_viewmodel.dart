// lib/ui/posts/viewmodel/post_actions_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../data/models/domain/post.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../services/event_bus_service.dart';
import '../../../services/post_deletion_service.dart';
import '../../../data/repositories/likes_repository.dart';
import '../../../data/repositories/favorito_repository.dart';
import '../../../data/repositories/quero_visitar_repository.dart';

class PostActionsViewModel extends ChangeNotifier {
  final String postId;
  Post _post;
  final LikesRepository _likesRepository;
  final FavoritoRepository _favoritoRepository;
  final QueroVisitarRepository _queroVisitarRepository;
  final EventBusService _eventBus = EventBusService();

  StreamSubscription<FavoriteChangedEvent>? _favoriteChangedSubscription;
  StreamSubscription<WantToVisitChangedEvent>? _wantToVisitChangedSubscription;

  PostActionsViewModel({
    required this.postId,
    required Post initialPost,
    LikesRepository? likesRepository,
    FavoritoRepository? favoritoRepository,
    QueroVisitarRepository? queroVisitarRepository,
  }) : _post = initialPost,
       _likesRepository = likesRepository ?? LikesRepositoryImpl(),
       _favoritoRepository = favoritoRepository ?? FavoritoRepositoryImpl(),
       _queroVisitarRepository = queroVisitarRepository ?? QueroVisitarRepositoryImpl() {
    _initializeCommands();
    _loadLikeState();
    _loadFavoritoState();
    _loadQueroVisitarState();
    _listenToEvents();
  }

  void _listenToEvents() {
    _favoriteChangedSubscription = _eventBus.on<FavoriteChangedEvent>().listen((event) {
      if (_post.coffeeId == event.coffeeId) {
        print('⭐ PostActions recebeu evento de favorito: coffeeId=${event.coffeeId}, isFavorited=${event.isFavorited}');
        _post = _post.copyWith(isFavorited: event.isFavorited);
        notifyListeners();
      }
    });

    _wantToVisitChangedSubscription = _eventBus.on<WantToVisitChangedEvent>().listen((event) {
      if (_post.coffeeId == event.coffeeId) {
        print('🏷️ PostActions recebeu evento de quero visitar: coffeeId=${event.coffeeId}, wantToVisit=${event.wantToVisit}');
        _post = _post.copyWith(wantToVisit: event.wantToVisit);
        notifyListeners();
      }
    });
  }

  void _initializeCommands() {
    toggleLike = Command0(_toggleLike);
    toggleFavorite = Command0(_toggleFavorite);
    toggleWantToVisit = Command0(_toggleWantToVisit);
    addComment = Command1(_addComment);
    sharePost = Command0(_sharePost);
    editPost = Command0(_editPost);
    deletePost = Command0(_deletePost);
  }

  late Command0<void> toggleLike;
  late Command0<void> toggleFavorite;
  late Command0<void> toggleWantToVisit;
  late Command1<void, String> addComment;
  late Command0<void> sharePost;
  late Command0<void> editPost;
  late Command0<void> deletePost;

  Post get post => _post;
  bool get isLiked => _post.isLiked;
  int get likes => _post.likes;
  int get likesCount => _post.likes;
  bool get isFavorited => _post.isFavorited ?? false;
  bool get wantToVisit => _post.wantToVisit ?? false;
  int get comments => _post.comments;
  int get commentsCount => _post.comments;

  String? get coffeeName => _post.coffeeName;
  String? get coffeeId => _post.coffeeId;
  String? get coffeeAddress => _post.coffeeAddress;
  double? get rating => _post.rating;

  bool get isOwnPost {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    print('🔍 [DEBUG isOwnPost] Post ID: $postId');
    print('   Current User UID: ${currentUser?.uid}');
    print('   Post Author UID: ${_post.authorUid}');
    print('   Post Author Name: ${_post.authorName}');
    
    if (currentUser == null) {
      print('   ❌ Usuário não autenticado');
      return false;
    }
    
    final currentUserUid = currentUser.uid;
    final postAuthorUid = _post.authorUid;
    
    if (postAuthorUid == null || postAuthorUid.isEmpty) {
      print('   ❌ Post sem authorUid!');
      return false;
    }
    
    final isOwn = currentUserUid == postAuthorUid;
    print('   Resultado: ${isOwn ? "✅ É SEU POST" : "❌ NÃO é seu post"}');
    
    return isOwn;
  }

  int get avatarColorIndex {
    return _post.authorName.isNotEmpty ? _post.authorName.codeUnitAt(0) % 5 : 0;
  }

  Future<void> _loadFavoritoState() async {
    try {
      final cafeteriaId = int.tryParse(_post.coffeeId ?? '');
      if (cafeteriaId == null) return;

      final result = await _favoritoRepository.checkIfUserFavorited(cafeteriaId);
      
      if (result.isOk) {
        _post = _post.copyWith(isFavorited: result.asOk.value);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao carregar estado do favorito: $e');
    }
  }

  Future<void> _loadQueroVisitarState() async {
    try {
      final cafeteriaId = int.tryParse(_post.coffeeId ?? '');
      if (cafeteriaId == null) return;

      final result = await _queroVisitarRepository.checkIfUserWantsToVisit(cafeteriaId);
      
      if (result.isOk) {
        _post = _post.copyWith(wantToVisit: result.asOk.value);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao carregar estado do "quero visitar": $e');
    }
  }

  Future<void> _loadLikeState() async {
    try {
      final feedId = int.tryParse(_post.id);
      if (feedId == null) return;

      final isLikedResult = await _likesRepository.checkIfUserLikedFeedPost(
        feedId,
      );

      if (isLikedResult.isOk) {
        final isLiked = isLikedResult.asOk.value;

        final likesCountResult = await _likesRepository.getFeedPostLikesCount(
          feedId,
        );

        if (likesCountResult.isOk) {
          final likesCount = likesCountResult.asOk.value;

          _post = _post.copyWith(isLiked: isLiked, likes: likesCount);
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar estado da curtida: $e');
    }
  }

  Future<Result<void>> _toggleLike() async {
    try {
      final feedId = int.tryParse(_post.id);
      if (feedId == null) {
        return Result.error(Exception('ID do post inválido'));
      }

      final previousIsLiked = _post.isLiked;
      final previousLikes = _post.likes;

      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likes: _post.isLiked ? _post.likes - 1 : _post.likes + 1,
      );
      notifyListeners();

      final result = await _likesRepository.toggleLikeFeedPost(feedId);

      if (result.isError) {
        _post = _post.copyWith(isLiked: previousIsLiked, likes: previousLikes);
        notifyListeners();
        return Result.error(result.asError.error);
      }

      final isNowLiked = result.asOk.value;

      final likesCountResult = await _likesRepository.getFeedPostLikesCount(
        feedId,
      );

      if (likesCountResult.isOk) {
        _post = _post.copyWith(
          isLiked: isNowLiked,
          likes: likesCountResult.asOk.value,
        );
        notifyListeners();
      }

      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likes: _post.isLiked ? _post.likes + 1 : _post.likes - 1,
      );
      notifyListeners();
      return Result.error(Exception('Erro ao curtir post: $e'));
    }
  }

  Future<Result<void>> _toggleFavorite() async {
    try {
      if (_post.coffeeId == null) {
        return Result.error(Exception('Post não é de uma cafeteria'));
      }

      final cafeteriaId = int.tryParse(_post.coffeeId!);
      if (cafeteriaId == null) {
        return Result.error(Exception('ID da cafeteria inválido'));
      }

      final previousFavorited = _post.isFavorited ?? false;
      _post = _post.copyWith(isFavorited: !previousFavorited);
      notifyListeners();

      final result = await _favoritoRepository.toggleFavorito(cafeteriaId);

      if (result.isError) {
        _post = _post.copyWith(isFavorited: previousFavorited);
        notifyListeners();
        return Result.error(result.asError.error);
      }

      _eventBus.emit(FavoriteChangedEvent(_post.coffeeId!, !previousFavorited));
      print('🚀 Evento FavoriteChangedEvent emitido: coffeeId=${_post.coffeeId}, isFavorited=${!previousFavorited}');

      print('✅ Favorito alterado com sucesso no post');
      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(isFavorited: !(_post.isFavorited ?? false));
      notifyListeners();
      return Result.error(Exception('Erro ao favoritar: $e'));
    }
  }

  Future<Result<void>> _toggleWantToVisit() async {
    try {
      if (_post.coffeeId == null) {
        return Result.error(Exception('Post não é de uma cafeteria'));
      }

      final cafeteriaId = int.tryParse(_post.coffeeId!);
      if (cafeteriaId == null) {
        return Result.error(Exception('ID da cafeteria inválido'));
      }

      final previousWantToVisit = _post.wantToVisit ?? false;
      _post = _post.copyWith(wantToVisit: !previousWantToVisit);
      notifyListeners();

      final result = await _queroVisitarRepository.toggleQueroVisitar(cafeteriaId);

      if (result.isError) {
        _post = _post.copyWith(wantToVisit: previousWantToVisit);
        notifyListeners();
        return Result.error(result.asError.error);
      }

      _eventBus.emit(WantToVisitChangedEvent(_post.coffeeId!, !previousWantToVisit));
      print('🚀 Evento WantToVisitChangedEvent emitido: coffeeId=${_post.coffeeId}, wantToVisit=${!previousWantToVisit}');

      print('✅ "Quero visitar" alterado com sucesso no post');
      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(wantToVisit: !(_post.wantToVisit ?? false));
      notifyListeners();
      return Result.error(Exception('Erro ao atualizar lista: $e'));
    }
  }

  Future<Result<void>> _addComment(String comment) async {
    try {
      _post = _post.copyWith(comments: _post.comments + 1);
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 800));

      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(comments: _post.comments - 1);
      notifyListeners();
      return Result.error(Exception('Erro ao comentar: $e'));
    }
  }

  Future<Result<void>> _sharePost() async {
    try {
      print('Compartilhar post: $postId');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao compartilhar: $e'));
    }
  }

  Future<Result<void>> _editPost() async {
    try {
      print('Editar post: $postId');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao editar: $e'));
    }
  }

  Future<Result<void>> _deletePost() async {
    try {
      print('🗑️ Deletando post: $postId');
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      await PostDeletionService.deletePost(_post.id);
      
      print('✅ Post deletado com sucesso');
      
      // ✅ CORREÇÃO: Emite evento para atualizar o feed
      _eventBus.emit(PostDeletedEvent(_post.id));
      print('🚀 Evento PostDeletedEvent emitido: postId=${_post.id}');
      
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao deletar post: $e');
      return Result.error(Exception('Erro ao deletar post: $e'));
    }
  }

  @override
  void dispose() {
    _favoriteChangedSubscription?.cancel();
    _wantToVisitChangedSubscription?.cancel();
    toggleLike.dispose();
    toggleFavorite.dispose();
    toggleWantToVisit.dispose();
    addComment.dispose();
    sharePost.dispose();
    editPost.dispose();
    deletePost.dispose();
    super.dispose();
  }
}