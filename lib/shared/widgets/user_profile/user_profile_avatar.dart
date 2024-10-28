import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';

class UserProfileAvatar extends StatefulWidget {
  final User user;

  const UserProfileAvatar({super.key, required this.user});

  @override
  State<UserProfileAvatar> createState() => _UserProfileAvatarState();
}

class _UserProfileAvatarState extends State<UserProfileAvatar> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenHeight * 0.12,
      height: screenHeight * 0.12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.user.hasAvatar
            ? null
            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
        image: widget.user.hasAvatar
            ? DecorationImage(
                image: NetworkImage(widget.user.avatarUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !widget.user.hasAvatar
          ? Center(
              child: Text(
                widget.user.firstName.isNotEmpty
                    ? widget.user.firstName[0].toUpperCase()
                    : widget.user.username[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: screenHeight * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
