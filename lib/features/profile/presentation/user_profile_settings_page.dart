import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/user_profile/logout_alert_dialog.dart';
import 'package:laya/shared/widgets/user_profile/settings_item_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: screenHeight * 0.0225,
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
              SettingsItem(
                icon: LucideIcons.palette,
                title: 'Change Theme',
                onTap: () => context.push('/change_theme_page'),
                isDestructive: false,
              ),
              SettingsItem(
                icon: LucideIcons.key,
                title: 'Update Password',
                onTap: () => context.push(
                  '/update_password_page',
                  extra: widget.user,
                ),
                isDestructive: false,
              ),
              SettingsItem(
                icon: LucideIcons.trash,
                title: 'Delete Account',
                isDestructive: true,
                onTap: () => context.push('/delete_account'),
              ),
              SettingsItem(
                icon: LucideIcons.logOut,
                title: 'Log Out',
                isDestructive: true,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => const LogoutAlertDialog(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
