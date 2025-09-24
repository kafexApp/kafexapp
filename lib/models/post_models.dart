// lib/models/post_models.dart
import 'comment_models.dart';

class PostData {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String date;
  final String? imageUrl;
  final String? videoUrl;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;
  final List<CommentData> recentComments;

  PostData({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    this.imageUrl,
    this.videoUrl,
    required this.content,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.recentComments = const [],
  });

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'date': date,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'content': content,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'recentComments': recentComments.map((c) => c.toJson()).toList(),
    };
  }

  // Método para criar instância a partir de JSON
  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      id: json['id'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      date: json['date'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      content: json['content'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      recentComments: (json['recentComments'] as List<dynamic>?)
          ?.map((c) => CommentData.fromJson(c))
          .toList() ?? [],
    );
  }

  // Método para criar uma cópia com alterações
  PostData copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? date,
    String? imageUrl,
    String? videoUrl,
    String? content,
    int? likes,
    int? comments,
    bool? isLiked,
    List<CommentData>? recentComments,
  }) {
    return PostData(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      recentComments: recentComments ?? this.recentComments,
    );
  }
}