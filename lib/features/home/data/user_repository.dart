import 'package:laya/config/supabase_config.dart';

class UserRepository {
  Future<Map<String, dynamic>> getUser(String userID) async {
    return await supabase.from('users').select().eq('id', userID).single();
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await supabase.from('users').insert(userData);
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    await supabase.from('users').update(userData).eq('id', id);
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }
}
