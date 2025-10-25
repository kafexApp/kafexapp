// lib/data/repositories/subscription_repository.dart

import '../../backend/supabase/supabase.dart';
import '../../utils/result.dart';
import '../models/domain/subscription_interest.dart';

abstract class SubscriptionRepository {
  /// Registra interesse do usuário na assinatura
  Future<Result<SubscriptionInterest>> registerInterest({
    required String userRef,
  });

  /// Verifica se usuário já tem interesse ativo
  Future<Result<bool>> hasActiveInterest({
    required String userRef,
  });

  /// Busca interesse do usuário
  Future<Result<SubscriptionInterest?>> getUserInterest({
    required String userRef,
  });

  /// Cancela interesse do usuário
  Future<Result<void>> cancelInterest({
    required String userRef,
  });
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final _supabase = SupaClient.client;

  @override
  Future<Result<SubscriptionInterest>> registerInterest({
    required String userRef,
  }) async {
    try {
      print('📝 Registrando interesse na assinatura...');
      print('   User Ref: $userRef');

      // Verificar se já existe interesse ativo
      final existingResult = await hasActiveInterest(userRef: userRef);
      
      if (existingResult.isOk && existingResult.asOk.value) {
        print('⚠️ Usuário já possui interesse ativo');
        
        // Buscar interesse existente
        final interestResult = await getUserInterest(userRef: userRef);
        if (interestResult.isOk && interestResult.asOk.value != null) {
          return Result.ok(interestResult.asOk.value!);
        }
      }

      // Inserir novo interesse
      final response = await _supabase
          .from('subscription_interest')
          .insert({
            'user_ref': userRef,
            'status': 'active',
          })
          .select()
          .single();

      final interest = SubscriptionInterest.fromJson(response);
      
      print('✅ Interesse registrado com sucesso: ID ${interest.id}');
      return Result.ok(interest);
    } catch (e, stackTrace) {
      print('❌ Erro ao registrar interesse: $e');
      print('Stack trace: $stackTrace');
      return Result.error(Exception('Erro ao registrar interesse: $e'));
    }
  }

  @override
  Future<Result<bool>> hasActiveInterest({
    required String userRef,
  }) async {
    try {
      print('🔍 Verificando interesse ativo para: $userRef');

      final response = await _supabase
          .from('subscription_interest')
          .select('id')
          .eq('user_ref', userRef)
          .eq('status', 'active')
          .maybeSingle();

      final hasInterest = response != null;
      
      print('   Tem interesse ativo: $hasInterest');
      return Result.ok(hasInterest);
    } catch (e) {
      print('❌ Erro ao verificar interesse: $e');
      return Result.error(Exception('Erro ao verificar interesse: $e'));
    }
  }

  @override
  Future<Result<SubscriptionInterest?>> getUserInterest({
    required String userRef,
  }) async {
    try {
      print('🔍 Buscando interesse do usuário: $userRef');

      final response = await _supabase
          .from('subscription_interest')
          .select()
          .eq('user_ref', userRef)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        print('   Nenhum interesse encontrado');
        return Result.ok(null);
      }

      final interest = SubscriptionInterest.fromJson(response);
      print('✅ Interesse encontrado: ID ${interest.id}');
      return Result.ok(interest);
    } catch (e) {
      print('❌ Erro ao buscar interesse: $e');
      return Result.error(Exception('Erro ao buscar interesse: $e'));
    }
  }

  @override
  Future<Result<void>> cancelInterest({
    required String userRef,
  }) async {
    try {
      print('🗑️ Cancelando interesse: $userRef');

      await _supabase
          .from('subscription_interest')
          .update({'status': 'cancelled'})
          .eq('user_ref', userRef)
          .eq('status', 'active');

      print('✅ Interesse cancelado com sucesso');
      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao cancelar interesse: $e');
      return Result.error(Exception('Erro ao cancelar interesse: $e'));
    }
  }
}