// lib/data/repositories/feed_repository.dart
import '../models/domain/post.dart';
import '../services/supabase_service.dart';
import '../../utils/result.dart';
import '../../services/feed_service.dart';

abstract class FeedRepository {
  Future<Result<List<Post>>> getFeed({int offset = 0});
  Future<Result<void>> createPost(Post post);
}

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required SupabaseService supabaseService})
    : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;
  static const int _pageSize = 10;

  @override
  Future<Result<List<Post>>> getFeed({int offset = 0}) async {
    try {
      print('📥 Carregando feed - offset: $offset, limit: $_pageSize');
      final rawPosts = await FeedService.getFeed(
        limit: _pageSize,
        offset: offset,
      );

      final posts = rawPosts.map((raw) => _convertToPost(raw)).toList();
      print('✅ ${posts.length} posts carregados');

      return Result.ok(posts);
    } catch (e) {
      print('❌ Erro ao carregar feed: $e');
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

    // ✅ Busca o usuario_uid do banco (Firebase UID do autor)
    String? authorUid = raw.usuarioUid;

    // ✅ CORREÇÃO CRÍTICA: Usar cafeteriaId ao invés de id
    // O campo 'id' é o ID da linha do feed, não da cafeteria
    // O campo 'cafeteriaId' (cafeteria_id no banco) é o ID correto da cafeteria
    String? coffeeId;
    if (raw.cafeteriaId != null) {
      coffeeId = raw.cafeteriaId.toString();
      print('✅ Post com cafeteria_id correto: $coffeeId');
    }

    print('🔍 DEBUG REPOSITORY: raw.cafeteriaId = ${raw.cafeteriaId}');
    print('🔍 DEBUG REPOSITORY: coffeeId final = $coffeeId');
    print('🔍 DEBUG REPOSITORY: raw.nomeCafeteria = ${raw.nomeCafeteria}');

    print(
      '🔍 Post mapeado: ID=${raw.id}, CafeteriaID=$coffeeId, Nome=$authorName, Avatar=$authorAvatar, AuthorUID=$authorUid, Comentários=${raw.comentarios}',
    );

    return Post(
      id: raw.id?.toString() ?? '0',
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: raw.criadoEm ?? DateTime.now(),
      content: raw.descricao ?? '',
      authorUid: authorUid,
      imageUrl: raw.urlFoto,
      videoUrl: raw.urlVideo,
      likes: 0,
      comments: int.tryParse(raw.comentarios ?? '0') ?? 0,
      isLiked: false,
      type: postType,
      coffeeName: raw.nomeCafeteria,
      rating: raw.pontuacao,
      coffeeId: coffeeId, // ✅ Agora usa o cafeteriaId correto
      coffeeAddress: raw.endereco,
    );
  }
}
