import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/auth/presentation/components/email_input.dart';
import 'package:laya/features/auth/presentation/components/error_display.dart';
import 'package:laya/features/auth/presentation/components/forgot_password_button.dart';
import 'package:laya/features/auth/presentation/components/login_button.dart';
import 'package:laya/features/auth/presentation/components/password_input.dart';
import 'package:laya/features/auth/presentation/components/signup_redirect.dart';
import 'package:laya/features/auth/presentation/components/social_buttons.dart';
import 'package:laya/features/auth/presentation/components/divider_with_text.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/models/user_model.dart';

// Form state provider
final loginFormProvider = StateProvider((ref) => LoginFormState());

// Login process state provider
final loginProcessProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

class LoginFormState {
  final String email;
  final String password;
  final bool showPassword;
  final String? emailError;
  final String? passwordError;

  // Immutable constructor with defaults
  LoginFormState({
    this.email = '',
    this.password = '',
    this.showPassword = false,
    this.emailError,
    this.passwordError,
  });

  // Create new state with specified changes
  LoginFormState copyWith({
    String? email,
    String? password,
    bool? showPassword,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }

  // Check if form is valid
  bool get isValid =>
      emailError == null &&
      passwordError == null &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      email.trim().isNotEmpty &&
      password.trim().isNotEmpty;
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final loginProcess = ref.watch(loginProcessProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Show welcome message on successful login
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, current) {
      current.whenData((user) {
        if (user != null && previous?.valueOrNull != user) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colorScheme.primary,
              content: Text(
                'Welcome back, ${user.username.isNotEmpty ? user.username : 'User'}!',
              ),
            ),
          );
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue reading',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              loginProcess.when(
                data: (_) => const SizedBox.shrink(),
                error: (error, _) => ErrorDisplay(message: error.toString()),
                loading: () => Container(),
              ),
              const SizedBox(height: 16),
              const EmailInput(),
              const SizedBox(height: 16),
              const PasswordInput(),
              const SizedBox(height: 24),
              const LoginButton(),
              const SizedBox(height: 16),
              const ForgotPasswordButton(),
              const SizedBox(height: 24),
              const DividerWithText(text: 'or continue with'),
              const SizedBox(height: 24),
              const SocialButtons(),
              const SizedBox(height: 24),
              const SignUpRedirect(),
            ],
          ),
        ),
      ),
    );
  }
}
