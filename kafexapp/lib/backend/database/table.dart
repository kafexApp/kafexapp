import 'row.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  Future<List<T>> queryRows({
    required Future<dynamic> Function(dynamic query) queryFn,
    int? limit,
    int? offset,
  }) async {
    // Aqui depois vamos conectar com Supabase de verdade
    return [];
  }
}
