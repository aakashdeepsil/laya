import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('SIGN IN', automaticallyImplyLeading: true),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          SupaEmailAuth(
            redirectTo: kIsWeb ? null : 'com.example.laya://login-callback/',
            resetPasswordRedirectTo:
                kIsWeb ? null : 'com.example.laya://login-callback/',
            onSignInComplete: (response) {
              context.go('/home');
            },
            onSignUpComplete: (response) {
              context.go('/home');
            },
          ),
          const Divider(),
          optionText,
          spacer,
          ElevatedButton.icon(
            icon: const Icon(Icons.email),
            onPressed: () {
              context.go('/magic_link');
            },
            label: const Text('Sign in with Magic Link'),
          ),
          spacer,
          ElevatedButton.icon(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/phone_sign_in');
            },
            icon: const Icon(Icons.phone),
            label: const Text('Sign in with Phone'),
          ),
          spacer,
          SupaSocialsAuth(
            colored: true,
            nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
              webClientId:
                  '1041085987882-tf1dca8vbnv5ect9gqljupdpgr5iaqbp.apps.googleusercontent.com',
              iosClientId:
                  '1041085987882-jt7g00fbtaq13uckto4ti6nrvrunks9o.apps.googleusercontent.com',
            ),
            enableNativeAppleAuth: false,
            socialProviders: socialProviders,
            onSuccess: (session) {
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}
