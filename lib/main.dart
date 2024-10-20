import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/error.dart';
import 'package:laya/routes/routes.dart';
import 'package:laya/splash.dart';
import 'package:laya/theme/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashPage(),
      routes: routes,
    ),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: Provider.of<ThemeProvider>(context).themeData,
      title: 'LAYA',
    );
  }
}
