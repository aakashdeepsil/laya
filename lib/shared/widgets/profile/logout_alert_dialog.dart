import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/providers/auth_provider.dart';

class LogoutAlertDialog extends ConsumerWidget {
  const LogoutAlertDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building LogoutAlertDialog', name: 'LogoutDialog');

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, current) {
      developer.log(
        'Auth state changed in LogoutAlertDialog: ${current.valueOrNull != null ? "Authenticated" : "Unauthenticated"}',
        name: 'LogoutDialog',
      );

      // If logged out successfully, navigate to login page
      if (previous?.valueOrNull != null && current.valueOrNull == null) {
        developer.log(
          'User logged out successfully, navigating to login',
          name: 'LogoutDialog',
        );
        if (context.mounted) {
          // Close the dialog
          context.pop();
          // Navigate to login
          context.go('/login');
        }
      }

      // Handle errors
      if (current.hasError && context.mounted) {
        developer.log(
          'Error in auth state: ${current.error}',
          name: 'LogoutDialog',
          error: current.error,
        );

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            content: Text(
              'Failed to log out: ${current.error}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _handleLogout(context, ref),
            ),
          ),
        );
      }
    });

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.logout_rounded,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Log Out',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to log out of your account?',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      actions: [
        // Cancel button
        OutlinedButton(
          onPressed: () {
            developer.log('Logout canceled', name: 'LogoutDialog');
            context.pop();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Logout button
        Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authStateProvider);
            final isLoading = authState.isLoading;

            return FilledButton(
              onPressed: isLoading ? null : () => _handleLogout(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                disabledBackgroundColor: colorScheme.error.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onError,
                      ),
                    )
                  : Text(
                      'Log Out',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            );
          },
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    developer.log('Attempting to log out', name: 'LogoutDialog');
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      developer.log('Logout initiated through service', name: 'LogoutDialog');
    } catch (e) {
      developer.log('Error during logout: $e', name: 'LogoutDialog', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
