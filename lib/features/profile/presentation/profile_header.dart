import 'package:flutter/material.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/config/supabase_config.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  int followingCount = 0;
  int followersCount = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _initializeProfileData();
  }

  Future<void> _initializeProfileData() async {
    await Future.wait([
      _getFollowingCount(),
      _getFollowersCount(),
      _checkIfFollowing(),
    ]);
  }

  Future<void> _getFollowingCount() async {
    try {
      final response = await supabase
          .from('user_relationships')
          .select('follower_id')
          .eq('follower_id', widget.profile.id);

      setState(() => followingCount = response.length);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  Future<void> _getFollowersCount() async {
    try {
      final response = await supabase
          .from('user_relationships')
          .select('followed_id')
          .eq('followed_id', widget.profile.id);

      setState(() => followersCount = response.length);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  Future<void> _checkIfFollowing() async {
    try {
      final data = await supabase
          .from('user_relationships')
          .select()
          .eq('follower_id', supabase.auth.currentUser!.id)
          .eq('followed_id', widget.profile.id);

      setState(() => isFollowing = data.isNotEmpty);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (isFollowing) {
      await _unfollowUser();
    } else {
      await _followUser();
    }
  }

  Future<void> _followUser() async {
    try {
      final response = await supabase.from('user_relationships').insert({
        'follower_id': supabase.auth.currentUser!.id,
        'followed_id': widget.profile.id,
      });

      if (response.error == null) {
        setState(() => isFollowing = true);
      } else {
        throw response.error!;
      }
    } catch (error) {
      // _showErrorSnackBar(error);
    }
  }

  Future<void> _unfollowUser() async {
    try {
      final response = await supabase
          .from('user_relationships')
          .delete()
          .eq('follower_id', supabase.auth.currentUser!.id)
          .eq('followed_id', widget.profile.id);

      if (response.error == null) {
        setState(() => isFollowing = false);
      } else {
        throw response.error!;
      }
    } catch (error) {
      // _showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.01),
        CircleAvatar(
          radius: screenHeight * 0.05,
          backgroundImage: NetworkImage(widget.profile.avatarUrl),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "${widget.profile.firstName} ${widget.profile.lastName}",
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$followersCount Followers",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              "$followingCount Following",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          widget.profile.bio,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        if (widget.profile.id != supabase.auth.currentUser?.id)
          ElevatedButton(
            onPressed: _toggleFollow,
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
      ],
    );
  }
}
