import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'constants.dart';

class MagicLink extends StatelessWidget {
  const MagicLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Magic Link'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SupaMagicAuth(
              onSuccess: (response) {
                context.go('/home');
              },
              redirectUrl: kIsWeb
                  ? null
                  : 'com.example.laya://login-callback',
            ),
            TextButton(
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.go('sign_in');
              },
            ),
          ],
        ),
      ),
    );
  }
}