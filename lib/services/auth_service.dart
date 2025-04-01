import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laya/models/user_model.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Service that handles user authentication and profile management
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  // Firestore database instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to users collection in Firestore
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Get document reference for a specific user
  DocumentReference _userDoc(String uid) => _usersCollection.doc(uid);

  /// Stream that emits the current authenticated user with Firestore data
  Stream<User?> get authStateChanges {
    developer.log('AuthService: Listening to auth state changes');
    return _auth
        .authStateChanges()
        .asyncMap((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        developer.log('AuthService: Auth state change - User signed out');
        return null; // Not signed in
      }

      developer.log(
        'AuthService: Auth state change - User ${firebaseUser.uid} signed in',
      );
      try {
        // Fetch user's profile data from Firestore
        developer.log(
          'AuthService: Fetching Firestore data for user ${firebaseUser.uid}',
        );
        final docSnapshot = await _userDoc(firebaseUser.uid).get();
        final userData = docSnapshot.exists
            ? docSnapshot.data() as Map<String, dynamic>
            : null;

        developer.log(
          'AuthService: Firestore data ${userData != null ? "found" : "not found"} for user ${firebaseUser.uid}',
        );
        return User.fromFirebase(firebaseUser, userData: userData);
      } catch (e) {
        developer.log('AuthService: Error getting user data: $e');
        // Return basic user without Firestore data
        return User.fromFirebase(firebaseUser);
      }
    });
  }

  /// Signs in a user with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    developer.log(
      'AuthService: Attempting to sign in user with email: ${email.split('@')[0]}@***',
    );
    try {
      final firebase_auth.UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser == null) {
        developer.log('AuthService: Sign-in failed - No user returned');
        return null;
      }

      developer
          .log('AuthService: Sign-in successful for user ${firebaseUser.uid}');

      // Track last login time
      developer.log(
        'AuthService: Updating last login timestamp for user ${firebaseUser.uid}',
      );
      await _userDoc(firebaseUser.uid).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      }).catchError(
          (e) => developer.log('AuthService: Failed to update last login: $e'));

      // Get complete user profile
      developer.log(
          'AuthService: Fetching complete user profile for ${firebaseUser.uid}');
      final docSnapshot = await _userDoc(firebaseUser.uid).get();
      final userData = docSnapshot.exists
          ? docSnapshot.data() as Map<String, dynamic>
          : null;

      developer.log(
        'AuthService: User profile ${userData != null ? "retrieved" : "not found"}',
      );
      return User.fromFirebase(firebaseUser, userData: userData);
    } catch (e) {
      developer.log('AuthService: Sign-in error: $e');
      return null;
    }
  }

  /// Creates a new user account with email, password and username
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    developer.log(
      'AuthService: Attempting to register new user with email: ${email.split('@')[0]}@***',
    );
    try {
      // Create auth account
      developer.log('AuthService: Creating Firebase authentication account');
      final firebase_auth.UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser == null) {
        developer.log('AuthService: Registration failed - No user returned');
        return null;
      }

      developer.log(
        'AuthService: Firebase account created successfully with ID: ${firebaseUser.uid}',
      );

      // Create user profile data
      final now = DateTime.now();
      final user = User(
        id: firebaseUser.uid,
        email: email,
        username: username,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      // Save to Firestore
      developer.log(
        'AuthService: Creating user profile in Firestore for ${firebaseUser.uid}',
      );
      await _userDoc(firebaseUser.uid).set(user.toJson());
      developer.log(
        'AuthService: User profile created successfully in Firestore',
      );

      return user;
    } catch (e) {
      developer.log('AuthService: Registration error: $e');
      return null;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    developer.log('AuthService: Signing out user');
    try {
      await _auth.signOut();
      developer.log('AuthService: User signed out successfully');
    } catch (e) {
      developer.log('AuthService: Sign out error: $e');
    }
  }

  /// Updates user profile information
  Future<User?> updateUserProfile(User user) async {
    developer.log('AuthService: Updating profile for user ${user.id}');
    try {
      // Update profile fields in Firestore
      developer.log('AuthService: Saving updated profile data to Firestore');
      await _userDoc(user.id).update({
        'username': user.username,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'avatarUrl': user.avatarUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      developer.log(
        'AuthService: Profile updated successfully for user ${user.id}',
      );
      return user.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      developer.log('AuthService: Update profile error: $e');
      return null;
    }
  }

  /// Checks if a username is available for use
  /// Returns true if username is available, false if already taken
  Future<bool> checkUsernameAvailability(String username) async {
    developer.log('AuthService: Checking availability of username: $username');

    if (username.isEmpty) {
      developer.log(
        'AuthService: Empty username provided, considering available',
      );
      return true;
    }

    try {
      // Get current user ID (if user is logged in)
      final currentUser = _auth.currentUser;
      final currentUserId = currentUser?.uid;

      // Query Firestore to find if username exists
      developer.log('AuthService: Querying Firestore for username');
      final querySnapshot = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // If no documents found, username is available
      if (querySnapshot.docs.isEmpty) {
        developer.log('AuthService: Username is available');
        return true;
      }

      // If the username belongs to the current user, it's available for them
      if (currentUserId != null &&
          querySnapshot.docs.first.id == currentUserId) {
        developer.log('AuthService: Username belongs to current user');
        return true;
      }

      // Username exists and belongs to another user
      developer.log('AuthService: Username is already taken');
      return false;
    } catch (e) {
      developer.log('AuthService: Error checking username: $e');
      return false;
    }
  }

  /// Fetches a user profile by their ID
  /// Returns the User object if found, null otherwise
  Future<User?> getUserById(String userId) async {
    developer.log('AuthService: Fetching user profile for ID: $userId');

    try {
      // Fetch user document from Firestore
      developer.log('AuthService: Querying Firestore for user document');
      final docSnapshot = await _userDoc(userId).get();

      if (!docSnapshot.exists) {
        developer.log('AuthService: No user found with ID: $userId');
        return null;
      }

      // Get user data
      final userData = docSnapshot.data() as Map<String, dynamic>;
      developer.log('AuthService: User profile retrieved for ID: $userId');

      // Check if this user also exists in Firebase Auth
      firebase_auth.User? firebaseUser;
      try {
        // Try to get the Firebase Auth user list - only available to admin SDK
        // This is a fallback and might not work in client apps
        final List<firebase_auth.UserInfo> providerData =
            _auth.currentUser?.providerData ?? [];

        // Check if we have provider data matching this user ID
        for (final userInfo in providerData) {
          if (userInfo.uid == userId) {
            firebaseUser = _auth.currentUser;
            break;
          }
        }
      } catch (e) {
        developer.log('AuthService: Unable to verify Firebase Auth user: $e');
        // Continue without Firebase Auth data
      }

      // Return user from Firestore data, with optional Firebase Auth data
      if (firebaseUser != null) {
        return User.fromFirebase(firebaseUser, userData: userData);
      }

      // Create user directly from Firestore data
      return User.fromFirebase(userData);
    } catch (e) {
      developer.log('AuthService: Error fetching user by ID: $e', error: e);
      return null;
    }
  }

  /// Signs in a user with Google
  Future<User?> signInWithGoogle() async {
    developer.log('AuthService: Attempting Google sign in');
    try {
      // Create a GoogleAuthProvider credential
      final googleProvider = firebase_auth.GoogleAuthProvider();

      // Get the auth instance
      final firebase_auth.UserCredential userCredential;

      if (kIsWeb) {
        // Use popup for web platform
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Use Google Sign In plugin for mobile platforms
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'profile',
          ],
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          developer.log('AuthService: User cancelled Google sign in');
          return null;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        userCredential = await _auth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        developer.log('AuthService: Google sign-in failed - No user returned');
        return null;
      }

      developer.log(
        'AuthService: Google sign-in successful for user ${firebaseUser.uid}',
      );

      // Check if user exists in Firestore
      final docSnapshot = await _userDoc(firebaseUser.uid).get();

      if (!docSnapshot.exists) {
        // Create new user profile
        developer.log(
          'AuthService: Creating new user profile for Google user ${firebaseUser.uid}',
        );

        final now = DateTime.now();
        final user = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: firebaseUser.email?.split('@')[0] ??
              '', // Default username from email
          firstName: firebaseUser.displayName?.split(' ').first ?? '',
          lastName: firebaseUser.displayName?.split(' ').last ?? '',
          avatarUrl: firebaseUser.photoURL ?? '',
          createdAt: now,
          updatedAt: now,
          lastLoginAt: now,
        );

        // Save to Firestore
        await _userDoc(firebaseUser.uid).set(user.toJson());
        developer.log('AuthService: User profile created successfully');
        return user;
      } else {
        // Update last login for existing user
        await _userDoc(firebaseUser.uid).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        // Return existing user with updated Firebase data
        final userData = docSnapshot.data() as Map<String, dynamic>;
        return User.fromFirebase(firebaseUser, userData: userData);
      }
    } catch (e) {
      developer.log('AuthService: Google sign-in error: $e');
      return null;
    }
  }
}
