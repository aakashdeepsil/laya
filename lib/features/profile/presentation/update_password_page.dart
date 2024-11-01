import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart' as user_model;
import 'package:laya/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordPage extends StatefulWidget {
  final user_model.User user;

  const UpdatePasswordPage({super.key, required this.user});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await supabase.auth.updateUser(UserAttributes(
        password: _newPasswordController.text,
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            'Password updated successfully',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: screenHeight * 0.02,
            ),
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            "Failed to update password. Please try again.",
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Password',
          style: TextStyle(
            fontSize: screenHeight * 0.0225,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: SizedBox(
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.03,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.check, size: screenHeight * 0.03),
              onPressed: _updatePassword,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: screenHeight * 0.03,
                      ),
                      onPressed: () => setState(
                          () => _showCurrentPassword = !_showCurrentPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: screenHeight * 0.03,
                      ),
                      onPressed: () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!_hasUpperAndLowerCase(value)) {
                      return 'Password must contain both uppercase and lowercase letters';
                    }
                    if (!_hasNumber(value)) {
                      return 'Password must contain at least one number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: screenHeight * 0.03,
                      ),
                      onPressed: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
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
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Password Requirements:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                _buildRequirement(
                  'At least 8 characters long',
                  _newPasswordController.text.length >= 8,
                  Theme.of(context).colorScheme,
                ),
                _buildRequirement(
                  'Contains both uppercase and lowercase letters',
                  _hasUpperAndLowerCase(_newPasswordController.text),
                  Theme.of(context).colorScheme,
                ),
                _buildRequirement(
                  'Contains at least one number',
                  _hasNumber(_newPasswordController.text),
                  Theme.of(context).colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: screenHeight * 0.02,
            color: isMet ? colorScheme.primary : colorScheme.outline,
          ),
          SizedBox(width: screenHeight * 0.01),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? colorScheme.onSurface : colorScheme.outline,
                fontSize: screenHeight * 0.015,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUpperAndLowerCase(String password) =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]'));

  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
