import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/features/auth/data/profile_service.dart';

class CompleteProfilePage extends StatefulWidget {
  final Profile profile;

  const CompleteProfilePage({super.key, required this.profile});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = true;
  String _avatarUrl = '';

  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  late final ProfileService _profileService;

  Future<void> _getProfile() async {
    setState(() => _loading = true);

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      context.go('/sign_in');
      return;
    }

    try {
      final data = await _profileService.getProfile(userId);
      if (data != null) {
        setState(() {
          _avatarUrl = data['avatar_url'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _usernameController.text = data['username'] ?? '';
        });
      }
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updates = {
      'id': userId,
      'avatar_url': _avatarUrl,
      'bio': _bioController.text.trim(),
      'username': _usernameController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _profileService.updateProfile(updates, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.go('/home');
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
        content: Text(
          message,
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print(widget.profile.lastName);
    _profileService = ProfileService();
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.075),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
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
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your last name' : null,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your username' : null,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself...',
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
