import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:laya/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to track if the user has completed onboarding
final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _redirectToNextPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redirectToNextPage() async {
    developer.log('Starting splash redirection flow', name: 'SplashScreen');

    // Start fade-in animation
    _controller.forward();

    // Set a timeout for the splash screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        _showError('Loading timeout. Please try again.');
      }
    });

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
      _showError('An error occurred. Please try again.');
      _navigateToAuth();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isUserProfileIncomplete(User user) {
    return user.firstName.isEmpty ||
        user.lastName.isEmpty ||
        user.username.isEmpty;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _redirectToNextPage();
            },
          ),
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
      context.go('/complete_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Stack(
        children: [
          // Logo with fade animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    developer.log(
                      'Error loading app logo: $error',
                      name: 'SplashScreen',
                      error: error,
                    );
                    return Icon(
                      Icons.book,
                      size: size.width * 0.4,
                      color: colorScheme.onPrimary,
                    );
                  },
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned(
              bottom: size.height * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

          // Error state
          if (_hasError)
            Positioned(
              bottom: size.height * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                        _redirectToNextPage();
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
