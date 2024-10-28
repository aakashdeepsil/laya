import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/features/auth/data/user_repository.dart';

class CompleteUserProfilePage extends StatefulWidget {
  final User user;

  const CompleteUserProfilePage({super.key, required this.user});

  @override
  State<CompleteUserProfilePage> createState() =>
      _CompleteUserProfilePageState();
}

class _CompleteUserProfilePageState extends State<CompleteUserProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = true;
  String _avatarUrl = '';

  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  Future<void> _getProfile() async {
    setState(() => _loading = true);

    final userID = supabase.auth.currentUser?.id;

    if (userID == null) {
      context.go('/sign_in');
      return;
    }

    try {
      final data = await _userRepository.getUser(userID);
      if (data == null) {
        throw Exception('Failed to load user information');
      }

      setState(() {
        _avatarUrl = data['avatar_url'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _usernameController.text = data['username'] ?? '';
      });
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final userID = supabase.auth.currentUser?.id;
    if (userID == null) return;

    final updates = {
      'id': userID,
      'avatar_url': _avatarUrl,
      'bio': _bioController.text.trim(),
      'username': _usernameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
    };

    try {
      await _userRepository.updateUser(updates, userID);

      final userResponse = await _userRepository.getUser(userID);

      if (userResponse == null) {
        throw Exception('Failed to load user information');
      }

      final user = User.fromJson(userResponse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
        context.go('/home', extra: user);
      }
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
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

  final _debouncer = Debouncer(milliseconds: 500);
  bool _isCheckingUsername = false;
  String? _usernameError;

  Future<void> _checkUsername(String username) async {
    if (username.isEmpty) return;

    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      final isAvailable = await _userRepository.isUsernameAvailable(
          username, supabase.auth.currentUser?.id);

      if (mounted) {
        setState(() {
          _usernameError = isAvailable ? null : 'Username is already taken';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usernameError = 'Error checking username';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Complete Profile',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: screenHeight * 0.03),
            onPressed: _loading ? null : () => _updateProfile(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Build your profile and connect with others!',
                style: TextStyle(fontSize: screenHeight * 0.02),
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
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        errorText: _usernameError,
                        suffixIcon: _isCheckingUsername
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : _usernameError == null &&
                                    _usernameController.text.isNotEmpty
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
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
                    SizedBox(height: screenHeight * 0.02),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself...',
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
