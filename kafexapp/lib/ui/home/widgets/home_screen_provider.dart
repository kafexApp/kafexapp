import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../viewmodel/home_feed_viewmodel.dart';
import 'home_screen.dart';

class HomeScreenProvider extends StatelessWidget {
  const HomeScreenProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeFeedViewModel(
        feedRepository: FeedRepositoryImpl(
          supabaseService: SupabaseService(),
        ),
      ),
      child: const HomeScreen(),
    );
  }
}