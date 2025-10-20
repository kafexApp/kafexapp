// lib/ui/home/viewmodel/home_feed_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../data/models/domain/post.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../services/event_bus_service.dart';

class HomeFeedViewModel extends ChangeNotifier {
  HomeFeedViewModel({
    required FeedRepository feedRepository,
    required AnalyticsRepository analyticsRepository,
  }) : _feedRepository = feedRepository,
       _analyticsRepository = analyticsRepository {
    loadFeed = Command0(_loadFeed)..execute();
    refreshFeed = Command0(_refreshFeed);
    loadMorePosts = Command0(_loadMorePosts);

    _listenToPostEvents();
    _logScreenView();
  }

  final FeedRepository _feedRepository;
  final AnalyticsRepository _analyticsRepository;
  final EventBusService _eventBus = EventBusService();
  StreamSubscription<PostCreatedEvent>? _postCreatedSubscription;
  StreamSubscription<PostDeletedEvent>? _postDeletedSubscription;
  StreamSubscription<FavoriteChangedEvent>? _favoriteChangedSubscription;
  StreamSubscription<WantToVisitChangedEvent>? _wantToVisitChangedSubscription;

  late Command0<List<Post>> loadFeed;
  late Command0<List<Post>> refreshFeed;
  late Command0<List<Post>> loadMorePosts;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  int _currentOffset = 0;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;
  bool _isDisposed = false;

  bool get hasMorePosts => _hasMorePosts;
  bool get isLoadingMore => _isLoadingMore;

  final Map<String, DateTime> _lastPostViewTime = {};
  static const _postViewDebounceSeconds = 2;

  void _logScreenView() {
    _analyticsRepository.logScreenView(
      screenName: 'feed',
      screenClass: 'HomeFeedViewModel',
    ).catchError((error) {
      print('⚠️ Erro ao logar screen view: $error');
    });
  }

  void _listenToPostEvents() {
    print('👂 HomeFeedViewModel começou a escutar eventos - EventBus: ${_eventBus.hashCode}');
    
    _postCreatedSubscription = _eventBus.on<PostCreatedEvent>().listen((event) {
      print('📱 Feed recebeu evento de novo post: ${event.postId}');
      refreshFeed.execute();
    });

    _postDeletedSubscription = _eventBus.on<PostDeletedEvent>().listen((event) {
      print('🗑️ Feed recebeu evento de post deletado: ${event.postId}');
      print('   Posts antes: ${_posts.length}');
      
      _posts.removeWhere((post) => post.id == event.postId);
      _currentOffset = _posts.length;
      
      print('   Posts depois: ${_posts.length}');
      print('   Notificando listeners...');
      
      if (!_isDisposed) {
        notifyListeners();
        print('   ✅ Listeners notificados!');
      } else {
        print('   ❌ ViewModel já foi disposed!');
      }
    });

    _favoriteChangedSubscription = _eventBus.on<FavoriteChangedEvent>().listen((event) {
      print('⭐ Feed recebeu evento de favorito: coffeeId=${event.coffeeId}, isFavorited=${event.isFavorited}');
      
      bool updated = false;
      for (int i = 0; i < _posts.length; i++) {
        if (_posts[i].coffeeId == event.coffeeId) {
          _posts[i] = _posts[i].copyWith(isFavorited: event.isFavorited);
          updated = true;
        }
      }
      
      if (updated && !_isDisposed) {
        notifyListeners();
      }
    });

    _wantToVisitChangedSubscription = _eventBus.on<WantToVisitChangedEvent>().listen((event) {
      print('🏷️ Feed recebeu evento de quero visitar: coffeeId=${event.coffeeId}, wantToVisit=${event.wantToVisit}');
      
      bool updated = false;
      for (int i = 0; i < _posts.length; i++) {
        if (_posts[i].coffeeId == event.coffeeId) {
          _posts[i] = _posts[i].copyWith(wantToVisit: event.wantToVisit);
          updated = true;
        }
      }
      
      if (updated && !_isDisposed) {
        notifyListeners();
      }
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
      
      _analyticsRepository.logEvent(
        eventName: 'feed_view',
        parameters: {
          'posts_count': _posts.length,
          'has_more': _hasMorePosts,
        },
      ).catchError((error) {
        print('⚠️ Erro ao logar feed view: $error');
      });
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
      
      _analyticsRepository.logFeedRefresh().catchError((error) {
        print('⚠️ Erro ao logar feed refresh: $error');
      });
      
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
        
        _analyticsRepository.logEvent(
          eventName: 'feed_load_more',
          parameters: {
            'new_posts_count': newPosts.length,
            'total_posts': _posts.length,
            'offset': _currentOffset,
          },
        ).catchError((error) {
          print('⚠️ Erro ao logar load more: $error');
        });
      }

      notifyListeners();
    } else {
      print('❌ Erro ao carregar mais posts: ${result.asError.error}');
    }

    return result;
  }

  void logPostView(Post post) {
    final now = DateTime.now();
    final lastTime = _lastPostViewTime[post.id];
    
    if (lastTime != null) {
      final difference = now.difference(lastTime).inSeconds;
      if (difference < _postViewDebounceSeconds) {
        return;
      }
    }
    
    _lastPostViewTime[post.id] = now;
    
    _analyticsRepository.logPostView(
      postId: int.tryParse(post.id) ?? 0,
      postType: post.type.toString().split('.').last,
    ).catchError((error) {
      print('⚠️ Erro ao logar post view: $error');
    });
  }

  void likePost(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final willLike = !post.isLiked;
      
      _posts[index] = post.copyWith(
        isLiked: willLike,
        likes: willLike ? post.likes + 1 : post.likes - 1,
      );
      notifyListeners();
      
      if (willLike) {
        _analyticsRepository.logPostLike(
          postId: int.tryParse(postId) ?? 0,
          postType: post.type.toString().split('.').last,
        ).catchError((error) {
          print('⚠️ Erro ao logar like: $error');
        });
      } else {
        _analyticsRepository.logPostUnlike(
          postId: int.tryParse(postId) ?? 0,
          postType: post.type.toString().split('.').last,
        ).catchError((error) {
          print('⚠️ Erro ao logar unlike: $error');
        });
      }
    }
  }

  void logPostShare(String postId, String shareMethod) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => _posts.first,
    );
    
    _analyticsRepository.logPostShare(
      postId: int.tryParse(postId) ?? 0,
      postType: post.type.toString().split('.').last,
      shareMethod: shareMethod,
    ).catchError((error) {
      print('⚠️ Erro ao logar share: $error');
    });
  }

  void logPostComment(String postId) {
    final post = _posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => _posts.first,
    );
    
    _analyticsRepository.logPostComment(
      postId: int.tryParse(postId) ?? 0,
      postType: post.type.toString().split('.').last,
    ).catchError((error) {
      print('⚠️ Erro ao logar comment: $error');
    });
  }

  void deletePost(String postId) {
    print('🗑️ deletePost chamado localmente para: $postId');
    _posts.removeWhere((post) => post.id == postId);
    _currentOffset = _posts.length;
    notifyListeners();
  }

  @override
  void dispose() {
    print('🗑️ HomeFeedViewModel sendo disposed');
    _isDisposed = true;
    _postCreatedSubscription?.cancel();
    _postDeletedSubscription?.cancel();
    _favoriteChangedSubscription?.cancel();
    _wantToVisitChangedSubscription?.cancel();
    _lastPostViewTime.clear();
    super.dispose();
  }
}