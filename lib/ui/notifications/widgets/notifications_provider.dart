import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../viewmodel/notifications_viewmodel.dart';
import 'notifications_screen.dart';

class NotificationsProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationsRepository>(
          create: (_) => NotificationsRepositoryImpl(),
        ),
        ChangeNotifierProvider<NotificationsViewModel>(
          create: (context) => NotificationsViewModel(
            repository: context.read<NotificationsRepository>(),
          ),
        ),
      ],
      child: NotificationsScreen(),
    );
  }
}