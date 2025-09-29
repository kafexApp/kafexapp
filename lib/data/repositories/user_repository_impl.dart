import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/domain/user.dart';
import '../services/supabase_service.dart';
import '../../utils/result.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required SupabaseService supabaseService})
      : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final authUser = _supabaseService.currentUser;
      if (authUser == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      return getUser(authUser.id);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar usuário atual: $e'));
    }
  }

  @override
  Future<Result<User>> getUser(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('usuarios')
          .select()
          .eq('id', userId)
          .single();

      final user = User.fromJson(response);
      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar usuário: $e'));
    }
  }

  @override
  Future<Result<void>> updateUser(User user) async {
    try {
      await _supabaseService.client
          .from('usuarios')
          .update(user.toJson())
          .eq('id', user.id);

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar usuário: $e'));
    }
  }
}