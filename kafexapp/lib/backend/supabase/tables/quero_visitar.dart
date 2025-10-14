// lib/backend/supabase/tables/quero_visitar.dart
import '../../database/database.dart';

class QueroVisitarTable extends SupabaseTable<QueroVisitarRow> {
  @override
  String get tableName => 'quero_visitar';

  @override
  QueroVisitarRow createRow(Map<String, dynamic> data) =>
      QueroVisitarRow(data);
}

class QueroVisitarRow extends SupabaseDataRow {
  QueroVisitarRow(Map<String, dynamic> data) : super(data);

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get usuarioUid => getField<String>('usuario_uid');
  set usuarioUid(String? value) => setField<String>('usuario_uid', value);

  int? get cafeteriaId => getField<int>('cafeteria_id');
  set cafeteriaId(int? value) => setField<int>('cafeteria_id', value);

  DateTime? get criadoEm {
    final value = getField<dynamic>('criado_em');
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  set criadoEm(DateTime? value) {
    setField<String>('criado_em', value?.toIso8601String());
  }

  bool? get visitado => getField<bool>('visitado');
  set visitado(bool? value) => setField<bool>('visitado', value);

  DateTime? get visitadoEm {
    final value = getField<dynamic>('visitado_em');
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  set visitadoEm(DateTime? value) {
    setField<String>('visitado_em', value?.toIso8601String());
  }
}