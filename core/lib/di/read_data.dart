import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase.dart';

class ReadData {
  final SupabaseClient _client = SupabaseConnect().client!;

  Future<List<Map<String, dynamic>>> get({
    required String table,
    List<String>? columns,
    Map<String, dynamic>? filters,
  }) async {
    var query = _client
        .from(table)
        .select(columns != null ? columns.join(',') : '*');

    /// apply filters (= only)
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    final res = await query;
    return List<Map<String, dynamic>>.from(res);
  }
}

// Cách dùng
// final users = await readData.get(
//   table: 'users',
//   columns: ['id', 'full_name', 'role'],
// );