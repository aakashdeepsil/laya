import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';

class UserProfileStats extends StatefulWidget {
  final User user;

  const UserProfileStats({super.key, required this.user});

  @override
  State<UserProfileStats> createState() => _UserProfileStatsState();
}

class _UserProfileStatsState extends State<UserProfileStats> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StatItem(value: '0', label: 'Followers'),
        Container(
          height: screenHeight * 0.04,
          width: 1,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        ),
        const StatItem(value: '0', label: 'Following'),
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
          style: TextStyle(
            fontSize: screenHeight * 0.014,
          ),
        ),
      ],
    );
  }
}
