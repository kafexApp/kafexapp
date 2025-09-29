import '../../../data/models/domain/post.dart';
import '../../../models/post_models.dart';

class PostAdapter {
  static PostData toPostData(Post post) {
    switch (post.type) {
      case PostType.coffeeReview:
        return PostData.review(
          id: post.id,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          date: _formatDate(post.createdAt),
          content: post.content,
          coffeeName: post.coffeeName ?? '',
          rating: post.rating ?? 0.0,
          coffeeId: post.coffeeId ?? '',
          imageUrl: post.imageUrl,
          videoUrl: post.videoUrl,
          likes: post.likes,
          comments: post.comments,
          isLiked: post.isLiked,
          isFavorited: post.isFavorited ?? false,
          wantToVisit: post.wantToVisit ?? false,
          recentComments: [],
        );

      case PostType.newCoffee:
        return PostData.newCoffee(
          id: post.id,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          date: _formatDate(post.createdAt),
          coffeeName: post.coffeeName ?? 'Nova Cafeteria',
          coffeeAddress: post.coffeeAddress ?? 'Endereço não informado',
          coffeeId: post.coffeeId ?? '',
          imageUrl: post.imageUrl,
          likes: post.likes,
          comments: post.comments,
          isLiked: post.isLiked,
          recentComments: [],
        );

      case PostType.traditional:
      default:
        return PostData.traditional(
          id: post.id,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          date: _formatDate(post.createdAt),
          content: post.content,
          imageUrl: post.imageUrl,
          videoUrl: post.videoUrl,
          likes: post.likes,
          comments: post.comments,
          isLiked: post.isLiked,
          recentComments: [],
        );
    }
  }

  static String _formatDate(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

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
}