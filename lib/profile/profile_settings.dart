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
  // Get the screen width and height
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Change Theme',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () => Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(),
            ),
            ListTile(
              title: Text(
                'Edit Profile Information',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () => context.push('/edit_profile'),
            ),
            ListTile(
              title: Text(
                'Update Password',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () => context.push('/update_password'),
            ),
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () {
                Supabase.instance.client.auth.signOut();
                context.go('/sign_in');
              },
            ),
          ],
        )),
      ),
    );
  }
}
