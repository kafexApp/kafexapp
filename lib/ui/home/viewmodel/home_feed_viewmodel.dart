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
    refreshFeed = Command0(_loadFeed);
    
    // Escuta eventos de novos posts criados
    _listenToPostEvents();
  }

  final FeedRepository _feedRepository;
  final EventBusService _eventBus = EventBusService();
  StreamSubscription<PostCreatedEvent>? _postCreatedSubscription;

  late Command0<List<Post>> loadFeed;
  late Command0<List<Post>> refreshFeed;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  /// Escuta eventos de posts criados para atualizar o feed automaticamente
  void _listenToPostEvents() {
    _postCreatedSubscription = _eventBus.on<PostCreatedEvent>().listen((event) {
      print('📱 Feed recebeu evento de novo post: ${event.postId}');
      // Recarrega o feed quando um novo post é criado
      refreshFeed.execute();
    });
  }

  Future<Result<List<Post>>> _loadFeed() async {
    print('🔄 Carregando feed...');
    final result = await _feedRepository.getFeed();

    if (result.isOk) {
      _posts = result.asOk.value;
      print('✅ Feed carregado com ${_posts.length} posts');
    } else {
      print('❌ Erro ao carregar feed: ${result.asError.error}');
      _posts = [];
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
    notifyListeners();
    
    // Emite evento de post excluído
    _eventBus.emit(PostDeletedEvent(postId));
  }

  @override
  void dispose() {
    _postCreatedSubscription?.cancel();
    super.dispose();
  }
}