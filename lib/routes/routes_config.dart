import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/features/about/presentation/about_us_page.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/auth/presentation/complete_user_profile_page.dart';
import 'package:laya/error.dart';
import 'package:laya/features/auth/presentation/sign_in_page.dart';
import 'package:laya/features/auth/presentation/sign_up_page.dart';
import 'package:laya/features/content/presentation/chapter/create_chapter_page.dart';
import 'package:laya/features/content/presentation/chapter/content_viewer_page.dart';
import 'package:laya/features/content/presentation/series/create_series_page.dart';
import 'package:laya/features/content/presentation/series/edit_series_page.dart';
import 'package:laya/features/content/presentation/series/series_details_page.dart';
import 'package:laya/features/content/presentation/chapter/view_video_content_page.dart';
import 'package:laya/features/explore/presentation/explore_page.dart';
import 'package:laya/features/home/presentation/home_page.dart';
import 'package:laya/features/library/presentations/library_page.dart';
import 'package:laya/features/profile/presentation/update_password_page.dart';
import 'package:laya/features/theme/change_theme_page.dart';
import 'package:laya/features/profile/presentation/edit_profile.dart';
import 'package:laya/features/profile/presentation/user_profile_page.dart';
import 'package:laya/features/profile/presentation/user_profile_settings_page.dart';
import 'package:laya/landing.dart';
import 'package:laya/splash.dart';

final GoRouter router = GoRouter(
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

List<RouteBase> routes = [
  GoRoute(
    path: 'about_us',
    builder: (BuildContext context, GoRouterState state) {
      return const AboutUs();
    },
  ),
  GoRoute(
    path: 'landing',
    builder: (BuildContext context, GoRouterState state) {
      return const Landing();
    },
  ),
  GoRoute(
    path: 'sign_in',
    builder: (BuildContext context, GoRouterState state) {
      return const SignInPage();
    },
  ),
  GoRoute(
    path: 'sign_up',
    builder: (BuildContext context, GoRouterState state) {
      return const SignUpPage();
    },
  ),
  GoRoute(
    path: 'complete_user_profile_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return CompleteUserProfilePage(user: user);
    },
  ),
  GoRoute(
    path: 'home',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return HomePage(user: user);
    },
  ),
  GoRoute(
    path: 'explore',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return ExplorePage(user: user);
    },
  ),
  GoRoute(
    path: 'library',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return LibraryPage(user: user);
    },
  ),
  GoRoute(
    path: 'user_profile_page',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final user = extras['user'] as User;
      final currentUser = extras['currentUser'] as User;
      return UserProfilePage(user: user, currentUser: currentUser);
    },
  ),
  GoRoute(
    path: 'update_password_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return UpdatePasswordPage(user: user);
    },
  ),
  GoRoute(
    path: 'edit_user_profile_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return EditUserProfilePage(user: user);
    },
  ),
  GoRoute(
    path: 'user_profile_settings_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return UserProfileSettingsPage(user: user);
    },
  ),
  GoRoute(
    path: 'change_theme_page',
    builder: (BuildContext context, GoRouterState state) {
      return const ChangeThemePage();
    },
  ),
  GoRoute(
    path: 'create_series_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return CreateSeriesPage(user: user);
    },
  ),
  GoRoute(
    path: 'edit_series_page',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final series = extras['series'] as Series;
      final user = extras['user'] as User;
      return EditSeriesPage(series: series, user: user);
    },
  ),
  GoRoute(
    path: 'series_details_page',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final series = extras['series'] as Series;
      final user = extras['user'] as User;
      return SeriesDetailsPage(series: series, user: user);
    },
  ),
  GoRoute(
    path: 'create_chapter_page',
    builder: (BuildContext context, GoRouterState state) {
      final user = state.extra as User;
      return CreateChapterPage(user: user);
    },
  ),
  GoRoute(
    path: 'view_video_content_page',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final content = extras['content'] as dynamic;
      final user = extras['user'] as User;
      return ViewVideoContentPage(user: user, content: content);
    },
  ),
  GoRoute(
    path: 'content_details_page',
    builder: (BuildContext context, GoRouterState state) {
      final Map<String, dynamic> extras = state.extra as Map<String, dynamic>;
      final content = extras['content'] as Content;
      final user = extras['user'] as User;
      return ContentViewerPage(content: content, user: user);
    },
  ),
];
