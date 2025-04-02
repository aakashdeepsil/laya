import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/about_us_screen.dart';
import 'package:laya/features/auth/presentation/complete_profile_screen.dart';
import 'package:laya/error.dart';
import 'package:laya/features/auth/presentation/login_screen.dart';
import 'package:laya/features/auth/presentation/signup_screen.dart';
import 'package:laya/features/content/presentation/chapter/create_chapter_screen.dart';
import 'package:laya/features/content/presentation/chapter/edit_chapter_screen.dart';
import 'package:laya/features/content/presentation/series/create_series_screen.dart';
import 'package:laya/features/content/presentation/series/edit_series_page.dart';
import 'package:laya/features/content/presentation/series/series_details_screen.dart';
import 'package:laya/features/home/presentation/home_screen.dart';
import 'package:laya/features/library/library_screen.dart';
import 'package:laya/features/profile/presentation/edit_profile_screen.dart';
import 'package:laya/features/profile/presentation/profile_settings_screen.dart';
import 'package:laya/features/profile/presentation/update_password_screen.dart';
import 'package:laya/features/reader/reader_screen.dart';
import 'package:laya/features/profile/presentation/profile_screen.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/onboarding_screen.dart';
import 'package:laya/splash_screen.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
      routes: routes,
    ),
  ],
);

List<RouteBase> routes = [
  GoRoute(
    path: 'about_us',
    builder: (BuildContext context, GoRouterState state) {
      return const AboutUsScreen();
    },
  ),
  GoRoute(
    path: 'onboarding',
    builder: (BuildContext context, GoRouterState state) {
      return OnboardingScreen();
    },
  ),
  GoRoute(
    path: 'login',
    builder: (BuildContext context, GoRouterState state) {
      return const LoginScreen();
    },
  ),
  GoRoute(
    path: 'signup',
    builder: (BuildContext context, GoRouterState state) {
      return const SignupScreen();
    },
  ),
  GoRoute(
    path: 'complete_profile',
    builder: (_, __) => const CompleteProfileScreen(),
  ),
  GoRoute(
    path: 'home',
    builder: (BuildContext context, GoRouterState state) {
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: 'profile',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfileScreen();
    },
  ),
  GoRoute(
    path: 'edit_profile',
    builder: (BuildContext context, GoRouterState state) {
      return const EditProfileScreen();
    },
  ),
  GoRoute(
    path: 'profile_settings',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfileSettingsScreen();
    },
  ),
  GoRoute(
    path: 'update_password',
    builder: (BuildContext context, GoRouterState state) {
      return const UpdatePasswordScreen();
    },
  ),
  GoRoute(
    path: 'reader',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final content = extras['content'] as Content;
      return ReaderScreen(content: content);
    },
  ),
  GoRoute(
    path: 'create_series',
    builder: (BuildContext context, GoRouterState state) {
      return const CreateSeriesScreen();
    },
  ),
  GoRoute(
    path: 'edit_series',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final series = extras['series'] as Series;
      return EditSeriesScreen(series: series);
    },
  ),
  GoRoute(
    path: 'series_details',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final series = extras['series'] as Series;
      return SeriesDetailsScreen(series: series);
    },
  ),
  GoRoute(
    path: 'library',
    builder: (BuildContext context, GoRouterState state) {
      return const LibraryScreen();
    },
  ),
  GoRoute(
    path: 'create_chapter',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras =
          state.extra as Map<String, dynamic>? ?? {};
      final series = extras['series'] as Series?;
      return CreateChapterScreen(series: series);
    },
  ),
  GoRoute(
    path: 'edit_chapter',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras =
          state.extra as Map<String, dynamic>? ?? {};
      final content = extras['content'] as Content;
      return EditChapterScreen(content: content);
    },
  ),
];
