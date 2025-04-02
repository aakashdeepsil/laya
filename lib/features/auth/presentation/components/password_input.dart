import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/auth/presentation/login_screen.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/services/auth_validator.dart';

/// Password input field with validation and visibility toggle
class PasswordInput extends ConsumerStatefulWidget {
  const PasswordInput({super.key});

  @override
  PasswordInputState createState() => PasswordInputState();
}

class PasswordInputState extends ConsumerState<PasswordInput> {
  // Password field controller
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Restore password from state if available
    final formState = ref.read(loginFormProvider);
    if (_controller.text.isEmpty && formState.password.isNotEmpty) {
      _controller.text = formState.password;
    }
  }

  @override
  void dispose() {
    // Clean up controller
    _controller.dispose();
    super.dispose();
  }

  /// Updates form state with password and validation
  void _handlePasswordChange(String value) {
    final error =
        value.isNotEmpty ? AuthValidator.validatePassword(value) : null;

    ref.read(loginFormProvider.notifier).update((state) {
      if (error != null) {
        return state.copyWith(password: value, passwordError: error);
      } else {
        return state.copyWith(password: value, clearPasswordError: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current form state
    final formState = ref.watch(loginFormProvider);

    return TextField(
      controller: _controller,
      onChanged: _handlePasswordChange,
      obscureText: !formState.showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        // Toggle visibility button
        suffixIcon: IconButton(
          icon: Icon(
            formState.showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            // Toggle password visibility
            ref.read(loginFormProvider.notifier).update(
                  (state) => state.copyWith(showPassword: !state.showPassword),
                );
          },
        ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        errorText: formState.passwordError,
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _attemptLogin(),
    );
  }

  /// Validates fields and attempts login if valid
  void _attemptLogin() {
    final formState = ref.read(loginFormProvider);
    final authService = ref.read(authServiceProvider);

    // Validate fields
    final emailError = AuthValidator.validateEmail(formState.email);
    final passwordError = AuthValidator.validatePassword(formState.password);

    // Update validation errors
    ref.read(loginFormProvider.notifier).update((state) => state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
        ));

    // Proceed with login if valid
    if (emailError == null && passwordError == null) {
      // Update login process state to loading
      ref.read(loginProcessProvider.notifier).state =
          const AsyncValue.loading();

      // Attempt login using AuthService
      authService
          .signInWithEmailAndPassword(formState.email, formState.password)
          .then((user) {
        if (user == null) {
          // Login failed
          ref.read(loginProcessProvider.notifier).state =
              AsyncValue.error('Invalid credentials', StackTrace.current);
        } else {
          // Login successful
          ref.read(loginProcessProvider.notifier).state =
              const AsyncValue.data(null);
        }
      }).catchError((error) {
        // Error during login
        ref.read(loginProcessProvider.notifier).state =
            AsyncValue.error(error.toString(), StackTrace.current);
      });
    }
  }
}
