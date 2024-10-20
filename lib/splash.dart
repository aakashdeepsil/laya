import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/features/auth/data/profile_service.dart';
import 'package:laya/config/schema/profiles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _redirectToNextPage();
  }

  Future<void> _redirectToNextPage() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        _navigateTo('/landing');
        return;
      }

      final profileResponse = await _profileService.getProfile(session.user.id);

      if (profileResponse == null) {
        _showError('Profile not found');
        _navigateTo('/landing');
        return;
      }

      final profile = Profile.fromMap(profileResponse);

      if (_isProfileIncomplete(profile)) {
        _navigateTo('/complete_profile', extra: profile);
        return;
      }

      _navigateTo('/home', extra: profile);
    } catch (error) {
      _showError(error.toString());
      _navigateTo('/landing');
    }
  }

  bool _isProfileIncomplete(Profile profile) {
    return profile.firstName.isEmpty ||
        profile.lastName.isEmpty ||
        profile.avatarUrl.isEmpty ||
        profile.bio.isEmpty ||
        profile.username.isEmpty;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

  void _navigateTo(String route, {Object? extra}) {
    if (mounted) {
      context.go(route, extra: extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
