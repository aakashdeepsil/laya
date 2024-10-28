import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';

class UserProfileBio extends StatefulWidget {
  final User user;

  const UserProfileBio({super.key, required this.user});

  @override
  State<UserProfileBio> createState() => _UserProfileBioState();
}

class _UserProfileBioState extends State<UserProfileBio> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: screenHeight * 0.01),
      child: Text(
        widget.user.bio,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: screenHeight * 0.016),
      ),
    );
  }
}
