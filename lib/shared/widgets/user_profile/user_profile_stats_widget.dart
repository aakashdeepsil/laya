import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/profile/data/user_repository.dart';

class UserProfileStats extends StatefulWidget {
  final User user;

  const UserProfileStats({super.key, required this.user});

  @override
  State<UserProfileStats> createState() => _UserProfileStatsState();
}

class _UserProfileStatsState extends State<UserProfileStats> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final UserRepository _userRepository = UserRepository();

  String followers = '0';
  String following = '0';

  Future<void> _fetchStats() async {
    try {
      final response = await _userRepository.getFollowCounts(widget.user.id);

      setState(() {
        followers = response['followers'].toString();
        following = response['following'].toString();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'Failed to load user stats: $e',
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatItem(value: followers, label: 'Followers'),
        Container(
          height: screenHeight * 0.04,
          width: 1,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        ),
        StatItem(value: following, label: 'Following'),
      ],
    );
  }
}

class StatItem extends StatefulWidget {
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  State<StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<StatItem> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.value,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          widget.label,
          style: TextStyle(fontSize: screenHeight * 0.014),
        ),
      ],
    );
  }
}
