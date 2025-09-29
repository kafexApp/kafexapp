import 'package:flutter/material.dart';
import 'package:kafex/data/models/domain/post.dart';
import 'package:kafex/ui/posts/providers/post_actions_provider.dart';
import 'package:kafex/ui/posts/widgets/traditional_post_widget.dart';
import 'package:kafex/ui/posts/widgets/review_post_widget.dart';
import 'package:kafex/ui/posts/widgets/new_coffee_post_widget.dart';

class PostCardFactory {
  static Widget create({
    required Post post,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    print('🏭 [FACTORY] Criando post tipo: ${post.type}');
    print('🏭 [FACTORY] coffeeName: ${post.coffeeName}');
    print('🏭 [FACTORY] rating: ${post.rating}');

    switch (post.type) {
      case DomainPostType.traditional:
        return PostActionsProvider(
          post: post,
          child: TraditionalPostWidget(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );

      case DomainPostType.coffeeReview:
        return PostActionsProvider(
          post: post,
          child: ReviewPostWidget(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );

      case DomainPostType.newCoffee:
        return PostActionsProvider(
          post: post,
          child: NewCoffeePostWidget(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );

      default:
        return PostActionsProvider(
          post: post,
          child: TraditionalPostWidget(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );
    }
  }
}