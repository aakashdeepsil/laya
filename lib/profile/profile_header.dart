import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileHeader extends StatefulWidget {
  final String username;
  final String lastName;
  final String firstName;
  final String bio;
  final String avatarUrl;

  const ProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.avatarUrl,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),
        if (widget.avatarUrl.isEmpty)
          CircleAvatar(
            radius: screenHeight * 0.05,
            child: Icon(
              LucideIcons.user,
              size: screenHeight * 0.075,
            ),
          )
        else
          CircleAvatar(
            radius: screenHeight * 0.05,
            backgroundImage: NetworkImage(widget.avatarUrl),
          ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          "${widget.firstName} ${widget.lastName}",
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
              "0 Following",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              "0 Followers",
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          widget.bio,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // ElevatedButton(
        //   onPressed: () => context.go('/profile/edit_profile'),
        //   child: const Text(
        //     "Edit Profile",
        //     style: TextStyle(
        //       fontSize: 16,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
