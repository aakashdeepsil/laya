import 'package:flutter/material.dart';

Widget? usernameStatusIcon(BuildContext context, bool isCheckingUsername,
    String? usernameError, TextEditingController usernameController,
    [String? originalUsername]) {
  final colorScheme = Theme.of(context).colorScheme;

  if (isCheckingUsername) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      ),
    );
  } else if (usernameError == null &&
      usernameController.text.isNotEmpty &&
      usernameController.text != originalUsername) {
    return Icon(
      Icons.check_circle,
      color: colorScheme.primary,
      size: 20,
    );
  }
  return null;
}
