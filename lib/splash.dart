import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/profile/data/user_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final UserRepository _userRepository = UserRepository();

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

      final userResponse = await _userRepository.getUser(session.user.id);

      if (userResponse == null) {
        _showError('User profile not found');
        _navigateTo('/landing');
        return;
      }

      final user = User.fromJson(userResponse);

      if (_isUserProfileIncomplete(user)) {
        _navigateTo('/complete_user_profile_page', extra: user);
        return;
      }

      _navigateTo('/home', extra: user);
    } catch (error) {
      _showError(error.toString());
      _navigateTo('/landing');
    }
  }

  bool _isUserProfileIncomplete(User user) {
    return user.firstName.isEmpty ||
        user.lastName.isEmpty ||
        user.bio.isEmpty ||
        user.username.isEmpty;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          'Something went wrong. Please try again later.',
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
      ),
    );
  }

  void _navigateTo(String route, {Object? extra}) {
    if (mounted) {
      context.go(route, extra: extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
