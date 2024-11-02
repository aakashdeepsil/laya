import 'package:laya/config/schema/user.dart';
import 'package:laya/config/supabase_config.dart';

class UserRepository {
  // Get user information from Supabase
  Future<Map<String, dynamic>?> getUser(String userID) async {
    try {
      return await supabase.from('users').select().eq('id', userID).single();
    } catch (error) {
      throw Exception('Failed to load user information: $error');
    }
  }

  // Update user information in Supabase
  Future<void> updateUser(Map<String, dynamic> updates, String userID) async {
    try {
      await supabase.from('users').update(updates).eq('id', userID);
    } catch (error) {
      throw Exception('Failed to update user information: $error');
    }
  }

  // Delete user from Supabase
  Future<void> deleteUser(String id) async {
    try {
      await supabase.from('users').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete user: $error');
    }
  }

  // Check if username is available
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

  // Search users by username, first name, or last name
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .or('username.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%')
          .order('username');

      return (response as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to search users';
    }
  }

  // Follow a user
  Future<void> followUser(String userId) async {
    try {
      await supabase.from('followers').insert({
        'follower_id': supabase.auth.currentUser!.id,
        'following_id': userId,
      });
    } catch (e) {
      throw 'Failed to follow user';
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String userId) async {
    try {
      await supabase
          .from('followers')
          .delete()
          .eq('follower_id', supabase.auth.currentUser!.id)
          .eq('following_id', userId);
    } catch (e) {
      throw 'Failed to unfollow user';
    }
  }

  // Check if the current user is following another user
  Future<bool> isFollowing(String userId) async {
    try {
      final response = await supabase
          .from('followers')
          .select()
          .eq('follower_id', supabase.auth.currentUser!.id)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw 'Failed to check follow status';
    }
  }

  // Get the number of followers and following for a user
  Future<Map<String, dynamic>> getFollowCounts(String userId) async {
    try {
      final followers = await supabase
          .from('followers')
          .select('id')
          .eq('following_id', userId);

      final following = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', userId);

      return {
        'followers': followers.length,
        'following': following.length,
      };
    } catch (e) {
      throw 'Failed to get follow counts';
    }
  }
}
