import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kafex/data/repositories/user_profile_repository.dart';
import 'package:kafex/ui/user_profile/viewmodel/user_profile_viewmodel.dart';
import 'package:kafex/ui/user_profile/widgets/user_profile_screen.dart';

class UserProfileProvider extends StatelessWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const UserProfileProvider({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository
        Provider<UserProfileRepository>(
          create: (_) => UserProfileRepositoryImpl(),
        ),
        
        // ViewModel
        ChangeNotifierProvider<UserProfileViewModel>(
          create: (context) => UserProfileViewModel(
            repository: context.read<UserProfileRepository>(),
            userId: userId,
          ),
        ),
      ],
      child: UserProfileScreen(),
    );
  }
}