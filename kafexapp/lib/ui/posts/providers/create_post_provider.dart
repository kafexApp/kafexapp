// lib/ui/posts/providers/create_post_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/create_post_viewmodel.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/services/supabase_service.dart';

class CreatePostProvider extends StatelessWidget {
  final Widget child;

  const CreatePostProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Cria diretamente a instância do repository e do viewmodel
    final feedRepository = FeedRepositoryImpl(
      supabaseService: SupabaseService(),
    );
    
    final viewModel = CreatePostViewModel(
      feedRepository: feedRepository,
    );

    return ChangeNotifierProvider<CreatePostViewModel>.value(
      value: viewModel,
      child: child,
    );
  }
}