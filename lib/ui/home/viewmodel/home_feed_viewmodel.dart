// lib/ui/home/viewmodel/home_feed_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../data/models/domain/post.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../services/event_bus_service.dart';

class HomeFeedViewModel extends ChangeNotifier {
  HomeFeedViewModel({required FeedRepository feedRepository})
    : _feedRepository = feedRepository {
    loadFeed = Command0(_loadFeed)..execute();
    refreshFeed = Command0(_refreshFeed);
    loadMorePosts = Command0(_loadMorePosts);

    _listenToPostEvents();
  }

  final FeedRepository _feedRepository;
  final EventBusService _eventBus = EventBusService();
  StreamSubscription<PostCreatedEvent>? _postCreatedSubscription;
  StreamSubscription<PostDeletedEvent>? _postDeletedSubscription;

  late Command0<List<Post>> loadFeed;
  late Command0<List<Post>> refreshFeed;
  late Command0<List<Post>> loadMorePosts;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentOffset = 0;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;

  bool get hasMorePosts => _hasMorePosts;
  bool get isLoadingMore => _isLoadingMore;

  void _listenToPostEvents() {
    _postCreatedSubscription = _eventBus.on<PostCreatedEvent>().listen((event) {
      print('📱 Feed recebeu evento de novo post: ${event.postId}');
      refreshFeed.execute();
    });

    _postDeletedSubscription = _eventBus.on<PostDeletedEvent>().listen((event) {
      print('🗑️ Feed recebeu evento de post deletado: ${event.postId}');
      _posts.removeWhere((post) => post.id == event.postId);
      _currentOffset = _posts.length;
      notifyListeners();
    });
  }

  Future<Result<List<Post>>> _loadFeed() async {
    print('🔄 Carregando feed inicial...');
    _currentOffset = 0;
    _hasMorePosts = true;

    final result = await _feedRepository.getFeed(offset: 0);

    if (result.isOk) {
      _posts = result.asOk.value;
      _currentOffset = _posts.length;
      _hasMorePosts = _posts.length >= 10;
      print('✅ Feed inicial carregado com ${_posts.length} posts');
    } else {
      print('❌ Erro ao carregar feed: ${result.asError.error}');
      _posts = [];
      _hasMorePosts = false;
    }

    return result;
  }

  Future<Result<List<Post>>> _refreshFeed() async {
    print('🔄 Atualizando feed...');
    _currentOffset = 0;
    _hasMorePosts = true;

    final result = await _feedRepository.getFeed(offset: 0);

    if (result.isOk) {
      _posts = result.asOk.value;
      _currentOffset = _posts.length;
      _hasMorePosts = _posts.length >= 10;
      print('✅ Feed atualizado com ${_posts.length} posts');
      notifyListeners();
    } else {
      print('❌ Erro ao atualizar feed: ${result.asError.error}');
    }

    return result;
  }

  Future<Result<List<Post>>> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) {
      print(
        '⏭️ Ignorando carregamento: isLoadingMore=$_isLoadingMore, hasMore=$_hasMorePosts',
      );
      return Result.ok([]);
    }

    print('📥 Carregando mais posts... offset: $_currentOffset');
    _isLoadingMore = true;
    notifyListeners();

    final result = await _feedRepository.getFeed(offset: _currentOffset);

    _isLoadingMore = false;

    if (result.isOk) {
      final newPosts = result.asOk.value;

      if (newPosts.isEmpty) {
        _hasMorePosts = false;
        print('🏁 Não há mais posts para carregar');
      } else {
        _posts.addAll(newPosts);
        _currentOffset = _posts.length;
        _hasMorePosts = newPosts.length >= 10;
        print(
          '✅ ${newPosts.length} novos posts carregados. Total: ${_posts.length}',
        );
      }

      notifyListeners();
    } else {
      print('❌ Erro ao carregar mais posts: ${result.asError.error}');
    }

    return result;
  }

  void likePost(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      notifyListeners();
    }
  }

  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    _currentOffset = _posts.length;
    notifyListeners();
  }

  @override
  void dispose() {
    _postCreatedSubscription?.cancel();
    _postDeletedSubscription?.cancel();
    super.dispose();
  }
}