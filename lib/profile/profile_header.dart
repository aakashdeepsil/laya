import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfileHeader extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // Get the screen width and height
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Variables to store the following and followers count
  int followingCount = 0;
  int followersCount = 0;

  // Function to get the following count
  Future<void> getFollowingCount() async {
    try {
      final response = await Supabase.instance.client
          .from('user_relationships')
          .select('follower_id')
          .eq('follower_id', widget.profile['id']);

      setState(() => followingCount = response.length);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Function to get the followers count
  Future<void> getFollowersCount() async {
    try {
      final response = await Supabase.instance.client
          .from('user_relationships')
          .select('followed_id')
          .eq('followed_id', widget.profile['id']);

      setState(() => followersCount = response.length);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowingCount();
    getFollowersCount();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.01),
        CircleAvatar(
          radius: screenHeight * 0.05,
          backgroundImage: NetworkImage(widget.profile['avatar_url']),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "${widget.profile['first_name']} ${widget.profile['last_name']}",
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: screenWidth * 0.03),
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
          widget.profile['bio'],
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
