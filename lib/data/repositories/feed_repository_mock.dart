import '../models/domain/post.dart';
import '../../utils/result.dart';
import 'feed_repository.dart';

class FeedRepositoryMock implements FeedRepository {
  @override
  Future<Result<List<Post>>> getFeed() async {
    // Simula delay de rede
    await Future.delayed(Duration(milliseconds: 500));
    
    final posts = [
      Post(
        id: 'example_1',
        authorName: 'Equipe Kafex',
        authorAvatar: '',
        createdAt: DateTime.now(),
        content: 'Bem-vindo ao Kafex! Explore cafeterias incríveis e compartilhe suas experiências ☕',
        imageUrl: null,
        videoUrl: null,
        likes: 1,
        comments: 0,
        isLiked: false,
        type: PostType.traditional,
      ),
      Post(
        id: 'example_2',
        authorName: 'Sistema',
        authorAvatar: '',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        content: 'Compartilhe suas experiências com café e descubra novos lugares incríveis!',
        imageUrl: null,
        videoUrl: null,
        likes: 0,
        comments: 0,
        isLiked: false,
        type: PostType.traditional,
      ),
    ];
    
    return Result.ok(posts);
  }
}