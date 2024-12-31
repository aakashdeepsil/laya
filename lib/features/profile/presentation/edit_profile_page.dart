import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/profile/data/user_repository.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/config/schema/user.dart' as user_model;
import 'package:laya/shared/widgets/user_profile/avatar_upload_widget.dart';

class EditUserProfilePage extends StatefulWidget {
  final user_model.User user;

  const EditUserProfilePage({super.key, required this.user});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  final _debouncer = Debouncer(milliseconds: 500);
  bool _isCheckingUsername = false;
  String? _usernameError;

  bool _loading = true;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      setState(() => _loading = true);

      setState(() {
        _avatarUrl = widget.user.avatarUrl;
        _bioController.text = widget.user.bio;
        _firstNameController.text = widget.user.firstName;
        _lastNameController.text = widget.user.lastName;
        _usernameController.text = widget.user.username;
      });
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      setState(() => _loading = true);

      final updatedProfile = widget.user.copyWith(avatarUrl: imageUrl).toJson();

      await _userRepository.updateUser(updatedProfile, widget.user.id);

      setState(() => _avatarUrl = imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Avatar updated successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (error) {
      _showErrorSnackBar('Failed to update avatar: ${error.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = user_model.User(
        id: widget.user.id,
        avatarUrl: _avatarUrl,
        bio: _bioController.text.trim(),
        createdAt: widget.user.createdAt,
        email: widget.user.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        updatedAt: DateTime.now(),
        username: _usernameController.text.trim(),
      ).toJson();

      try {
        setState(() => _loading = true);

        final userID = widget.user.id;

        await _userRepository.updateUser(updatedProfile, userID);

        final updatedUserProfile = await _userRepository.getUser(userID);

        if (updatedUserProfile == null) {
          throw Exception('Failed to load user information');
        }

        final user = user_model.User.fromJson(updatedUserProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User profile updated successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          context.go('/user_profile_page', extra: user);
        }
      } catch (error) {
        _showErrorSnackBar(error.toString());
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
      ),
    );
  }

  Future<void> _checkUsername(String username) async {
    if (username.isEmpty) return;

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final isAvailable = await _userRepository.isUsernameAvailable(
        username,
        widget.user.id,
      );

      setState(() =>
          _usernameError = isAvailable ? null : 'Username is already taken');
    } catch (e) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: screenHeight * 0.03),
            onPressed: _loading ? null : _updateProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.075),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              AvatarUploadWidget(
                currentAvatarUrl: widget.user.avatarUrl,
                onUpload: _onUpload,
                isLoading: _loading,
                userID: widget.user.id,
              ),
              SizedBox(height: screenHeight * 0.025),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        errorText: _usernameError,
                        suffixIcon: _isCheckingUsername
                            ? SizedBox(
                                width: screenWidth * 0.05,
                                height: screenHeight * 0.05,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _usernameError == null &&
                                    _usernameController.text.isNotEmpty
                                ? Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: screenHeight * 0.025,
                                  )
                                : null,
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
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 3,
        user: widget.user,
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
