import 'package:laya/config/supabase_config.dart';

class UserRepository {
  Future<Map<String, dynamic>?> getUser(String userID) async {
    try {
      return await supabase.from('users').select().eq('id', userID).single();
    } catch (error) {
      throw Exception('Failed to load user information: $error');
    }
  }

  Future<void> updateUser(Map<String, dynamic> updates, String userID) async {
    try {
      await supabase.from('users').update(updates).eq('id', userID);
    } catch (error) {
      throw Exception('Failed to update user information: $error');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await supabase.from('users').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete user: $error');
    }
  }

  Future<bool> isUsernameAvailable(
    String username, [
    String? currentUserID,
  ]) async {
    try {
      final response = await supabase.rpc(
        'check_username_availability',
        params: {
          'username_to_check': username,
          if (currentUserID != null) 'current_user_id': currentUserID,
        },
      );

      return response as bool;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }
}
