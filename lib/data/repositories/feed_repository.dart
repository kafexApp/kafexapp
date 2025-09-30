// lib/data/repositories/feed_repository.dart
import '../models/domain/post.dart';
import '../services/supabase_service.dart';
import '../../utils/result.dart';
import '../../services/feed_service.dart';

abstract class FeedRepository {
  Future<Result<List<Post>>> getFeed();
  Future<Result<void>> createPost(Post post);
}

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  @override
  Future<Result<List<Post>>> getFeed() async {
    try {
      final rawPosts = await FeedService.getFeed();
      final posts = rawPosts.map((raw) => _convertToPost(raw)).toList();
      return Result.ok(posts);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar feed: $e'));
    }
  }

  @override
  Future<Result<void>> createPost(Post post) async {
    try {
      // TODO: Implementar criação de post no backend
      // Por enquanto, simula sucesso
      await Future.delayed(Duration(seconds: 2));
      print('Post criado: ${post.content}');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao criar post: $e'));
    }
  }

  Post _convertToPost(dynamic raw) {
    DomainPostType postType = DomainPostType.traditional;
    
    if (raw.pontuacao != null && raw.nomeCafeteria != null) {
      postType = DomainPostType.coffeeReview;
    } else if (raw.nomeCafeteria != null && raw.endereco != null) {
      postType = DomainPostType.newCoffee;
    }

    // Melhora o mapeamento do nome do autor
    String authorName = 'Usuário';
    if (raw.nomeExibicao != null && raw.nomeExibicao!.isNotEmpty) {
      authorName = raw.nomeExibicao!;
    } else if (raw.nome_usuario != null && raw.nome_usuario!.isNotEmpty) {
      authorName = raw.nome_usuario!; // Campo que salvamos na criação
    } else if (raw.usuario != null && raw.usuario!.isNotEmpty) {
      authorName = raw.usuario!;
    }

    // Melhora o mapeamento do avatar do autor
    String authorAvatar = '';
    if (raw.fotoUrl != null && raw.fotoUrl!.isNotEmpty) {
      authorAvatar = raw.fotoUrl!;
    } else if (raw.urlFoto != null && raw.urlFoto!.isNotEmpty) {
      authorAvatar = raw.urlFoto!;
    }

    print('🔍 Post mapeado: ID=${raw.id}, Nome=$authorName, Avatar=$authorAvatar');

    return Post(
      id: raw.id?.toString() ?? '0',
      authorName: authorName,
      authorAvatar: authorAvatar,
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