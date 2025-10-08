// lib/data/repositories/favorito_repository.dart

import '../../utils/result.dart';
import '../../services/favorito_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Interface abstrata para repositório de Favoritos
abstract class FavoritoRepository {
  Future<Result<bool>> toggleFavorito(int cafeteriaId);
  Future<Result<bool>> checkIfUserFavorited(int cafeteriaId);
  Future<Result<List<Map<String, dynamic>>>> getUserFavoritosList();
  Future<Result<int>> countFavoritos();
}

/// Implementação real do repositório de Favoritos
class FavoritoRepositoryImpl implements FavoritoRepository {
  final FavoritoService _favoritoService = FavoritoService();

  /// Obtém o Firebase UID do usuário atual
  String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<Result<bool>> toggleFavorito(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final success = await _favoritoService.toggleFavorito(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return success
          ? Result.ok(true)
          : Result.error(Exception('Falha ao alternar favorito'));
    } catch (e) {
      return Result.error(Exception('Erro ao alternar favorito: $e'));
    }
  }

  @override
  Future<Result<bool>> checkIfUserFavorited(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.ok(false);
      }

      final isFavorited = await _favoritoService.checkIfUserFavorited(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return Result.ok(isFavorited);
    } catch (e) {
      return Result.error(Exception('Erro ao verificar favorito: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserFavoritosList() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final favoritos = await _favoritoService.getUserFavoritosList(
        firebaseUid,
      );

      return Result.ok(favoritos);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar favoritos: $e'));
    }
  }

  @override
  Future<Result<int>> countFavoritos() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.ok(0);
      }

      final count = await _favoritoService.countUserFavoritos(
        firebaseUid,
      );

      return Result.ok(count);
    } catch (e) {
      return Result.error(Exception('Erro ao contar favoritos: $e'));
    }
  }
}