import 'package:supabase_flutter/supabase_flutter.dart';

class SupaClient {
  SupaClient._();
  static SupabaseClient get client => Supabase.instance.client;
}
