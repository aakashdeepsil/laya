import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'SIGN IN',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.05,
        ),
        children: [
          SupaEmailAuth(
            redirectTo: kIsWeb ? null : 'com.example.laya://login-callback/',
            resetPasswordRedirectTo:
                kIsWeb ? null : 'com.example.laya://login-callback/',
            onSignInComplete: (response) => context.go('/home'),
            onSignUpComplete: (response) => context.go('/home'),
          ),
          const Divider(),
          Text(
            'OR',
            style: TextStyle(
              fontSize: screenHeight * 0.02,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          SupaSocialsAuth(
            colored: true,
            enableNativeAppleAuth: false,
            nativeGoogleAuthConfig: NativeGoogleAuthConfig(
              webClientId: dotenv.get('WEB_CLIENT_ID'),
              iosClientId: dotenv.get('IOS_CLIENT_ID'),
            ),
            onSuccess: (session) => context.go('/home'),
            socialProviders: socialProviders,
          ),
        ],
      ),
    );
  }
}
