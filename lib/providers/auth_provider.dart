// Provider file for authentication related services and state

import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/services/auth_service.dart';

// Provides a single instance of AuthService throughout the app
final authServiceProvider = Provider<AuthService>((ref) {
  developer.log('Initializing AuthService provider', name: 'AuthProvider');
  return AuthService();
});

// Streams the current user authentication state (logged in or not)
final authStateProvider = StreamProvider<User?>((ref) {
  developer.log('Setting up auth state stream', name: 'AuthProvider');
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges.map((user) {
    developer.log(
      'Auth state changed: User ${user != null ? 'logged in' : 'logged out'}',
      name: 'AuthProvider',
    );
    return user;
  });
});
