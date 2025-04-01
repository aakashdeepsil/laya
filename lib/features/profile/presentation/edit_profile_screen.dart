import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/profile/presentation/components/custom_textfield.dart';
import 'package:laya/features/profile/presentation/components/save_button.dart';
import 'package:laya/features/profile/presentation/components/username_status_icon.dart';
import 'package:laya/shared/utils/debouncer.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/profile_provider.dart';
import 'package:laya/shared/widgets/profile/avatar_upload_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final _debouncer = Debouncer(milliseconds: 500);
  bool _isCheckingUsername = false;
  String? _usernameError;
  bool _hasUnsavedChanges = false;

  String? _originalUsername;

  @override
  void initState() {
    super.initState();
    developer.log('EditProfilePage initialized', name: 'EditProfilePage');
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get the current user from auth state
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull;

      if (user != null) {
        // Load initial values
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _usernameController.text = user.username;
        _originalUsername = user.username;

        // Add listeners to detect changes
        _addChangeListeners();

        developer.log(
          'User profile loaded: ${user.username}',
          name: 'EditProfilePage',
        );
      } else {
        developer.log('No user found in auth state', name: 'EditProfilePage');
        _showErrorSnackBar('Unable to load user profile');
        context.go('/login');
      }
    } catch (error) {
      developer.log(
        'Error loading profile: $error',
        name: 'EditProfilePage',
        error: error,
      );
      _showErrorSnackBar('Error loading profile: $error');
    }
  }

  void _addChangeListeners() {
    // Add listeners to track unsaved changes
    void checkChanges() {
      if (!mounted) return;

      final currentUser = ref.read(authStateProvider).valueOrNull;
      if (currentUser == null) return;

      final hasChanges = _firstNameController.text != currentUser.firstName ||
          _lastNameController.text != currentUser.lastName ||
          _usernameController.text != currentUser.username;

      if (hasChanges != _hasUnsavedChanges) {
        setState(() => _hasUnsavedChanges = hasChanges);
      }
    }

    _firstNameController.addListener(checkChanges);
    _lastNameController.addListener(checkChanges);
    _usernameController.addListener(checkChanges);
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;

      if (currentUser == null) {
        throw Exception('No user found');
      }

      final authService = ref.read(authServiceProvider);
      final updatedUser = currentUser.copyWith(avatarUrl: imageUrl);

      // Update profile using AuthService
      final result = await authService.updateUserProfile(updatedUser);

      if (result != null) {
        // Update profile provider with the new data
        ref.read(profileProvider.notifier).updateProfileData(result);

        developer.log('Avatar updated successfully', name: 'EditProfilePage');

        if (mounted) {
          _showSuccessSnackBar('Avatar updated successfully!');
        }
      } else {
        throw Exception('Failed to update avatar');
      }
    } catch (error) {
      developer.log(
        'Avatar update error: $error',
        name: 'EditProfilePage',
        error: error,
      );
      _showErrorSnackBar('Failed to update avatar: ${error.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;

      if (currentUser == null) {
        _showErrorSnackBar('No user profile found');
        return;
      }

      try {
        setState(() => _isCheckingUsername = true);

        final updatedUser = currentUser.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // Get the auth service and update profile
        final authService = ref.read(authServiceProvider);
        final result = await authService.updateUserProfile(updatedUser);

        if (result != null) {
          // Invalidate both providers to force a fresh fetch
          ref.invalidate(profileProvider);

          // Trigger a fresh fetch of profile data
          await ref.read(profileProvider.notifier).fetchProfile(result.id);

          setState(() {
            _hasUnsavedChanges = false;
            _originalUsername = result.username;
          });

          if (mounted) {
            _showSuccessSnackBar('Profile updated successfully!');
            context.pop();
          }
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (error) {
        developer.log(
          'Profile update error: $error',
          name: 'EditProfilePage',
          error: error,
        );
        _showErrorSnackBar(error.toString());
      } finally {
        setState(() => _isCheckingUsername = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _checkUsername(String username) async {
    if (username.isEmpty) return;

    // Skip check if the username hasn't changed from original
    if (username == _originalUsername) {
      setState(() => _usernameError = null);
      return;
    }

    if (username.length < 3) {
      setState(() => _usernameError = 'Username must be at least 3 characters');
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final isAvailable = await authService.checkUsernameAvailability(username);

      setState(() =>
          _usernameError = isAvailable ? null : 'Username is already taken');
    } catch (e) {
      developer.log('Username check error: $e',
          name: 'EditProfilePage', error: e);
      setState(() => _usernameError = 'Error checking username');
    } finally {
      setState(() => _isCheckingUsername = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('STAY'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state changes and profile state
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(profileProvider);

    final currentUser = authState.valueOrNull;
    final bool isLoading = authState.isLoading || profileState.isLoading;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading || currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: currentUser != null
                            ? AvatarUploadWidget(
                                currentAvatarUrl: currentUser.avatarUrl,
                                onUpload: _onUpload,
                                isLoading: isLoading,
                                user: currentUser,
                              )
                            : const SizedBox(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            textField(
                              context: context,
                              controller: _firstNameController,
                              label: 'First Name',
                              icon: LucideIcons.user,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            textField(
                              context: context,
                              controller: _lastNameController,
                              label: 'Last Name',
                              icon: LucideIcons.user,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            textField(
                              context: context,
                              controller: _usernameController,
                              label: 'Username',
                              icon: LucideIcons.atSign,
                              errorText: _usernameError,
                              suffixIcon: usernameStatusIcon(
                                context,
                                _isCheckingUsername,
                                _usernameError,
                                _usernameController,
                                _originalUsername,
                              ),
                              onChanged: (value) =>
                                  _debouncer.run(() => _checkUsername(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                if (_usernameError != null) {
                                  return _usernameError;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            saveButton(
                              context,
                              isLoading,
                              _hasUnsavedChanges,
                              _updateProfile,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
