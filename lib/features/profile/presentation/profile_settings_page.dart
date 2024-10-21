import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:provider/provider.dart';
import 'package:laya/theme/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsPage extends StatefulWidget {
  final Profile profile;

  const ProfileSettingsPage({super.key, required, required this.profile});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  void _toggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  void _editProfile() {
    context.push('/edit_profile', extra: widget.profile);
  }

  void _updatePassword() {
    context.push('/update_password', extra: widget.profile);
  }

  void _logOut() {
    Supabase.instance.client.auth.signOut();
    context.go('/sign_in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _buildListTile('Change Theme', _toggleTheme),
            _buildListTile('Edit Profile Information', _editProfile),
            _buildListTile('Update Password', _updatePassword),
            _buildListTile('Log Out', _logOut),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: screenHeight * 0.02),
      ),
      onTap: onTap,
    );
  }
}
