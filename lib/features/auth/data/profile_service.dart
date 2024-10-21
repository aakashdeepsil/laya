import 'package:laya/config/supabase_config.dart';

class ProfileService {
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      return await supabase.from('users').select().eq('id', userId).single();
    } catch (error) {
      throw Exception('Failed to load user information: $error');
    }
  }

  Future<void> updateProfile(
    Map<String, dynamic> updates,
    String userID,
  ) async {
    try {
      await supabase.from('users').update(updates).eq('id', userID);
    } catch (error) {
      throw Exception('Failed to update user information: $error');
    }
  }

  Future<void> updateAvatar(String imageUrl, String userId) async {
    try {
      return await supabase
          .from('users')
          .update({'avatar_url': imageUrl}).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update avatar: $error');
    }
  }
}
