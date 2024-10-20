import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/profile_avatar.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = true;

  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  String _avatarUrl = '';

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _getProfile() async {
    setState(() => _loading = true);

    if (Supabase.instance.client.auth.currentUser != null) {
      String userId = Supabase.instance.client.auth.currentSession!.user.id;

      try {
        var data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        _avatarUrl = (data['avatar_url'] ?? '') as String;
        _bioController.text = (data['bio'] ?? '') as String;
        _firstNameController.text = (data['first_name'] ?? '') as String;
        _lastNameController.text = (data['last_name'] ?? '') as String;
        _usernameController.text = (data['username'] ?? '') as String;
      } on PostgrestException catch (error) {
        _showErrorSnackBar(error.message);
      } catch (error) {
        _showErrorSnackBar(error.toString());
      } finally {
        setState(() => _loading = false);
      }
    } else {
      context.go('/sign_in');
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);

    final userName = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final bio = _bioController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final updates = {
      'id': userId,
      'avatar_url': _avatarUrl,
      'bio': bio,
      'username': userName,
      'first_name': firstName,
      'last_name': lastName,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );

        context.go('/home');
      }
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': imageUrl}).eq('id', userId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
          ),
        );
      }
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    }

    setState(() => _avatarUrl = imageUrl);
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Complete Profile',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: screenHeight * 0.03),
            onPressed: _loading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Build your profile and connect with others!',
                      style: TextStyle(fontSize: screenHeight * 0.02),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ProfileAvatar(imageUrl: _avatarUrl, onUpload: _onUpload),
                    SizedBox(height: screenHeight * 0.025),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.075,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                hintText: 'Enter your first name...',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter your last name...',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Choose a username...',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
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
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
