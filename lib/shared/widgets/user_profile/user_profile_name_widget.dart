import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';

class UserProfileName extends StatefulWidget {
  final User user;

  const UserProfileName({super.key, required this.user});

  @override
  State<UserProfileName> createState() => _UserProfileNameState();
}

class _UserProfileNameState extends State<UserProfileName> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.user.fullName.isNotEmpty
          ? widget.user.fullName
          : widget.user.username,
      style: TextStyle(
        fontSize: screenHeight * 0.024,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
