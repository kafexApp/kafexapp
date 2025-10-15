// lib/data/repositories/avaliacao_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../backend/supabase/supabase.dart';
import '../../services/avaliacao_service.dart';
import '../../services/user_profile_service.dart';
import '../../ui/cafe_detail/models/user_review_model.dart';
import '../../backend/supabase/tables/avaliacao_com_cafeteria.dart';
import '../../utils/result.dart';

/// Interface abstrata do repositório de avaliações
abstract class AvaliacaoRepository {
  Future<Result<List<UserReview>>> getAvaliacoesByCafeteria(int cafeteriaId);
  Future<Result<UserReview?>> getAvaliacaoById(int avaliacaoId);
  Future<Result<List<UserReview>>> getAvaliacoesByUser(int userId);
  Future<Result<int>> createAvaliacao({
    required int cafeteriaId,
    required String cafeteriaRef,
    required double nota,
    required String descricao,
    XFile? foto,
  });
  Future<Result<void>> updateAvaliacao({
    required int avaliacaoId,
    double? nota,
    String? descricao,
  });
  Future<Result<void>> deleteAvaliacao(int avaliacaoId);
  Future<Result<Map<String, dynamic>>> getAvaliacaoStats(int cafeteriaId);
}

/// Implementação do repositório de avaliações
class AvaliacaoRepositoryImpl implements AvaliacaoRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  AvaliacaoRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? firebaseStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<Result<List<UserReview>>> getAvaliacoesByCafeteria(
    int cafeteriaId,
  ) async {
    try {
      print('🔍 Repository: Buscando avaliações da cafeteria $cafeteriaId');

      final avaliacoes = await AvaliacaoService.getAvaliacoesByCafeteria(
        cafeteriaId,
      );

      // Converte para UserReview
      final reviews = avaliacoes
          .map((avaliacao) => UserReview.fromSupabase(avaliacao))
          .toList();

      print('✅ Repository: ${reviews.length} avaliações convertidas');
      return Result.ok(reviews);
    } catch (e) {
      print('❌ Repository: Erro ao buscar avaliações: $e');
      return Result.error(Exception('Erro ao buscar avaliações: $e'));
    }
  }

  @override
  Future<Result<UserReview?>> getAvaliacaoById(int avaliacaoId) async {
    try {
      print('🔍 Repository: Buscando avaliação ID $avaliacaoId');

      final avaliacao = await AvaliacaoService.getAvaliacaoById(avaliacaoId);

      if (avaliacao == null) {
        return Result.ok(null);
      }

      final review = UserReview.fromSupabase(avaliacao);
      print('✅ Repository: Avaliação encontrada');
      return Result.ok(review);
    } catch (e) {
      print('❌ Repository: Erro ao buscar avaliação: $e');
      return Result.error(Exception('Erro ao buscar avaliação: $e'));
    }
  }

  @override
  Future<Result<List<UserReview>>> getAvaliacoesByUser(int userId) async {
    try {
      print('🔍 Repository: Buscando avaliações do usuário $userId');

      final avaliacoes = await AvaliacaoService.getAvaliacoesByUser(userId);

      final reviews = avaliacoes
          .map((avaliacao) => UserReview.fromSupabase(avaliacao))
          .toList();

      print('✅ Repository: ${reviews.length} avaliações do usuário');
      return Result.ok(reviews);
    } catch (e) {
      print('❌ Repository: Erro ao buscar avaliações do usuário: $e');
      return Result.error(Exception('Erro ao buscar avaliações: $e'));
    }
  }

  @override
  Future<Result<int>> createAvaliacao({
    required int cafeteriaId,
    required String cafeteriaRef,
    required double nota,
    required String descricao,
    XFile? foto,
  }) async {
    try {
      print('📝 Repository: Criando nova avaliação');

      // Busca o usuário atual
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Busca o user_id no Supabase
      final userId = await _getUserIdFromSupabase(currentUser.uid);
      if (userId == 0) {
        return Result.error(
          Exception('Perfil do usuário não encontrado no Supabase'),
        );
      }

      // Upload da foto se houver
      String? fotoUrl;
      if (foto != null) {
        final uploadResult = await _uploadPhoto(
          foto,
          currentUser.uid,
          cafeteriaRef,
        );

        if (uploadResult.isError) {
          return Result.error(uploadResult.asError.error);
        }

        fotoUrl = uploadResult.asOk.value;
      }

      // Insere no Supabase
      final response = await SupaClient.client.from('avaliacao').insert({
        'user_id': userId,
        'user_ref': currentUser.uid,
        'cafeteria_id': cafeteriaId,
        'cafeteria_ref': cafeteriaRef,
        'nota': nota,
        'descricao': descricao,
        'foto_url': fotoUrl,
      }).select('id').single();

      final avaliacaoId = response['id'] as int;

      print('✅ Repository: Avaliação criada com ID $avaliacaoId');
      return Result.ok(avaliacaoId);
    } catch (e, stackTrace) {
      print('❌ Repository: Erro ao criar avaliação: $e');
      print('Stack trace: $stackTrace');
      return Result.error(Exception('Erro ao criar avaliação: $e'));
    }
  }

  @override
  Future<Result<void>> updateAvaliacao({
    required int avaliacaoId,
    double? nota,
    String? descricao,
  }) async {
    try {
      print('📝 Repository: Atualizando avaliação $avaliacaoId');

      final updateData = <String, dynamic>{};
      if (nota != null) updateData['nota'] = nota;
      if (descricao != null) updateData['descricao'] = descricao;

      if (updateData.isEmpty) {
        return Result.ok(null);
      }

      await SupaClient.client
          .from('avaliacao')
          .update(updateData)
          .eq('id', avaliacaoId);

      print('✅ Repository: Avaliação atualizada');
      return Result.ok(null);
    } catch (e) {
      print('❌ Repository: Erro ao atualizar avaliação: $e');
      return Result.error(Exception('Erro ao atualizar avaliação: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAvaliacao(int avaliacaoId) async {
    try {
      print('🗑️ Repository: Deletando avaliação $avaliacaoId');

      await SupaClient.client.from('avaliacao').delete().eq('id', avaliacaoId);

      print('✅ Repository: Avaliação deletada');
      return Result.ok(null);
    } catch (e) {
      print('❌ Repository: Erro ao deletar avaliação: $e');
      return Result.error(Exception('Erro ao deletar avaliação: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getAvaliacaoStats(
    int cafeteriaId,
  ) async {
    try {
      print('📊 Repository: Calculando estatísticas da cafeteria $cafeteriaId');

      final stats = await AvaliacaoService.getAvaliacaoStatsByCafeteria(
        cafeteriaId,
      );

      print('✅ Repository: Estatísticas calculadas');
      return Result.ok(stats);
    } catch (e) {
      print('❌ Repository: Erro ao calcular estatísticas: $e');
      return Result.error(Exception('Erro ao calcular estatísticas: $e'));
    }
  }

  /// Busca o ID do usuário no Supabase
  Future<int> _getUserIdFromSupabase(String firebaseUid) async {
    try {
      print('🔍 Buscando user_id do Supabase...');

      final profile = await UserProfileService.getUserProfile(firebaseUid);

      if (profile == null) {
        print('⚠️ Perfil não encontrado, usando 0 como fallback');
        return 0;
      }

      final userId = profile.id;
      print('✅ user_id encontrado: $userId');
      return userId ?? 0;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      return 0;
    }
  }

  /// Upload de foto da avaliação
  Future<Result<String>> _uploadPhoto(
    XFile photo,
    String usuarioUid,
    String cafeteriaRef,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'avaliacoes/$usuarioUid/${timestamp}_${_sanitizeFileName(cafeteriaRef)}.jpg';

      print('📤 Fazendo upload da foto: $fileName');

      final storageRef = _firebaseStorage.ref().child(fileName);

      // Upload diferente para web e mobile
      if (kIsWeb) {
        // WEB: usar putData com bytes
        final bytes = await photo.readAsBytes();
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('✅ Upload concluído (web): $downloadUrl');
        return Result.ok(downloadUrl);
      } else {
        // MOBILE: usar putFile
        final file = File(photo.path);
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('✅ Upload concluído (mobile): $downloadUrl');
        return Result.ok(downloadUrl);
      }
    } catch (e) {
      print('❌ Erro no upload da foto: $e');
      return Result.error(Exception('Erro ao fazer upload da foto: $e'));
    }
  }

  /// Remove caracteres especiais do nome do arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}