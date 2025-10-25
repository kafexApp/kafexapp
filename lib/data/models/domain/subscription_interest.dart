// lib/data/models/domain/subscription_interest.dart

class SubscriptionInterest {
  final int id;
  final String userRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  SubscriptionInterest({
    required this.id,
    required this.userRef,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// Factory para criar a partir do Supabase
  factory SubscriptionInterest.fromJson(Map<String, dynamic> json) {
    return SubscriptionInterest(
      id: json['id'] as int,
      userRef: json['user_ref'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String,
    );
  }

  /// Converte para JSON para enviar ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_ref': userRef,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  /// CopyWith para criar cópias imutáveis
  SubscriptionInterest copyWith({
    int? id,
    String? userRef,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return SubscriptionInterest(
      id: id ?? this.id,
      userRef: userRef ?? this.userRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'SubscriptionInterest(id: $id, userRef: $userRef, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionInterest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}