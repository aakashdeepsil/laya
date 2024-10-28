import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';

class EditUserProfileButton extends StatefulWidget {
  final User user;

  const EditUserProfileButton({super.key, required this.user});

  @override
  State<EditUserProfileButton> createState() => _EditUserProfileButtonState();
}

class _EditUserProfileButtonState extends State<EditUserProfileButton> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.push(
        '/edit_user_profile_page',
        extra: widget.user,
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.01),
        ),
      ),
      child: Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: screenHeight * 0.016,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
