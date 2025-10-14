// lib/services/quero_visitar_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueroVisitarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtém o Firebase UID do usuário atual
  String? _getCurrentFirebaseUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Verifica se o usuário marcou uma cafeteria como "quero visitar"
  Future<bool> checkIfUserWantsToVisit({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      final response = await _supabase
          .from('quero_visitar')
          .select('id')
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Erro ao verificar "quero visitar": $e');
      return false;
    }
  }

  /// Adiciona uma cafeteria à lista "quero visitar"
  Future<bool> addQueroVisitar({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      // Verifica se já está marcado
      final alreadyMarked = await checkIfUserWantsToVisit(
        cafeteriaId: cafeteriaId,
        usuarioUid: usuarioUid,
      );

      if (alreadyMarked) {
        print('⚠️ Cafeteria já está na lista "quero visitar"');
        return false;
      }

      // Insere o registro
      await _supabase.from('quero_visitar').insert({
        'usuario_uid': usuarioUid,
        'cafeteria_id': cafeteriaId,
        'criado_em': DateTime.now().toIso8601String(),
        'visitado': false,
      });

      print('✅ Cafeteria adicionada à lista "quero visitar"');
      return true;
    } catch (e) {
      print('❌ Erro ao adicionar "quero visitar": $e');
      return false;
    }
  }

  /// Remove uma cafeteria da lista "quero visitar"
  Future<bool> removeQueroVisitar({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      await _supabase
          .from('quero_visitar')
          .delete()
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid);

      print('✅ Cafeteria removida da lista "quero visitar"');
      return true;
    } catch (e) {
      print('❌ Erro ao remover "quero visitar": $e');
      return false;
    }
  }

  /// Toggle - adiciona ou remove da lista "quero visitar"
  Future<bool> toggleQueroVisitar({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      final isMarked = await checkIfUserWantsToVisit(
        cafeteriaId: cafeteriaId,
        usuarioUid: usuarioUid,
      );

      if (isMarked) {
        return await removeQueroVisitar(
          cafeteriaId: cafeteriaId,
          usuarioUid: usuarioUid,
        );
      } else {
        return await addQueroVisitar(
          cafeteriaId: cafeteriaId,
          usuarioUid: usuarioUid,
        );
      }
    } catch (e) {
      print('❌ Erro ao fazer toggle "quero visitar": $e');
      return false;
    }
  }

  /// Busca todas as cafeterias que o usuário quer visitar
  Future<List<Map<String, dynamic>>> getUserQueroVisitarList(
    String usuarioUid,
  ) async {
    try {
      final response = await _supabase
          .from('quero_visitar')
          .select('*')
          .eq('usuario_uid', usuarioUid)
          .eq('visitado', false)
          .order('criado_em', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar lista "quero visitar": $e');
      return [];
    }
  }

  /// Busca todas as cafeterias já visitadas
  Future<List<Map<String, dynamic>>> getUserVisitedList(
    String usuarioUid,
  ) async {
    try {
      final response = await _supabase
          .from('quero_visitar')
          .select('*')
          .eq('usuario_uid', usuarioUid)
          .eq('visitado', true)
          .order('visitado_em', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar lista de visitados: $e');
      return [];
    }
  }

  /// Marca uma cafeteria como visitada
  Future<bool> markAsVisited({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      await _supabase
          .from('quero_visitar')
          .update({
            'visitado': true,
            'visitado_em': DateTime.now().toIso8601String(),
          })
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid);

      print('✅ Cafeteria marcada como visitada');
      return true;
    } catch (e) {
      print('❌ Erro ao marcar como visitada: $e');
      return false;
    }
  }

  /// Desmarca uma cafeteria como visitada (volta para "quero visitar")
  Future<bool> unmarkAsVisited({
    required int cafeteriaId,
    required String usuarioUid,
  }) async {
    try {
      await _supabase
          .from('quero_visitar')
          .update({
            'visitado': false,
            'visitado_em': null,
          })
          .eq('cafeteria_id', cafeteriaId)
          .eq('usuario_uid', usuarioUid);

      print('✅ Cafeteria desmarcada como visitada');
      return true;
    } catch (e) {
      print('❌ Erro ao desmarcar como visitada: $e');
      return false;
    }
  }

  /// Conta quantas cafeterias o usuário quer visitar
  Future<int> countQueroVisitar(String usuarioUid) async {
    try {
      final response = await _supabase
          .from('quero_visitar')
          .select()
          .eq('usuario_uid', usuarioUid)
          .eq('visitado', false)
          .count();

      return response.count;
    } catch (e) {
      print('❌ Erro ao contar "quero visitar": $e');
      return 0;
    }
  }

  /// Conta quantas cafeterias o usuário já visitou
  Future<int> countVisited(String usuarioUid) async {
    try {
      final response = await _supabase
          .from('quero_visitar')
          .select()
          .eq('usuario_uid', usuarioUid)
          .eq('visitado', true)
          .count();

      return response.count;
    } catch (e) {
      print('❌ Erro ao contar visitadas: $e');
      return 0;
    }
  }
}