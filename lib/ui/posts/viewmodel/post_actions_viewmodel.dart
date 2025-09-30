// lib/ui/posts/viewmodel/post_actions_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/utils/command.dart';
import 'package:kafex/utils/result.dart';
import '../../../services/post_deletion_service.dart';
import '../../../services/event_bus_service.dart';
import '../../../utils/user_manager.dart';

class PostActionsViewModel extends ChangeNotifier {
  final String postId;
  final Post initialPost;
  final EventBusService _eventBus = EventBusService();

  PostActionsViewModel({
    required this.postId,
    required this.initialPost,
  }) {
    _post = initialPost;
    _initializeCommands();
  }

  late Post _post;
  Post get post => _post;

  // Commands
  late final Command0<void> toggleLike = Command0(_toggleLike);
  late final Command0<void> toggleFavorite = Command0(_toggleFavorite);
  late final Command0<void> toggleWantToVisit = Command0(_toggleWantToVisit);
  late final Command1<void, String> addComment = Command1(_addComment);
  late final Command0<void> sharePost = Command0(_sharePost);
  late final Command0<void> editPost = Command0(_editPost);
  late final Command0<void> deletePost = Command0(_deletePost);

  void _initializeCommands() {
    // Inicializar commands
  }

  // Getters para UI
  bool get isLiked => _post.isLiked;
  int get likesCount => _post.likes;
  int get commentsCount => _post.comments;
  bool get isFavorited => _post.isFavorited ?? false;
  bool get wantToVisit => _post.wantToVisit ?? false;

  // Dados específicos por tipo
  String? get coffeeName => _post.coffeeName;
  double? get rating => _post.rating;
  String? get coffeeId => _post.coffeeId;
  String? get coffeeAddress => _post.coffeeAddress;

  // Verificações de permissão
  bool get canDelete => PostDeletionService.canDeletePost(_getAuthorEmail());
  bool get canEdit => PostDeletionService.canDeletePost(_getAuthorEmail()); // Mesma lógica por enquanto

  String _getAuthorEmail() {
    // Por enquanto, usamos um método para extrair o email do autor
    // Em uma implementação completa, isso viria do post
    final userManager = UserManager.instance;
    return userManager.userEmail;
  }

  // Avatar e identificação
  String getAvatarInitial() {
    return _post.authorName.isNotEmpty ? _post.authorName[0].toUpperCase() : 'U';
  }

  int getAvatarColorIndex() {
    return _post.authorName.isNotEmpty ? _post.authorName.codeUnitAt(0) % 5 : 0;
  }

  // Actions
  Future<Result<void>> _toggleLike() async {
    try {
      // Atualização otimista
      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likes: _post.isLiked ? _post.likes - 1 : _post.likes + 1,
      );
      notifyListeners();

      // TODO: Chamar API real
      await Future.delayed(Duration(milliseconds: 300));
      
      return Result.ok(null);
    } catch (e) {
      // Reverter em caso de erro
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

      // Atualização otimista
      _post = _post.copyWith(isFavorited: !isFavorited);
      notifyListeners();

      // TODO: Chamar API real para favoritar cafeteria
      await Future.delayed(Duration(milliseconds: 500));
      
      return Result.ok(null);
    } catch (e) {
      // Reverter em caso de erro
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

      // Atualização otimista
      _post = _post.copyWith(wantToVisit: !wantToVisit);
      notifyListeners();

      // TODO: Chamar API real para lista "quero visitar"
      await Future.delayed(Duration(milliseconds: 500));
      
      return Result.ok(null);
    } catch (e) {
      // Reverter em caso de erro
      _post = _post.copyWith(wantToVisit: !wantToVisit);
      notifyListeners();
      return Result.error(Exception('Erro ao atualizar lista: $e'));
    }
  }

  Future<Result<void>> _addComment(String comment) async {
    try {
      // Atualização otimista
      _post = _post.copyWith(comments: _post.comments + 1);
      notifyListeners();

      // TODO: Chamar API real para adicionar comentário
      await Future.delayed(Duration(milliseconds: 800));
      
      return Result.ok(null);
    } catch (e) {
      // Reverter em caso de erro
      _post = _post.copyWith(comments: _post.comments - 1);
      notifyListeners();
      return Result.error(Exception('Erro ao comentar: $e'));
    }
  }

  Future<Result<void>> _sharePost() async {
    try {
      // TODO: Implementar compartilhamento
      print('Compartilhar post: $postId');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao compartilhar: $e'));
    }
  }

  Future<Result<void>> _editPost() async {
    try {
      // TODO: Implementar edição
      print('Editar post: $postId');
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao editar: $e'));
    }
  }

  Future<Result<void>> _deletePost() async {
    try {
      print('🗑️ Iniciando exclusão do post: $postId');
      
      final success = await PostDeletionService.deletePost(
        postId: postId,
        authorEmail: _getAuthorEmail(),
      );

      if (success) {
        print('✅ Post excluído com sucesso');
        
        // Emite evento de post excluído para atualizar o feed
        _eventBus.emit(PostDeletedEvent(postId));
        
        return Result.ok(null);
      } else {
        return Result.error(Exception('Falha ao excluir post'));
      }
    } catch (e) {
      print('❌ Erro ao excluir post: $e');
      return Result.error(Exception('Erro ao excluir: $e'));
    }
  }

  // Formatação de data
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