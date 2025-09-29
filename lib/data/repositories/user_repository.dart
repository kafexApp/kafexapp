import '../models/domain/user.dart';
import '../../utils/result.dart';

abstract class UserRepository {
  Future<Result<User>> getUser(String userId);
  Future<Result<User>> getCurrentUser();
  Future<Result<void>> updateUser(User user);
}