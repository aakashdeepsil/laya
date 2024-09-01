import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/components/profile_avatar.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Get the screen width and height
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Variable to store the loading state
  bool _loading = true;

  // Variables to store the user's avatar URL
  String _avatarUrl = '';

  // Variables to store the user's bio, first name, last name, and username
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Function to show error snackbar
  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(fontSize: screenHeight * 0.015),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // Function to get the user's profile
  Future<void> _getProfile() async {
    try {
      setState(() => _loading = true);

      final userId = Supabase.instance.client.auth.currentSession!.user.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _avatarUrl = data['avatar_url'];
      _bioController.text = data['bio'];
      _firstNameController.text = data['first_name'];
      _lastNameController.text = data['last_name'];
      _usernameController.text = data['username'];
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // Called when user taps `Update` button
  Future<void> _updateProfile() async {
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
      setState(() => _loading = true);

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        context.go('/profile/${Supabase.instance.client.auth.currentUser?.id}');
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': imageUrl}).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Avatar uploaded successfully!',
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      setState(() => _avatarUrl = imageUrl);
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    }
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.05),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200] ?? Colors.white),
            ),
          ),
          child: AppBar(
            title: Text(
              "Edit Profile",
              style: TextStyle(fontSize: screenHeight * 0.025),
            ),
            centerTitle: false,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.check, size: screenHeight * 0.03),
                onPressed: _loading ? null : _updateProfile,
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter your last name...',
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Choose a username...',
                              ),
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
      bottomNavigationBar: const MyBottomNavigationBar(index: 4),
    );
  }
}
