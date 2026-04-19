import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';

class Crud {
  final supabase = get<SupabaseConnect>().client!;

  /// 1. TẠO BẢNG (chỉ chạy 1 lần)
  Future<void> createTable() async {
    try {
      await supabase.rpc('create_test_users_table');
    } catch (e) {
      print("Lỗi tạo bảng: $e");
    }
  }

  /// 2. THÊM DỮ LIỆU
  Future<void> insertUser(String name, String password) async {
    try {
      await supabase.from('test_users').insert({
        'name': name,
        'password': password,
      });
    } catch (e) {
      print("Lỗi insert: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final res = await supabase.from('test_users').select();
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("Lỗi getUsers: $e");
      return [];
    }
  }
}
