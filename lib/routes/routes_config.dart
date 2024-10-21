import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/about/presentation/about_us_page.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/features/auth/presentation/complete_profile_page.dart';
import 'package:laya/error.dart';
import 'package:laya/features/auth/presentation/sign_in_page.dart';
import 'package:laya/features/auth/presentation/sign_up_page.dart';
import 'package:laya/features/home/presentation/home_page.dart';
import 'package:laya/features/profile/presentation/edit_profile.dart';
import 'package:laya/features/profile/presentation/profile_page.dart';
import 'package:laya/features/profile/presentation/profile_settings_page.dart';
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
  // GoRoute(
  //   path: 'update_password',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const UpdatePassword();
  //   },
  // ),
  GoRoute(
    path: 'complete_profile',
    builder: (BuildContext context, GoRouterState state) {
      final profile = state.extra as Profile;
      return CompleteProfilePage(profile: profile);
    },
  ),
  GoRoute(
    path: 'home',
    builder: (BuildContext context, GoRouterState state) {
      final profile = state.extra as Profile;
      return HomePage(profile: profile);
    },
  ),
  // GoRoute(
  //   path: 'socials',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const Socials();
  //   },
  // ),
  // GoRoute(
  //   path: 'post_details/:postID',
  //   builder: (BuildContext context, GoRouterState state) {
  //     final extraData = state.extra as Map<String, dynamic>?;

  //     return PostDetail(
  //       postID: state.pathParameters['postID']!,
  //       avatarURL: extraData?['avatarUrl'],
  //       post: extraData?['postItem'],
  //       username: extraData?['username'],
  //     );
  //   },
  // ),
  // GoRoute(
  //   path: 'create_post',
  //   builder: (BuildContext context, GoRouterState state) => const CreatePost(),
  // ),
  // GoRoute(
  //   path: 'post_details/:postID/add_comment',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return AddCommentPage(postId: state.pathParameters['postID']!);
  //   },
  // ),
  GoRoute(
    path: 'profile_page',
    builder: (BuildContext context, GoRouterState state) {
      final profile = state.extra as Profile;
      return ProfilePage(profile: profile);
    },
  ),
  GoRoute(
    path: 'edit_profile',
    builder: (BuildContext context, GoRouterState state) {
      final profile = state.extra as Profile;
      return  EditProfilePage(profile: profile);
    },
  ),
  GoRoute(
    path: 'profile_settings_page',
    builder: (BuildContext context, GoRouterState state) {
      final profile = state.extra as Profile;
      return ProfileSettingsPage(profile: profile);
    },
  ),
  // GoRoute(
  //   path: 'update_password',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const UpdatePassword();
  //   },
  // ),
  // GoRoute(
  //   path: 'explore',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const Search();
  //   },
  // ),
];
