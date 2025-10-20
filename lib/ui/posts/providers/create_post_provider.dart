// lib/ui/posts/providers/create_post_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/create_post_viewmodel.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/services/supabase_service.dart';

class CreatePostProvider extends StatefulWidget {
  final Widget child;

  const CreatePostProvider({
    super.key,
    required this.child,
  });

  @override
  State<CreatePostProvider> createState() => _CreatePostProviderState();
}

class _CreatePostProviderState extends State<CreatePostProvider> {
  late CreatePostViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // CORREÇÃO: Cria o viewModel UMA VEZ no initState
    final feedRepository = FeedRepositoryImpl(
      supabaseService: SupabaseService(),
    );
    
    _viewModel = CreatePostViewModel(
      feedRepository: feedRepository,
    );
    
    print('✅ CreatePostProvider inicializado com ViewModel: ${_viewModel.hashCode}');
  }

  @override
  void dispose() {
    print('🗑️ CreatePostProvider sendo descartado');
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Usa .value para passar a instância já criada
    return ChangeNotifierProvider<CreatePostViewModel>.value(
      value: _viewModel,
      child: widget.child,
    );
  }
}