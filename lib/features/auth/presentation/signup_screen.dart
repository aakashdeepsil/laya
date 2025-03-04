import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/auth/presentation/components/social_buttons.dart';
import 'package:laya/features/auth/presentation/components/divider_with_text.dart';
import 'package:laya/features/auth/presentation/components/shake_curve.dart';
import 'package:laya/features/auth/presentation/signup_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:laya/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Add controllers as class fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: ShakeCurve()))
        .animate(_shakeController);

    // Set initial values
    _emailController.text = ref.read(emailProvider);
    _passwordController.text = ref.read(passwordProvider);
    _confirmPasswordController.text = ref.read(confirmPasswordProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);
    final confirmPassword = ref.read(confirmPasswordProvider);

    // Only update if values differ to avoid cursor reset
    if (_emailController.text != email) _emailController.text = email;
    if (_passwordController.text != password) {
      _passwordController.text = password;
    }
    if (_confirmPasswordController.text != confirmPassword) {
      _confirmPasswordController.text = confirmPassword;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    // Dispose all controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength += 0.25;
    return strength;
  }

  Color getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.green;
    return Colors.indigo;
  }

  String getStrengthText(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  bool validateEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool validateStep() {
    final step = ref.read(signupStepProvider);
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);
    final confirmPassword = ref.read(confirmPasswordProvider);

    String? error;
    switch (step) {
      case 1:
        if (email.isEmpty || !validateEmail(email)) {
          error = 'Please enter a valid email address';
        }
        break;
      case 2:
        if (password.length < 8) {
          error = 'Password must be at least 8 characters';
        } else if (password != confirmPassword) {
          error = 'Passwords do not match';
        }
        break;
    }

    if (error != null) {
      ref.read(errorProvider.notifier).state = error;
      _shakeController.forward().then((_) => _shakeController.reset());
      return false;
    }
    return true;
  }

  Future<void> handleSignup() async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      ref.read(errorProvider.notifier).state = null;

      final email = ref.read(emailProvider);
      final password = ref.read(passwordProvider);
      final username = email.split('@').first; // Default username from email

      // Get the auth service
      final authService = ref.read(authServiceProvider);

      // Create user with email and password
      final user = await authService.registerWithEmailAndPassword(
        email,
        password,
        username,
      );

      if (user != null) {
        // User created successfully
        ref.read(isLoadingProvider.notifier).state = false;

        if (mounted) {
          // Navigate to profile completion instead of home
          context.go('/complete_profile');
        }
      } else {
        throw Exception("Failed to create account");
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;

      // Handle specific Firebase Auth errors
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      ref.read(errorProvider.notifier).state = errorMessage;
      _shakeController.forward().then((_) => _shakeController.reset());
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(errorProvider.notifier).state = 'An unexpected error occurred';
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  void handleNext() {
    if (validateStep()) {
      final currentStep = ref.read(signupStepProvider);
      if (currentStep < 2) {
        ref.read(signupStepProvider.notifier).state = currentStep + 1;
        ref.read(errorProvider.notifier).state = null;
      } else {
        handleSignup();
      }
    }
  }

  void handleBack() {
    final currentStep = ref.read(signupStepProvider);
    if (currentStep > 1) {
      ref.read(signupStepProvider.notifier).state = currentStep - 1;
      ref.read(errorProvider.notifier).state = null;
    }
  }

  Widget buildCurrentStep() {
    final step = ref.watch(signupStepProvider);
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final confirmPassword = ref.watch(confirmPasswordProvider);
    final showPassword = ref.watch(showPasswordProvider);

    // Return only the UI for the current step
    switch (step) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's your email?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll send you a verification code",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              onChanged: (value) =>
                  ref.read(emailProvider.notifier).state = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
          ],
        );

      case 2:
        final strength = calculatePasswordStrength(password);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Make it strong and unique',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              onChanged: (value) =>
                  ref.read(passwordProvider.notifier).state = value,
              obscureText: !showPassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => ref
                      .read(showPasswordProvider.notifier)
                      .state = !showPassword,
                ),
              ),
            ),
            if (password.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: Colors.grey.shade800,
                  color: getStrengthColor(strength),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getStrengthText(strength),
                  style: TextStyle(
                    color: getStrengthColor(strength),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              onChanged: (value) =>
                  ref.read(confirmPasswordProvider.notifier).state = value,
              style: const TextStyle(color: Colors.white),
              obscureText: !showPassword,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                hintText: 'Confirm Password',
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(signupStepProvider);
    final error = ref.watch(errorProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: step / 2,
                      backgroundColor: Colors.grey.shade800,
                      color: Theme.of(context).colorScheme.secondary,
                      minHeight: 4,
                    ),
                  ),
                  if (step > 1)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: handleBack,
                    ),
                ],
              ),
              const SizedBox(height: 40),
              if (error != null)
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              buildCurrentStep(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : handleNext,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        step == 2 ? 'Create Account' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              if (step == 1) ...[
                const SizedBox(height: 24),
                const DividerWithText(text: 'or sign up with'),
                const SizedBox(height: 24),
                const SocialButtons(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
