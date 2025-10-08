// lib/data/repositories/quero_visitar_repository.dart

import '../../utils/result.dart';
import '../../services/quero_visitar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Interface abstrata para repositório de "Quero Visitar"
abstract class QueroVisitarRepository {
  Future<Result<bool>> toggleQueroVisitar(int cafeteriaId);
  Future<Result<bool>> checkIfUserWantsToVisit(int cafeteriaId);
  Future<Result<List<Map<String, dynamic>>>> getUserQueroVisitarList();
  Future<Result<List<Map<String, dynamic>>>> getUserVisitedList();
  Future<Result<bool>> markAsVisited(int cafeteriaId);
  Future<Result<bool>> unmarkAsVisited(int cafeteriaId);
  Future<Result<int>> countQueroVisitar();
  Future<Result<int>> countVisited();
}

/// Implementação real do repositório de "Quero Visitar"
class QueroVisitarRepositoryImpl implements QueroVisitarRepository {
  final QueroVisitarService _queroVisitarService = QueroVisitarService();

  /// Obtém o Firebase UID do usuário atual
  String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<Result<bool>> toggleQueroVisitar(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final success = await _queroVisitarService.toggleQueroVisitar(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return success
          ? Result.ok(true)
          : Result.error(Exception('Erro ao atualizar "quero visitar"'));
    } catch (e) {
      print('❌ Erro no repository toggleQueroVisitar: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<bool>> checkIfUserWantsToVisit(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.ok(false);
      }

      final isMarked = await _queroVisitarService.checkIfUserWantsToVisit(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return Result.ok(isMarked);
    } catch (e) {
      print('❌ Erro no repository checkIfUserWantsToVisit: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserQueroVisitarList() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final list = await _queroVisitarService.getUserQueroVisitarList(
        firebaseUid,
      );

      return Result.ok(list);
    } catch (e) {
      print('❌ Erro no repository getUserQueroVisitarList: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserVisitedList() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final list = await _queroVisitarService.getUserVisitedList(
        firebaseUid,
      );

      return Result.ok(list);
    } catch (e) {
      print('❌ Erro no repository getUserVisitedList: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<bool>> markAsVisited(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final success = await _queroVisitarService.markAsVisited(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return success
          ? Result.ok(true)
          : Result.error(Exception('Erro ao marcar como visitada'));
    } catch (e) {
      print('❌ Erro no repository markAsVisited: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<bool>> unmarkAsVisited(int cafeteriaId) async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      final success = await _queroVisitarService.unmarkAsVisited(
        cafeteriaId: cafeteriaId,
        usuarioUid: firebaseUid,
      );

      return success
          ? Result.ok(true)
          : Result.error(Exception('Erro ao desmarcar como visitada'));
    } catch (e) {
      print('❌ Erro no repository unmarkAsVisited: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<int>> countQueroVisitar() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.ok(0);
      }

      final count = await _queroVisitarService.countQueroVisitar(
        firebaseUid,
      );

      return Result.ok(count);
    } catch (e) {
      print('❌ Erro no repository countQueroVisitar: $e');
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<int>> countVisited() async {
    try {
      final firebaseUid = _getCurrentFirebaseUid();
      if (firebaseUid == null) {
        return Result.ok(0);
      }

      final count = await _queroVisitarService.countVisited(
        firebaseUid,
      );

      return Result.ok(count);
    } catch (e) {
      print('❌ Erro no repository countVisited: $e');
      return Result.error(e as Exception);
    }
  }
}