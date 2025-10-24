// lib/data/repositories/likes_repository.dart

import '../../utils/result.dart';
import '../../services/likes_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/supabase/supabase.dart';

/// Interface abstrata para repositório de curtidas
abstract class LikesRepository {
  Future<Result<bool>> toggleLikeFeedPost(int feedId);
  Future<Result<bool>> toggleLikeAvaliacao(int avaliacaoId);
  Future<Result<bool>> checkIfUserLikedFeedPost(int feedId);
  Future<Result<bool>> checkIfUserLikedAvaliacao(int avaliacaoId);
  Future<Result<int>> getFeedPostLikesCount(int feedId);
  Future<Result<int>> getAvaliacaoLikesCount(int avaliacaoId);
}

/// Implementação real do repositório de curtidas
class LikesRepositoryImpl implements LikesRepository {
  final LikesService _likesService = LikesService();

  /// Obtém o ID do usuário no Supabase a partir do Firebase UID
  Future<int?> _getUserIdFromFirebaseUid(String firebaseUid) async {
    try {
      final response = await SupaClient.client
          .from('usuario_perfil')
          .select('id')
          .eq('ref', firebaseUid)
          .maybeSingle();

      if (response != null) {
        return response['id'] as int?;
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      return null;
    }
  }

  /// Obtém o ID do usuário atual
  Future<int?> _getCurrentUserId() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('❌ Nenhum usuário autenticado');
        return null;
      }

      final userId = await _getUserIdFromFirebaseUid(firebaseUser.uid);
      if (userId == null) {
        print('❌ User ID não encontrado para UID: ${firebaseUser.uid}');
      }
      return userId;
    } catch (e) {
      print('❌ Erro ao obter user ID atual: $e');
      return null;
    }
  }

  @override
  Future<Result<bool>> toggleLikeFeedPost(int feedId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Verifica se já curtiu ANTES de fazer a ação
      final isLiked = await _likesService.checkIfUserLikedFeedPost(
        feedId: feedId,
        userId: userId,
      );

      if (isLiked) {
        // Descurtir
        final success = await _likesService.unlikeFeedPost(
          feedId: feedId,
          userId: userId,
        );
        return success
            ? Result.ok(false)
            : Result.error(Exception('Erro ao descurtir'));
      } else {
        // Curtir
        final success = await _likesService.likeFeedPost(
          feedId: feedId,
          userId: userId,
        );
        return success
            ? Result.ok(true)
            : Result.error(Exception('Erro ao curtir'));
      }
    } catch (e) {
      return Result.error(Exception('Erro ao alternar curtida: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleLikeAvaliacao(int avaliacaoId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Verifica se já curtiu
      final isLiked = await _likesService.checkIfUserLikedAvaliacao(
        avaliacaoId: avaliacaoId,
        userId: userId,
      );

      if (isLiked) {
        // Descurtir
        final success = await _likesService.unlikeAvaliacao(
          avaliacaoId: avaliacaoId,
          userId: userId,
        );
        return success
            ? Result.ok(false)
            : Result.error(Exception('Erro ao descurtir'));
      } else {
        // Curtir
        final success = await _likesService.likeAvaliacao(
          avaliacaoId: avaliacaoId,
          userId: userId,
        );
        return success
            ? Result.ok(true)
            : Result.error(Exception('Erro ao curtir'));
      }
    } catch (e) {
      return Result.error(Exception('Erro ao alternar curtida: $e'));
    }
  }

  @override
  Future<Result<bool>> checkIfUserLikedFeedPost(int feedId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Result.ok(false);
      }

      final isLiked = await _likesService.checkIfUserLikedFeedPost(
        feedId: feedId,
        userId: userId,
      );

      return Result.ok(isLiked);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar curtida: $e'));
    }
  }

  @override
  Future<Result<bool>> checkIfUserLikedAvaliacao(int avaliacaoId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return Result.ok(false);
      }

      final isLiked = await _likesService.checkIfUserLikedAvaliacao(
        avaliacaoId: avaliacaoId,
        userId: userId,
      );

      return Result.ok(isLiked);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar curtida: $e'));
    }
  }

  @override
  Future<Result<int>> getFeedPostLikesCount(int feedId) async {
    try {
      final count = await _likesService.getFeedPostLikesCount(feedId);
      return Result.ok(count);
    } catch (e) {
      return Result.error(Exception('Erro ao contar curtidas: $e'));
    }
  }

  @override
  Future<Result<int>> getAvaliacaoLikesCount(int avaliacaoId) async {
    try {
      final count = await _likesService.getAvaliacaoLikesCount(avaliacaoId);
      return Result.ok(count);
    } catch (e) {
      return Result.error(Exception('Erro ao contar curtidas: $e'));
    }
  }
}
