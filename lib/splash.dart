import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:laya/config/schema/user/user.dart';
import 'package:laya/features/profile/data/user_repository.dart';

// 1. Create User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// 2. Create Auth State Provider
final authStateProvider = StreamProvider<auth.User?>((ref) {
  return auth.FirebaseAuth.instance.authStateChanges();
});

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
    _redirectToNextPage();
  }

  Future<void> _redirectToNextPage() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 3. Get current user from Firebase
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    
    if (firebaseUser == null) {
      _navigateTo('/onboarding');
      return;
    }

    try {
      // 4. Access repository through Riverpod
      final userRepo = ref.read(userRepositoryProvider);
      final userData = await userRepo.getUser(firebaseUser.uid);

      if (userData == null) {
        _showError('User profile not found');
        _navigateTo('/onboarding');
        return;
      }

      final currentUser = User.fromJson(userData);

      if (_isUserProfileIncomplete(currentUser)) {
        _navigateTo('/complete_user_profile_page', extra: currentUser);
        return;
      }

      _navigateTo('/home', extra: currentUser);
    } catch (error) {
      _showError(error.toString());
      _navigateTo('/onboarding');
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
        content: const Text('Something went wrong. Please try again later.'),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/images/app_logo.png'),
          ),
        ),
      ),
    );
  }
}
