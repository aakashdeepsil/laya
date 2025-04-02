import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/auth/presentation/login_screen.dart';
import 'package:laya/providers/auth_provider.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginProcess = ref.watch(loginProcessProvider);
    final formState = ref.watch(loginFormProvider);
    final bool isFormValid = formState.isValid;

    // Dim button when form is invalid
    final double buttonOpacity = isFormValid ? 1.0 : 0.7;

    /// Gets button callback based on login process state and form validity
    /// Returns null when form is invalid or loading
    VoidCallback? getOnPressedCallback(
      AsyncValue<void> loginProcess,
      LoginFormState formState,
      bool isFormValid,
      WidgetRef ref,
    ) {
      // Disable button during loading
      if (loginProcess is AsyncLoading) {
        return null;
      }

      // Return login function if form is valid, null otherwise
      return isFormValid
          ? () async {
              try {
                // Get auth service reference
                final authService = ref.read(authServiceProvider);

                // Set loading state
                ref.read(loginProcessProvider.notifier).state =
                    const AsyncValue.loading();

                // Attempt login
                final user = await authService.signInWithEmailAndPassword(
                  formState.email.trim(),
                  formState.password.trim(),
                );

                if (user == null) {
                  // Login failed
                  ref.read(loginProcessProvider.notifier).state =
                      AsyncValue.error(
                          'Invalid credentials', StackTrace.current);
                } else {
                  // Login successful
                  ref.read(loginProcessProvider.notifier).state =
                      const AsyncValue.data(null);
                  // Redirect to home screen
                  context.go('/home');
                }
              } catch (e) {
                // Handle errors
                ref.read(loginProcessProvider.notifier).state =
                    AsyncValue.error(e.toString(), StackTrace.current);
              }
            }
          : null;
    }

    return Opacity(
      opacity: buttonOpacity,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: getOnPressedCallback(
            loginProcess,
            formState,
            isFormValid,
            ref,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: loginProcess.maybeWhen(
            loading: () => const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            orElse: () => const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
