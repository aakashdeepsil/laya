import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/auth/presentation/login_screen.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/services/auth_validator.dart';

/// Email input field with validation using Riverpod for state management
class EmailInput extends ConsumerStatefulWidget {
  const EmailInput({super.key});

  @override
  EmailInputState createState() => EmailInputState();
}

class EmailInputState extends ConsumerState<EmailInput> {
  /// Controller for the email text field
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get current form state and authenticated email
    final formState = ref.read(loginFormProvider);
    final authState = ref.read(authStateProvider);

    // Extract email from authenticated user if available
    final String authEmail = authState.when(
      data: (User? user) => user?.email ?? '',
      loading: () => '',
      error: (_, __) => '',
    );

    // Use form email if available, otherwise use authenticated email
    final initialEmail =
        formState.email.isNotEmpty ? formState.email : authEmail;

    // Update controller if value changed
    if (_controller.text != initialEmail) {
      _controller.text = initialEmail;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Check if email is valid
  String? _validateEmail(String email) {
    return AuthValidator.validateEmail(email);
  }

  /// Update form state when email changes
  void _handleEmailChange(String value) {
    final error = _validateEmail(value);

    ref.read(loginFormProvider.notifier).update((state) {
      if (error != null) {
        return state.copyWith(email: value, emailError: error);
      } else {
        return state.copyWith(email: value, clearEmailError: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);

    return TextField(
      controller: _controller,
      onChanged: _handleEmailChange,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: formState.emailError,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }
}
