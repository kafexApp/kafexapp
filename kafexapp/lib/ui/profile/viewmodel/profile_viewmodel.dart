import 'package:flutter/foundation.dart';
import '../../../data/models/domain/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required UserRepository userRepository})
      : _userRepository = userRepository {
    load = Command0(_load)..execute();
  }

  final UserRepository _userRepository;
  
  late Command0<User> load;

  User? _user;
  User? get user => _user;

  Future<Result<User>> _load() async {
    final result = await _userRepository.getCurrentUser();
    
    if (result.isOk) {
      _user = result.asOk.value;
    }
    
    return result;
  }

  void refresh() {
    load.execute();
  }
}