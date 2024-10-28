import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/auth/data/auth_repository.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileSettingsPage extends StatefulWidget {
  final User user;

  const UserProfileSettingsPage({super.key, required this.user});

  @override
  State<UserProfileSettingsPage> createState() =>
      _UserProfileSettingsPageState();
}

class _UserProfileSettingsPageState extends State<UserProfileSettingsPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.02,
            vertical: screenHeight * 0.01,
          ),
          child: Column(
            children: [
              _buildSettingItem(
                context: context,
                icon: LucideIcons.palette,
                title: 'Change Theme',
                onTap: () => context.push('/theme'),
              ),
              _buildSettingItem(
                context: context,
                icon: LucideIcons.userCog,
                title: 'Edit Profile Information',
                onTap: () => context.push('/edit-profile'),
              ),
              _buildSettingItem(
                context: context,
                icon: LucideIcons.key,
                title: 'Update Password',
                onTap: () => context.push('/update-password'),
              ),
              _buildSettingItem(
                context: context,
                icon: LucideIcons.trash,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () => context.push('/delete_account'),
              ),
              _buildSettingItem(
                context: context,
                icon: LucideIcons.logOut,
                title: 'Log Out',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenHeight * 0.02,
              vertical: screenHeight * 0.02,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenHeight * 0.012),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? colorScheme.error.withOpacity(0.1)
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isDestructive ? colorScheme.error : colorScheme.primary,
                    size: screenHeight * 0.024,
                  ),
                ),
                SizedBox(width: screenHeight * 0.02),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: colorScheme.onSurface.withOpacity(0.5),
                  size: screenHeight * 0.024,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.02),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontSize: screenHeight * 0.018,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: screenHeight * 0.018,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _authRepository.signOut();
              context.go('/sign_in');
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: screenHeight * 0.018,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
