import 'package:flutter/material.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/viewmodel/post_actions_viewmodel.dart';
import 'package:provider/provider.dart';

class PostActionsProvider extends StatelessWidget {
  final Post post;
  final Widget child;

  const PostActionsProvider({
    super.key,
    required this.post,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostActionsViewModel(
        postId: post.id,
        initialPost: post,
      ),
      child: child,
    );
  }
}