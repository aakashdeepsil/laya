import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/constants.dart';
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
      appBar: appBar('Profile Settings', automaticallyImplyLeading: true),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
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
