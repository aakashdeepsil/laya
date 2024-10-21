import 'package:laya/config/supabase_config.dart';

class UserRelationshipsService {
  // Future<int> getFollowingCount(String userId) async {
  //   try {
  //     final response = await supabase
  //         .from('user_relationships')
  //         .select('follower_id', const FetchOptions(count: CountOption.exact))
  //         .eq('follower_id', userId);

  //     return response.length;
  //   } catch (error) {
  //     throw Exception('Failed to fetch following count: $error');
  //   }
  // }

  // Future<int> getFollowersCount(String userId) async {
  //   try {
  //     final response = await supabase
  //         .from('user_relationships')
  //         .select('followed_id', const FetchOptions(count: CountOption.exact))
  //         .eq('followed_id', userId);

  //     return response.length;
  //   } catch (error) {
  //     throw Exception('Failed to fetch followers count: $error');
  //   }
  // }

  Future<bool> isFollowing(String currentUserId, String profileUserId) async {
    try {
      final response = await supabase
          .from('user_relationships')
          .select()
          .eq('follower_id', currentUserId)
          .eq('followed_id', profileUserId)
          .single();

      return response != null;
    } catch (error) {
      throw Exception('Failed to check following status: $error');
    }
  }

  Future<void> followUser(String currentUserId, String profileUserId) async {
    try {
      await supabase.from('user_relationships').insert({
        'follower_id': currentUserId,
        'followed_id': profileUserId,
      });
    } catch (error) {
      throw Exception('Failed to follow user: $error');
    }
  }

  Future<void> unfollowUser(String currentUserId, String profileUserId) async {
    try {
      await supabase
          .from('user_relationships')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', profileUserId);
    } catch (error) {
      throw Exception('Failed to unfollow user: $error');
    }
  }
}
