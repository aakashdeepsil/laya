import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/auth/data/auth_repository.dart';
import 'package:laya/features/auth/data/auth_validator.dart';
import 'package:laya/features/profile/data/user_repository.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await _authRepository.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final userResponse = await _userRepository.getUser(response.user!.id);

      if (userResponse == null) {
        throw Exception('Failed to load user information');
      }

      final user = User.fromJson(userResponse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Sign up successful!',
              style: TextStyle(fontSize: screenHeight * 0.01),
            ),
          ),
        );

        context.push('/complete_user_profile', extra: user);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign up failed. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.01),
            ),
          ),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: AuthValidator.validateEmail,
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: AuthValidator.validatePassword,
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () => context.push('/sign_in'),
                child: Text(
                  "Already have an account? Sign in",
                  style: TextStyle(fontSize: screenHeight * 0.015),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
