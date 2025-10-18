import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/analytics_repository.dart'; // NOVO
import '../../../data/services/supabase_service.dart';
import '../viewmodel/home_feed_viewmodel.dart';
import 'home_screen.dart';

class HomeScreenProvider extends StatelessWidget {
  const HomeScreenProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NOVO - Pega o AnalyticsRepository do Provider global
    final analyticsRepository = Provider.of<AnalyticsRepository>(
      context,
      listen: false,
    );

    return ChangeNotifierProvider(
      create: (_) => HomeFeedViewModel(
        feedRepository: FeedRepositoryImpl(
          supabaseService: SupabaseService(),
        ),
        analyticsRepository: analyticsRepository, // NOVO
      ),
      child: const HomeScreen(),
    );
  }
}