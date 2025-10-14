import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kafex/data/repositories/profile_settings_repository.dart';
import 'package:kafex/ui/profile_settings/viewmodel/profile_settings_viewmodel.dart';
import 'package:kafex/ui/profile_settings/widgets/profile_settings_screen.dart';

class ProfileSettingsProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository
        Provider<ProfileSettingsRepository>(
          create: (_) => ProfileSettingsRepositoryImpl(),
        ),
        
        // ViewModel
        ChangeNotifierProvider<ProfileSettingsViewModel>(
          create: (context) => ProfileSettingsViewModel(
            repository: context.read<ProfileSettingsRepository>(),
          ),
        ),
      ],
      child: ProfileSettingsScreen(),
    );
  }
}