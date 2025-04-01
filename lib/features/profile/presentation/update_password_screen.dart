import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Login state management
  bool _isLoading = false;
  String? _errorMessage;

  // Password visibility toggles
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Password strength tracking
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    developer.log(
      'UpdatePasswordScreen initialized',
      name: 'UpdatePasswordScreen',
    );

    // Listen to password changes to update strength indicator
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0;

    // Calculate password strength
    if (password.length >= 8) strength += 0.25;
    if (_hasUpperAndLowerCase(password)) strength += 0.25;
    if (_hasNumber(password)) strength += 0.25;
    if (_hasSpecialChar(password)) strength += 0.25;

    setState(() => _passwordStrength = strength);
  }

  Future<void> _updatePassword() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      developer.log(
        'Attempting to update password',
        name: 'UpdatePasswordScreen',
      );

      // Get the Firebase user
      final firebaseAuth = FirebaseAuth.instance;
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser == null) {
        throw Exception('You need to be logged in to update your password');
      }

      // First, re-authenticate the user with their current password
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: _currentPasswordController.text,
      );

      // Re-authenticate
      developer.log('Re-authenticating user', name: 'UpdatePasswordScreen');
      await firebaseUser.reauthenticateWithCredential(credential);

      // Update the password
      developer.log(
        'Updating password in Firebase',
        name: 'UpdatePasswordScreen',
      );
      await firebaseUser.updatePassword(_newPasswordController.text);

      if (!mounted) return;

      // Show success message
      _showSuccessMessage('Password updated successfully');

      // Close the page after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.pop();
        }
      });
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      setState(() {
        switch (e.code) {
          case 'wrong-password':
            _errorMessage = 'Current password is incorrect';
            break;
          case 'requires-recent-login':
            _errorMessage =
                'Please log out and log back in to update your password';
            break;
          default:
            _errorMessage = e.message ?? 'Failed to update password';
        }
      });
      developer.log(
        'Firebase Auth Error: ${e.code} - ${e.message}',
        name: 'UpdatePasswordScreen',
        error: e,
      );
    } catch (e) {
      // Handle other errors
      setState(() => _errorMessage = e.toString());
      developer.log(
        'Error updating password: $e',
        name: 'UpdatePasswordScreen',
        error: e,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                LucideIcons.check,
                size: 20,
                color: colorScheme.primary,
              ),
              onPressed: _updatePassword,
              tooltip: 'Update Password',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error message if present
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 20,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Current password field
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  showPassword: _showCurrentPassword,
                  toggleVisibility: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // New password field
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  showPassword: _showNewPassword,
                  toggleVisibility: () =>
                      setState(() => _showNewPassword = !_showNewPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!_hasUpperAndLowerCase(value)) {
                      return 'Include both uppercase and lowercase letters';
                    }
                    if (!_hasNumber(value)) {
                      return 'Include at least one number';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'New password must be different from current';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Password strength indicator
                _buildPasswordStrengthIndicator(colorScheme),

                const SizedBox(height: 20),

                // Confirm password field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  showPassword: _showConfirmPassword,
                  toggleVisibility: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Password requirements section
                Text(
                  'Password Requirements:',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Requirements list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirement(
                      'At least 8 characters',
                      _newPasswordController.text.length >= 8,
                      colorScheme,
                    ),
                    _buildRequirement(
                      'Uppercase and lowercase letters',
                      _hasUpperAndLowerCase(_newPasswordController.text),
                      colorScheme,
                    ),
                    _buildRequirement(
                      'At least one number',
                      _hasNumber(_newPasswordController.text),
                      colorScheme,
                    ),
                    _buildRequirement(
                      'At least one special character',
                      _hasSpecialChar(_newPasswordController.text),
                      colorScheme,
                    ),
                    _buildRequirement(
                      'Different from current password',
                      _newPasswordController.text.isNotEmpty &&
                          _currentPasswordController.text !=
                              _newPasswordController.text,
                      colorScheme,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Update button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      disabledBackgroundColor:
                          colorScheme.primary.withValues(alpha: 0.5),
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Updating...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(ColorScheme colorScheme) {
    Color indicatorColor;
    String strengthText;

    if (_passwordStrength < 0.25) {
      indicatorColor = Colors.red;
      strengthText = 'Weak';
    } else if (_passwordStrength < 0.5) {
      indicatorColor = Colors.orange;
      strengthText = 'Fair';
    } else if (_passwordStrength < 0.75) {
      indicatorColor = Colors.yellow.shade700;
      strengthText = 'Good';
    } else {
      indicatorColor = Colors.green;
      strengthText = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength:',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: indicatorColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: colorScheme.surfaceVariant,
            color: indicatorColor,
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required Function() toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !showPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              LucideIcons.lock,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: toggleVisibility,
            splashRadius: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceVariant
              .withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isMet
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                isMet ? LucideIcons.check : null,
                size: 12,
                color: isMet ? colorScheme.primary : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUpperAndLowerCase(String password) {
    return password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  bool _hasSpecialChar(String password) {
    return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
