import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/auth/data/auth_repository.dart';

class LogoutAlertDialog extends StatefulWidget {
  const LogoutAlertDialog({super.key});

  @override
  State<LogoutAlertDialog> createState() => _LogoutAlertDialogState();
}

class _LogoutAlertDialogState extends State<LogoutAlertDialog> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final AuthRepository _authRepository = AuthRepository();

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      if (mounted) {
        context.go('/sign_in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to log out. Please try again.",
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenHeight * 0.02),
      ),
      title: Text(
        'Log Out',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: screenHeight * 0.022,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        'Are you sure you want to log out?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          fontSize: screenHeight * 0.018,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: logout,
          child: Text(
            'Log Out',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
