import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/shared/widgets/profile/logout_alert_dialog.dart';
import 'package:laya/shared/widgets/profile/settings_item_widget.dart';
import 'package:laya/theme/theme_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('ProfileSettingsScreen initialized', name: 'ProfileSettings');
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building ProfileSettingsScreen UI', name: 'ProfileSettings');
    final colorScheme = Theme.of(context).colorScheme;

    // Get current user from auth provider
    final authState = ref.watch(authStateProvider);

    // Get theme mode from theme provider
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme.isDarkMode;

    // Handle loading/error states
    if (authState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings'), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.valueOrNull;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Not signed in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    developer.log(
      'Building settings for user: ${user.id}',
      name: 'ProfileSettings',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile summary
            _buildProfileSummary(user, colorScheme),

            // Settings sections
            _buildSettingsSection('Appearance', colorScheme),

            // Theme toggle
            SettingsItem(
              icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
              title: 'Change Theme',
              trailingWidget: Switch(
                value: isDarkMode,
                activeColor: colorScheme.primary,
                onChanged: (value) {
                  developer.log(
                    'Theme toggle: $value',
                    name: 'ProfileSettings',
                  );
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),
              onTap: () {
                developer.log(
                  'Theme setting tapped',
                  name: 'ProfileSettings',
                );
              },
              isDestructive: false,
            ),

            _buildSettingsSection('Account', colorScheme),

            SettingsItem(
              icon: LucideIcons.userCog,
              title: 'Edit Profile',
              onTap: () {
                developer.log(
                  'Edit Profile tapped',
                  name: 'ProfileSettings',
                );
                context.push('/edit_profile');
              },
              isDestructive: false,
            ),

            SettingsItem(
              icon: LucideIcons.key,
              title: 'Update Password',
              onTap: () {
                developer.log(
                  'Update Password tapped',
                  name: 'ProfileSettings',
                );
                context.push('/update_password', extra: user);
              },
              isDestructive: false,
            ),

            SettingsItem(
              icon: LucideIcons.bell,
              title: 'Notification Settings',
              onTap: () {
                developer.log(
                  'Notification Settings tapped',
                  name: 'ProfileSettings',
                );
                context.push('/notification_settings');
              },
              isDestructive: false,
            ),

            _buildSettingsSection('Help & Support', colorScheme),

            SettingsItem(
              icon: LucideIcons.helpCircle,
              title: 'Help Center',
              onTap: () {
                developer.log(
                  'Help Center tapped',
                  name: 'ProfileSettings',
                );
                context.push('/help_center');
              },
              isDestructive: false,
            ),

            SettingsItem(
              icon: LucideIcons.info,
              title: 'About Laya',
              onTap: () {
                developer.log('About tapped', name: 'ProfileSettings');
                _showAboutDialog(context);
              },
              isDestructive: false,
            ),

            _buildSettingsSection('Danger Zone', colorScheme),

            SettingsItem(
              icon: LucideIcons.logOut,
              title: 'Log Out',
              isDestructive: true,
              onTap: () {
                developer.log('Logout tapped', name: 'ProfileSettings');
                showDialog(
                  context: context,
                  builder: (context) => const LogoutAlertDialog(),
                );
              },
            ),

            SettingsItem(
              icon: LucideIcons.trash,
              title: 'Delete Account',
              isDestructive: true,
              onTap: () {
                developer.log('Delete Account tapped', name: 'ProfileSettings');
                _showDeleteAccountConfirmation(context);
              },
            ),

            const SizedBox(height: 32),

            // App version info
            Center(
              child: Text(
                'Laya v1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(User user, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // User avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Edit profile button
          IconButton(
            icon: const Icon(LucideIcons.pencil),
            onPressed: () {
              developer.log('Edit profile button tapped',
                  name: 'ProfileSettings');
              context.push('/edit_profile');
            },
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          'About Laya',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 64,
              width: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Laya v1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal book and reading companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2023 Laya Team',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be permanently removed. Are you sure you want to delete your account?',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              developer.log('Confirm delete account', name: 'ProfileSettings');

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Deleting account...'),
                    ],
                  ),
                ),
              );

              // try {
              //   // Delete account logic
              //   final authService = ref.read(authServiceProvider);
              //   await authService.deleteAccount();

              //   if (context.mounted) {
              //     Navigator.pop(context); // Close loading dialog
              //     context.go('/login');
              //   }
              // } catch (e) {
              //   developer.log('Error deleting account: $e',
              //       name: 'ProfileSettings', error: e);
              //   if (context.mounted) {
              //     Navigator.pop(context); // Close loading dialog
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Error: ${e.toString()}'),
              //         backgroundColor: colorScheme.error,
              //       ),
              //     );
              //   }
              // }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
