import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:laya/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'package:laya/providers/auth_provider.dart';

// Provider to track if the user has completed onboarding
final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirectToNextPage();
  }

  Future<void> _redirectToNextPage() async {
    developer.log('Starting splash redirection flow', name: 'SplashScreen');

    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      // Check if user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      // Update provider state
      ref.read(hasCompletedOnboardingProvider.notifier).state =
          hasCompletedOnboarding;

      // If user hasn't completed onboarding, send them there first
      if (!hasCompletedOnboarding) {
        developer.log(
          'User has not completed onboarding, redirecting to onboarding',
          name: 'SplashScreen',
        );
        _navigateToOnboarding();
        return;
      }

      // Get the auth service
      final authService = ref.read(authServiceProvider);

      // Get current Firebase user
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        developer.log(
          'No firebase user found, redirecting to authentication',
          name: 'SplashScreen',
        );
        _navigateToAuth();
        return;
      }

      developer.log(
        'Firebase user found: ${firebaseUser.uid}, checking user profile',
        name: 'SplashScreen',
      );

      // Get user data from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!docSnapshot.exists) {
        developer.log(
          'No user profile found, creating basic profile',
          name: 'SplashScreen',
        );

        // Create basic user in Firestore
        final now = DateTime.now();
        final newUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.email?.split('@').first ?? '',
          createdAt: now,
          updatedAt: now,
          lastLoginAt: now,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());

        if (_isUserProfileIncomplete(newUser)) {
          developer.log(
            'Basic profile created, redirecting to profile completion',
            name: 'SplashScreen',
          );
          _navigateToCompleteProfile();
          return;
        }
      } else {
        // User exists in Firestore, check if profile is complete
        final userData = docSnapshot.data() as Map<String, dynamic>;

        // Convert to User model (using a simplified approach)
        final user = User(
          id: userData['id'] ?? firebaseUser.uid,
          email: userData['email'] ?? firebaseUser.email ?? '',
          username: userData['username'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          avatarUrl: userData['avatarUrl'] ?? '',
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
          updatedAt: userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : DateTime.now(),
          lastLoginAt: userData['lastLoginAt'] != null
              ? DateTime.parse(userData['lastLoginAt'])
              : DateTime.now(),
        );

        if (_isUserProfileIncomplete(user)) {
          developer.log(
            'User profile incomplete, redirecting to profile completion',
            name: 'SplashScreen',
          );
          _navigateToCompleteProfile();
          return;
        }
      }

      // Update last login time
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      }).catchError((e) => developer.log('Failed to update last login: $e'));

      developer.log(
        'User profile complete, redirecting to home',
        name: 'SplashScreen',
      );
      _navigateToHome();
    } catch (error) {
      developer.log(
        'Error during splash redirection: ${error.toString()}',
        name: 'SplashScreen',
        error: error,
      );
      _showError();
      _navigateToAuth();
    }
  }

  bool _isUserProfileIncomplete(User user) {
    return user.firstName.isEmpty ||
        user.lastName.isEmpty ||
        user.username.isEmpty;
  }

  void _showError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text('Something went wrong. Please try again later.'),
        ),
      );
    }
  }

  void _navigateToOnboarding() {
    if (mounted) {
      context.go('/onboarding');
    }
  }

  void _navigateToAuth() {
    if (mounted) {
      context.go('/login');
    }
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  void _navigateToCompleteProfile() {
    if (mounted) {
      context.go('/complete-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: Image.asset('assets/images/app_logo.png'),
        ),
      ),
    );
  }
}
