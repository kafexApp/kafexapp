// lib/backend/supabase/tables/comentario_com_usuario.dart
import '../../database/database.dart';

class ComentarioComUsuarioTable extends SupabaseTable<ComentarioComUsuarioRow> {
  @override
  String get tableName => 'comentario_com_usuario';

  @override
  ComentarioComUsuarioRow createRow(Map<String, dynamic> data) =>
      ComentarioComUsuarioRow(data);
}

class ComentarioComUsuarioRow extends SupabaseDataRow {
  ComentarioComUsuarioRow(Map<String, dynamic> data) : super(data);

  String? get comentarioId => getField<String>('comentario_id');
  set comentarioId(String? value) => setField<String>('comentario_id', value);

  DateTime? get comentarioCriadoEm {
    final value = getField<dynamic>('comentario_criado_em');
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  set comentarioCriadoEm(DateTime? value) =>
      setField<DateTime>('comentario_criado_em', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get userRef => getField<String>('user_ref');
  set userRef(String? value) => setField<String>('user_ref', value);

  String? get feedId => getField<String>('feed_id');
  set feedId(String? value) => setField<String>('feed_id', value);

  String? get comentario => getField<String>('comentario');
  set comentario(String? value) => setField<String>('comentario', value);

  String? get nomeExibicao => getField<String>('nome_exibicao');
  set nomeExibicao(String? value) => setField<String>('nome_exibicao', value);

  String? get fotoPerfil => getField<String>('foto_perfil');
  set fotoPerfil(String? value) => setField<String>('foto_perfil', value);
}
