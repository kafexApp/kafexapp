import 'package:flutter/material.dart';
import '../../models/post_models.dart';
import 'traditional_post_card.dart';
import 'review_post_card.dart';
import 'new_coffee_post_card.dart';

class PostCardFactory {
  static Widget create({
    required PostData post,
    required PostType type,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    
    // Propriedades específicas para Review
    String? coffeeName,
    double? rating,
    String? coffeeId,
    bool? isFavorited,
    bool? wantToVisit,
    VoidCallback? onFavorite,
    VoidCallback? onWantToVisit,
    
    // Propriedades específicas para New Coffee
    String? coffeeAddress,
    VoidCallback? onEvaluateNow,
    
    // Propriedades específicas para Traditional
    VoidCallback? onViewAllComments,
  }) {
    // DEBUG: Log dos dados recebidos
    print('🏭 [FACTORY] Criando post tipo: $type');
    print('🏭 [FACTORY] Post ID: ${post.id}');
    print('🏭 [FACTORY] Post imageUrl: ${post.imageUrl}');
    print('🏭 [FACTORY] Post autor: ${post.authorName}');
    print('🏭 [FACTORY] Post conteúdo: ${post.content}');
    
    switch (type) {
      case PostType.traditional:
        print('🏭 [FACTORY] Criando TraditionalPostCard');
        return TraditionalPostCard(
          post: post,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
          onViewAllComments: onViewAllComments,
        );
        
      case PostType.coffeeReview:
        print('🏭 [FACTORY] Criando ReviewPostCard');
        if (coffeeName == null || rating == null || coffeeId == null) {
          print('❌ [FACTORY] Erro: Review posts require coffeeName, rating, and coffeeId');
          // Fallback para traditional se dados insuficientes
          return TraditionalPostCard(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }
        return ReviewPostCard(
          post: post,
          coffeeName: coffeeName,
          rating: rating,
          coffeeId: coffeeId,
          isFavorited: isFavorited ?? false,
          wantToVisit: wantToVisit ?? false,
          onFavorite: onFavorite,
          onWantToVisit: onWantToVisit,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
        );
        
      case PostType.newCoffee:
        print('🏭 [FACTORY] Criando NewCoffeePostCard');
        if (coffeeName == null || coffeeAddress == null || coffeeId == null) {
          print('❌ [FACTORY] Erro: New coffee posts require coffeeName, coffeeAddress, and coffeeId');
          // Fallback para traditional se dados insuficientes
          return TraditionalPostCard(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onEdit: onEdit,
            onDelete: onDelete,
          );
        }
        return NewCoffeePostCard(
          post: post,
          coffeeName: coffeeName,
          coffeeAddress: coffeeAddress,
          coffeeId: coffeeId,
          onEvaluateNow: onEvaluateNow,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
        );
        
      default:
        print('🏭 [FACTORY] Tipo desconhecido, usando Traditional como fallback');
        // Fallback para post tradicional
        return TraditionalPostCard(
          post: post,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
        );
    }
  }
  
  // Método auxiliar para criar post a partir de um Map (útil para APIs)
  static Widget createFromMap(Map<String, dynamic> data) {
    final postType = _getPostTypeFromString(data['type'] ?? 'traditional');
    
    final post = PostData(
      id: data['id'] ?? '',
      authorName: data['authorName'] ?? '',
      authorAvatar: data['authorAvatar'] ?? '',
      date: data['date'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      recentComments: [],
    );
    
    return create(
      post: post,
      type: postType,
      coffeeName: data['coffeeName'],
      rating: data['rating']?.toDouble(),
      coffeeId: data['coffeeId'],
      coffeeAddress: data['coffeeAddress'],
      isFavorited: data['isFavorited'],
      wantToVisit: data['wantToVisit'],
    );
  }
  
  static PostType _getPostTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'review':
      case 'coffee_review':
        return PostType.coffeeReview;
      case 'new':
      case 'new_coffee':
        return PostType.newCoffee;
      case 'traditional':
      default:
        return PostType.traditional;
    }
  }
}