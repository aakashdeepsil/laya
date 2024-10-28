import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/user_profile/edit_user_profile_button_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_avatar.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_bio_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_name_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_stats_widget.dart';

class UserProfileHeader extends StatefulWidget {
  final User user;

  const UserProfileHeader({super.key, required this.user});

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.02),
      child: Column(
        children: [
          UserProfileAvatar(user: widget.user),
          SizedBox(height: screenHeight * 0.02),
          UserProfileName(user: widget.user),
          if (widget.user.bio.isNotEmpty) UserProfileBio(user: widget.user),
          SizedBox(height: screenHeight * 0.02),
          UserProfileStats(user: widget.user),
          SizedBox(height: screenHeight * 0.02),
          EditUserProfileButton(user: widget.user),
        ],
      ),
    );
  }
}
