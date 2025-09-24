class SupabaseDataRow {
  final Map<String, dynamic> data;
  SupabaseDataRow(this.data);

  T? getField<T>(String key) => data[key] as T?;
  void setField<T>(String key, T? value) => data[key] = value;
}
