import '../models/domain/post.dart';
import '../services/supabase_service.dart';
import '../../utils/result.dart';
import '../../services/feed_service.dart';

abstract class FeedRepository {
  Future<Result<List<Post>>> getFeed();
}

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  @override
  Future<Result<List<Post>>> getFeed() async {
    try {
      // Usa o FeedService existente para buscar dados brutos
      final rawPosts = await FeedService.getFeed();
      
      // Converte para modelos de domínio
      final posts = rawPosts.map((raw) => _convertToPost(raw)).toList();
      
      return Result.ok(posts);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar feed: $e'));
    }
  }

  Post _convertToPost(dynamic raw) {
    // Determinar tipo do post
    PostType postType = PostType.traditional;
    
    if (raw.pontuacao != null && raw.nomeCafeteria != null) {
      postType = PostType.coffeeReview;
    } else if (raw.nomeCafeteria != null && raw.endereco != null) {
      postType = PostType.newCoffee;
    }

    return Post(
      id: raw.id?.toString() ?? '0',
      authorName: raw.nomeExibicao ?? raw.usuario ?? 'Usuário',
      authorAvatar: raw.fotoUrl ?? raw.urlFoto ?? '',
      createdAt: raw.criadoEm ?? DateTime.now(),
      content: raw.descricao ?? '',
      imageUrl: raw.urlFoto,
      videoUrl: raw.urlVideo,
      likes: _parseIntFromString(raw.comentarios) ?? 0,
      comments: 0,
      isLiked: false,
      type: postType,
      coffeeName: raw.nomeCafeteria,
      rating: raw.pontuacao,
      coffeeId: raw.id?.toString(),
      isFavorited: false,
      wantToVisit: false,
      coffeeAddress: raw.endereco,
    );
  }

  int? _parseIntFromString(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}