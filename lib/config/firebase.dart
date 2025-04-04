import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:laya/firebase_options.dart';

Future<void> initializeFirebase() async {
  try {
    developer.log(
      'Initializing Firebase Core...',
      name: 'Firebase:Init',
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    developer.log(
      'Firebase Core initialized successfully',
      name: 'Firebase:Init',
    );

    // Configure Firebase Functions to use the emulator in debug mode
    if (kDebugMode) {
      developer.log(
        'Debug mode detected - configuring Firebase Functions for emulator',
        name: 'Firebase:Functions',
      );

      try {
        FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5001);

        developer.log(
          'Firebase Functions configured for emulator at 10.0.2.2:5001',
          name: 'Firebase:Functions',
        );
      } catch (e) {
        developer.log(
          '❌ Failed to connect to Firebase Functions emulator: $e',
          name: 'Firebase:Functions',
          error: e,
        );
      }
    } else {
      developer.log(
        'Production mode - using Firebase Functions production endpoint',
        name: 'Firebase:Functions',
      );
    }
  } catch (e) {
    developer.log(
      '❌ Firebase initialization failed: $e',
      name: 'Firebase:Init',
      error: e,
    );
    rethrow;
  }
}
