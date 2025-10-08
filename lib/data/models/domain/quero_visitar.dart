// lib/data/models/domain/quero_visitar.dart

/// Modelo de domínio para a funcionalidade "Quero Visitar"
/// Representa uma cafeteria que o usuário marcou para visitar
class QueroVisitar {
  final int id;
  final int cafeteriaId;
  final int usuarioId;
  final DateTime criadoEm;
  final bool visitado;
  final DateTime? visitadoEm;

  QueroVisitar({
    required this.id,
    required this.cafeteriaId,
    required this.usuarioId,
    required this.criadoEm,
    this.visitado = false,
    this.visitadoEm,
  });

  /// Cria uma instância a partir de um Map do Supabase
  factory QueroVisitar.fromJson(Map<String, dynamic> json) {
    return QueroVisitar(
      id: json['id'] as int,
      cafeteriaId: json['cafeteria_id'] as int,
      usuarioId: json['id_usuario'] as int,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      visitado: json['visitado'] as bool? ?? false,
      visitadoEm: json['visitado_em'] != null
          ? DateTime.parse(json['visitado_em'] as String)
          : null,
    );
  }

  /// Converte para Map para enviar ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'cafeteria_id': cafeteriaId,
      'id_usuario': usuarioId,
      'visitado': visitado,
      'visitado_em': visitadoEm?.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos atualizados
  QueroVisitar copyWith({
    int? id,
    int? cafeteriaId,
    int? usuarioId,
    DateTime? criadoEm,
    bool? visitado,
    DateTime? visitadoEm,
  }) {
    return QueroVisitar(
      id: id ?? this.id,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      criadoEm: criadoEm ?? this.criadoEm,
      visitado: visitado ?? this.visitado,
      visitadoEm: visitadoEm ?? this.visitadoEm,
    );
  }

  @override
  String toString() {
    return 'QueroVisitar(id: $id, cafeteriaId: $cafeteriaId, usuarioId: $usuarioId, visitado: $visitado)';
  }
}