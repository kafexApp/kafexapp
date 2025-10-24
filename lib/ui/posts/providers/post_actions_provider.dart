import 'package:flutter/material.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/viewmodel/post_actions_viewmodel.dart';
import 'package:provider/provider.dart';

/// Provider corrigido que atualiza o ViewModel quando o Post muda
class PostActionsProvider extends StatefulWidget {
  final Post post;
  final Widget child;

  const PostActionsProvider({
    super.key,
    required this.post,
    required this.child,
  });

  @override
  State<PostActionsProvider> createState() => _PostActionsProviderState();
}

class _PostActionsProviderState extends State<PostActionsProvider> {
  late PostActionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PostActionsViewModel(
      postId: widget.post.id,
      initialPost: widget.post,
    );
  }

  @override
  void didUpdateWidget(PostActionsProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detecta mudanças no post e recria o ViewModel
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.isLiked != widget.post.isLiked ||
        oldWidget.post.likes != widget.post.likes ||
        oldWidget.post.comments != widget.post.comments) {

      // Descarta o ViewModel antigo e cria um novo
      _viewModel.dispose();
      _viewModel = PostActionsViewModel(
        postId: widget.post.id,
        initialPost: widget.post,
      );
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostActionsViewModel>.value(
      value: _viewModel,
      child: widget.child,
    );
  }
}