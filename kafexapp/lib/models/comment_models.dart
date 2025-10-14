// lib/models/comment_models.dart

class CommentData {
  final String id;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;
  final String? authorAvatar; // Para compatibilidade com post_models
  final String? date; // Para compatibilidade com post_models

  CommentData({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.authorAvatar,
    this.date,
  });

  // Getter para compatibilidade com post_models
  String get authorName => userName;

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  // Método para criar instância a partir de JSON
  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      id: json['id'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  // Método para criar uma cópia com alterações
  CommentData copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? content,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return CommentData(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Factory para criar a partir do formato antigo (post_models)
  factory CommentData.fromPostComment({
    required String id,
    required String authorName,
    required String authorAvatar,
    required String content,
    required String date,
  }) {
    return CommentData(
      id: id,
      userName: authorName,
      userAvatar: authorAvatar.startsWith('http') ? authorAvatar : null,
      content: content,
      timestamp: DateTime.now(), // Mock - em produção, parsearia a data
      likes: 0,
      isLiked: false,
      authorAvatar: authorAvatar,
      date: date,
    );
  }
}