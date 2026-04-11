import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';

class TestUserData {
  final supabase = get<SupabaseConnect>().client!;

  Future<void> createUser(String name, String password) async {
    await supabase.from('test_users').insert({
      'name': name,
      'password': password,
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await supabase.from('test_users').select();
    return List<Map<String, dynamic>>.from(res);
  }
}
