// lib/ui/posts/viewmodel/post_actions_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../data/models/domain/post.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../utils/user_manager.dart';
import '../../../services/event_bus_service.dart';
import '../../../services/post_deletion_service.dart';
import '../../../data/repositories/likes_repository.dart';

class PostActionsViewModel extends ChangeNotifier {
  final String postId;
  Post _post;
  final LikesRepository _likesRepository;
  final EventBusService _eventBus = EventBusService();

  PostActionsViewModel({
    required this.postId,
    required Post initialPost,
    LikesRepository? likesRepository,
  }) : _post = initialPost,
       _likesRepository = likesRepository ?? LikesRepositoryImpl() {
    _initializeCommands();
    _loadLikeState();
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
    final userEmail = UserManager.instance.userEmail;
    final authorEmail = _post.authorName;
    return authorEmail == userEmail;
  }

  String _getAuthorEmail() {
    return _post.authorName;
  }

  int get avatarColorIndex {
    return _post.authorName.isNotEmpty ? _post.authorName.codeUnitAt(0) % 5 : 0;
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

      _post = _post.copyWith(isFavorited: !isFavorited);
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 500));

      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(isFavorited: !isFavorited);
      notifyListeners();
      return Result.error(Exception('Erro ao favoritar: $e'));
    }
  }

  Future<Result<void>> _toggleWantToVisit() async {
    try {
      if (_post.coffeeId == null) {
        return Result.error(Exception('Post não é de uma cafeteria'));
      }

      _post = _post.copyWith(wantToVisit: !wantToVisit);
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 500));

      return Result.ok(null);
    } catch (e) {
      _post = _post.copyWith(wantToVisit: !wantToVisit);
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
      print('🗑️ === DEBUG EXCLUSÃO ===');
      print('Post ID: $postId');
      print('Author Name: ${_post.authorName}');
      
      final userEmail = UserManager.instance.userEmail;
      print('User Email atual: $userEmail');
      
      final success = await PostDeletionService.deletePost(
        postId: postId,
        authorEmail: userEmail,
      );

      print('Resultado da exclusão: $success');

      if (success) {
        print('✅ Post excluído - emitindo evento');
        _eventBus.emit(PostDeletedEvent(postId));
        return Result.ok(null);
      } else {
        print('❌ Falha na exclusão');
        return Result.error(Exception('Falha ao excluir post'));
      }
    } catch (e) {
      print('❌ ERRO CRÍTICO: $e');
      return Result.error(Exception('Erro ao excluir: $e'));
    }
  }

  String getFormattedDate() {
    final Duration difference = DateTime.now().difference(_post.createdAt);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return 'há $weeks semana${weeks > 1 ? 's' : ''}';
    }
  }

  @override
  void dispose() {
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