import 'package:flutter/foundation.dart';
import '../../../data/models/domain/post.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class HomeFeedViewModel extends ChangeNotifier {
  HomeFeedViewModel({required FeedRepository feedRepository})
      : _feedRepository = feedRepository {
    loadFeed = Command0(_loadFeed)..execute();
    refreshFeed = Command0(_loadFeed);
  }

  final FeedRepository _feedRepository;

  late Command0<List<Post>> loadFeed;
  late Command0<List<Post>> refreshFeed;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<Result<List<Post>>> _loadFeed() async {
    final result = await _feedRepository.getFeed();

    if (result.isOk) {
      _posts = result.asOk.value;
    } else {
      // Em caso de erro, usar lista vazia
      _posts = [];
    }

    return result;
  }

  // Comandos para ações de posts
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
    // TODO: Salvar like no Supabase
  }

  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
    // TODO: Deletar no Supabase
  }
}