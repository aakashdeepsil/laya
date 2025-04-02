import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/config/firebase.dart';
import 'package:laya/routes/routes_config.dart';
import 'package:laya/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  developer.log(
    'Flutter binding initialized',
    name: 'App:Startup',
  );

  developer.log(
    'Initializing Firebase...',
    name: 'App:Startup',
  );

  await initializeFirebase();

  developer.log(
    'Firebase initialized successfully',
    name: 'App:Startup',
  );

  developer.log(
    'Starting app with Riverpod',
    name: 'App:Startup',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log(
      'Building MyApp with router configuration',
      name: 'App:Initialize',
    );

    final theme = ref.watch(themeProvider);

    developer.log(
      'Theme loaded: ${theme.isDarkMode ? 'dark' : 'light'} mode',
      name: 'App:Theme',
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme.theme,
      title: 'LAYA',
      onGenerateTitle: (context) {
        developer.log(
          'App title generated',
          name: 'App:Initialize',
        );

        return 'LAYA';
      },
    );
  }
}
