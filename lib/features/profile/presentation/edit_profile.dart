import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/features/auth/data/profile_service.dart';
import 'package:laya/features/profile/presentation/profile_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = true;
  String _avatarUrl = '';

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    try {
      setState(() => _loading = true);

      setState(() {
        _avatarUrl = widget.profile.avatarUrl;
        _bioController.text = widget.profile.bio;
        _firstNameController.text = widget.profile.firstName;
        _lastNameController.text = widget.profile.lastName;
        _usernameController.text = widget.profile.username;
      });
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = Profile(
        id: widget.profile.id,
        avatarUrl: _avatarUrl,
        bio: _bioController.text.trim(),
        createdAt: widget.profile.createdAt,
        email: widget.profile.email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        updatedAt: DateTime.now(),
        username: _usernameController.text.trim(),
      ).toMap();

      try {
        setState(() => _loading = true);

        final userID = widget.profile.id;

        await _profileService.updateProfile(updatedProfile, userID);

        final newProfile = await _profileService.getProfile(userID);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          context.go('/profile_page', extra: Profile.fromMap(newProfile!));
        }
      } catch (error) {
        _showErrorSnackBar(error.toString());
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'avatar_url': imageUrl}).eq('id', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Avatar uploaded successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        setState(() => _avatarUrl = imageUrl);
      }
    } catch (error) {
      _showErrorSnackBar(error.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
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
        title: const Text("Edit Profile"),
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
              ProfileAvatar(imageUrl: _avatarUrl, onUpload: _onUpload),
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
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 4,
        profile: widget.profile,
      ),
    );
  }
}
