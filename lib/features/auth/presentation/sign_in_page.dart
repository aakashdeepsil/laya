import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart' as user_model;
import 'package:laya/features/auth/data/auth_repository.dart';
import 'package:laya/features/auth/data/auth_validator.dart';
import 'package:laya/features/auth/data/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await _authRepository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      final userMap = await _userRepository.getUser(response.user!.id);

      if (userMap == null) {
        throw Exception('Failed to load user information');
      }

      final user = user_model.User.fromJson(userMap);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Sign in successful!',
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
          ),
        );

        context.push('/complete_user_profile', extra: user);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              error.message,
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              error.message,
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error: ${error.toString()}',
              style: TextStyle(fontSize: screenHeight * 0.015),
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
          'SIGN IN',
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
                keyboardType: TextInputType.emailAddress,
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
                onPressed: _signIn,
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: screenHeight * 0.015),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () => context.push('/sign_up'),
                child: Text(
                  "Don't have an account? Sign up",
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
