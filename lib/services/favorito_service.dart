// lib/services/favorito_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço responsável por gerenciar operações de favoritos no Supabase
class FavoritoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtém o Firebase UID do usuário atual
  String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Verifica se o usuário favoritou uma cafeteria
  Future<bool> checkIfUserFavorited({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      final response = await _supabase
          .from('favorito')
          .select('id')
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Erro ao verificar favorito: $e');
      return false;
    }
  }

  /// Adiciona uma cafeteria aos favoritos
  Future<bool> addFavorito({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      // Verifica se já está favoritado
      final alreadyFavorited = await checkIfUserFavorited(
        cafeteriaId: cafeteriaId,
        usuarioUid: usuarioUid,
      );

      if (alreadyFavorited) {
        print('⚠️ Cafeteria já está nos favoritos');
        return false;
      }

      // Insere o registro
      await _supabase.from('favorito').insert({
        'usuario_uid': usuarioUid,
        'cafeteria_id': cafeteriaId,
      });

      print('✅ Cafeteria adicionada aos favoritos');
      return true;
    } catch (e) {
      print('❌ Erro ao adicionar favorito: $e');
      return false;
    }
  }

  /// Remove uma cafeteria dos favoritos
  Future<bool> removeFavorito({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      await _supabase
          .from('favorito')
          .delete()
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid);

      print('✅ Cafeteria removida dos favoritos');
      return true;
    } catch (e) {
      print('❌ Erro ao remover favorito: $e');
      return false;
    }
  }

  /// Toggle: adiciona ou remove dos favoritos
  Future<bool> toggleFavorito({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      final isFavorited = await checkIfUserFavorited(
        cafeteriaId: cafeteriaId,
        usuarioUid: usuarioUid,
      );

      if (isFavorited) {
        return await removeFavorito(
          cafeteriaId: cafeteriaId,
          usuarioUid: usuarioUid,
        );
      } else {
        return await addFavorito(
          cafeteriaId: cafeteriaId,
          usuarioUid: usuarioUid,
        );
      }
    } catch (e) {
      print('❌ Erro ao alternar favorito: $e');
      return false;
    }
  }

  /// Obtém a lista de cafeterias favoritadas pelo usuário
  Future<List<Map<String, dynamic>>> getUserFavoritosList(
    String usuarioUid,
  ) async {
    try {
      final response = await _supabase
          .from('favorito')
          .select('*')
          .eq('usuario_uid', usuarioUid)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar favoritos: $e');
      return [];
    }
  }

  /// Conta quantas cafeterias o usuário favoritou
  Future<int> countUserFavoritos(
    String usuarioUid,
  ) async {
    try {
      final response = await _supabase
          .from('favorito')
          .select('id')
          .eq('usuario_uid', usuarioUid);

      return (response as List).length;
    } catch (e) {
      print('❌ Erro ao contar favoritos: $e');
      return 0;
    }
  }
}