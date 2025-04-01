import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laya/shared/utils/debouncer.dart';
import 'package:laya/features/auth/presentation/components/image_source_option.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  bool _isLoading = false;
  bool _isCheckingUsername = false;
  String? _usernameError;
  File? _selectedImage;
  bool _isUploadingImage = false;
  String _avatarUrl = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    developer.log('CompleteProfileScreen initialized', name: 'ProfileScreen');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    developer.log('Loading user data from auth state', name: 'ProfileScreen');
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user != null && mounted) {
        developer.log('User data found: ${user.id}', name: 'ProfileScreen');
        setState(() {
          _currentUser = user;
          _usernameController.text = user.username;
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _avatarUrl = user.avatarUrl;
        });
        developer.log('User data loaded into form fields',
            name: 'ProfileScreen');
        developer.log(
          'Username: ${user.username}, First Name: ${user.firstName}, Last Name: ${user.lastName}',
          name: 'ProfileScreen',
        );
      } else {
        developer.log(
          'User data not found or widget unmounted',
          name: 'ProfileScreen',
        );
      }
    });
  }

  Future<void> _saveProfile() async {
    developer.log('Attempting to save profile', name: 'ProfileScreen');
    if (_formKey.currentState?.validate() ?? false) {
      developer.log('Form validation passed', name: 'ProfileScreen');
      setState(() {
        _isLoading = true;
      });

      try {
        developer.log('Getting auth service reference', name: 'ProfileScreen');
        final authService = ref.read(authServiceProvider);

        if (_currentUser != null) {
          developer.log(
            'Updating user profile for ${_currentUser!.id}',
            name: 'ProfileScreen',
          );
          final updatedUser = _currentUser!.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            username: _usernameController.text.trim(),
            avatarUrl: _avatarUrl,
            updatedAt: DateTime.now(),
          );

          developer.log(
            'Profile data: First Name: ${updatedUser.firstName}, Last Name: ${updatedUser.lastName}, Username: ${updatedUser.username}',
            name: 'ProfileScreen',
          );
          developer.log(
            'Calling updateUserProfile on auth service',
            name: 'ProfileScreen',
          );
          final result = await authService.updateUserProfile(updatedUser);

          if (result != null) {
            developer.log('Profile update successful', name: 'ProfileScreen');
          } else {
            developer.log(
              'Profile update returned null user',
              name: 'ProfileScreen',
            );
          }

          if (mounted) {
            developer.log('Showing success message', name: 'ProfileScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF6366f1),
                content: const Text(
                  'Profile updated successfully!',
                  style: TextStyle(fontSize: 16),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );

            developer.log('Navigating to home screen', name: 'ProfileScreen');
            context.go('/home');
          } else {
            developer.log(
              'Widget not mounted after profile update',
              name: 'ProfileScreen',
            );
          }
        } else {
          developer.log(
            'Cannot update profile: currentUser is null',
            name: 'ProfileScreen',
          );
        }
      } catch (e) {
        developer.log(
          'Error updating profile: $e',
          name: 'ProfileScreen',
          error: e,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text('Error updating profile: ${e.toString()}'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          developer.log('Loading state reset', name: 'ProfileScreen');
        }
      }
    } else {
      developer.log('Form validation failed', name: 'ProfileScreen');
    }
  }

  Future<void> _checkUsername(String username) async {
    developer.log('Checking username: $username', name: 'ProfileScreen');
    if (username.isEmpty) {
      developer.log('Username is empty, clearing error', name: 'ProfileScreen');
      setState(() {
        _usernameError = null;
        _isCheckingUsername = false;
      });
      return;
    }

    if (username.length < 3) {
      developer.log('Username too short: $username', name: 'ProfileScreen');
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });
    developer.log(
      'Started username availability check: $username',
      name: 'ProfileScreen',
    );

    try {
      developer.log(
        'Getting auth service for username check',
        name: 'ProfileScreen',
      );
      final authService = ref.read(authServiceProvider);
      developer.log(
        'Calling checkUsernameAvailability method',
        name: 'ProfileScreen',
      );
      final isAvailable = await authService.checkUsernameAvailability(username);
      developer.log(
        'Username availability result: $isAvailable',
        name: 'ProfileScreen',
      );

      if (mounted) {
        setState(() {
          _usernameError = isAvailable ? null : 'Username is already taken';
          _isCheckingUsername = false;
        });
        developer.log(
          'Updated UI with username check result: ${_usernameError ?? "available"}',
          name: 'ProfileScreen',
        );
      } else {
        developer.log(
          'Widget unmounted during username check',
          name: 'ProfileScreen',
        );
      }
    } catch (e) {
      developer.log(
        'Error checking username: $e',
        name: 'ProfileScreen',
        error: e,
      );
      if (mounted) {
        setState(() {
          _usernameError = 'Error checking username';
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    developer.log('Picking image from ${source.name}', name: 'ProfileScreen');
    try {
      final picker = ImagePicker();
      developer.log('Opening image picker', name: 'ProfileScreen');
      final pickedFile = await picker.pickImage(source: source, maxWidth: 800);

      if (pickedFile != null) {
        developer.log('Image picked: ${pickedFile.path}',
            name: 'ProfileScreen');
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploadingImage = true;
        });

        if (_currentUser == null) {
          developer.log(
            'Cannot upload image: currentUser is null',
            name: 'ProfileScreen',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not authenticated')),
            );
          }
          setState(() => _isUploadingImage = false);
          return;
        }

        final userId = _currentUser!.id;
        developer.log(
          'Uploading image for user: $userId',
          name: 'ProfileScreen',
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatars')
            .child('$userId.jpg');

        developer.log(
          'Starting file upload to Firebase Storage',
          name: 'ProfileScreen',
        );
        final uploadTask = storageRef.putFile(_selectedImage!);

        developer.log('Waiting for upload to complete', name: 'ProfileScreen');
        final snapshot = await uploadTask;
        developer.log(
          'Upload completed, getting download URL',
          name: 'ProfileScreen',
        );
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _avatarUrl = downloadUrl;
          _isUploadingImage = false;
        });
        developer.log(
          'Image uploaded successfully: $_avatarUrl',
          name: 'ProfileScreen',
        );
      } else {
        developer.log('No image selected', name: 'ProfileScreen');
      }
    } catch (e) {
      developer.log(
        'Error picking/uploading image: $e',
        name: 'ProfileScreen',
        error: e,
      );
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    developer.log(
      'Opening image source selection dialog',
      name: 'ProfileScreen',
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF18181b),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                imageSourceOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    developer.log(
                      'Camera option selected',
                      name: 'ProfileScreen',
                    );
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                imageSourceOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    developer.log(
                      'Gallery option selected',
                      name: 'ProfileScreen',
                    );
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    developer.log('Disposing CompleteProfileScreen', name: 'ProfileScreen');
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building CompleteProfileScreen UI', name: 'ProfileScreen');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF818cf8),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your details to complete your profile and customize your experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6b7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Profile Avatar Section
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27272a),
                                shape: BoxShape.circle,
                                image: _selectedImage != null
                                    ? DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : _avatarUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              _avatarUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : _avatarUrl.isEmpty && _selectedImage == null
                                      ? const Icon(
                                          Icons.person_outline,
                                          size: 50,
                                          color: Color(0xFF6b7280),
                                        )
                                      : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  _selectedImage != null ||
                                          _avatarUrl.isNotEmpty
                                      ? Icons.edit
                                      : Icons.add_a_photo,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Name
                          const Text(
                            'First Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your first name',
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Last Name
                          const Text(
                            'Last Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your last name',
                              hintStyle: const TextStyle(
                                color: Color(0xFF6b7280),
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Username
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Choose a unique username',
                              hintStyle: const TextStyle(
                                color: Color(0xFF6b7280),
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: _isCheckingUsername
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _usernameError == null &&
                                          _usernameController.text.isNotEmpty
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : null,
                              errorText: _usernameError,
                              errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onChanged: (value) {
                              _debouncer.run(() => _checkUsername(value));
                            },
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
                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading || _isUploadingImage
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                disabledForegroundColor:
                                    Colors.white.withValues(alpha: 0.5),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _isLoading || _isUploadingImage
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Complete Profile',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
