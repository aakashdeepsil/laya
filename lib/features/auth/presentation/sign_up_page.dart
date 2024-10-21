import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/features/auth/data/auth_repository.dart';
import 'package:laya/features/home/data/user_repository.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepository = AuthRepository();
  final _UserRepository = UserRepository();

  Future<void> _signUp() async {
    try {
      final response = await _authRepository.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final profile = Profile(
        id: response.user!.id,
        email: response.user!.email!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _UserRepository.createUser(profile.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful!')),
        );

        context.push('/complete_profile', extra: response);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SIGN UP',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextButton(
              onPressed: () => context.push('/sign_in'),
              child: const Text("Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
