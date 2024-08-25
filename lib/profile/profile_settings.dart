import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/profile');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Change Theme'),
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(),
            ),
            ListTile(
              title: const Text('Edit Profile Information'),
              onTap: () {
                context.go('/edit_profile');
              },
            ),
            ListTile(
              title: const Text('Update Password'),
              onTap: () {
                context.go('/update_password');
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                Supabase.instance.client.auth.signOut();
                context.go('/');
              },
            ),
          ],
        )),
      ),
    );
  }
}
