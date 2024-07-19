import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/home.dart';
import 'package:laya/magic_link.dart';
import 'package:laya/sign_in.dart';
import 'package:laya/update_password.dart';

List<RouteBase> routes = [
  GoRoute(
    path: 'sign_in',
    builder: (BuildContext context, GoRouterState state) {
      return const SignUp();
    },
  ),
  GoRoute(
    path: 'update_password',
    builder: (BuildContext context, GoRouterState state) {
      return const UpdatePassword();
    },
  ),
  GoRoute(
    path: 'magic_link',
    builder: (BuildContext context, GoRouterState state) {
      return const MagicLink();
    },
  ),
  GoRoute(
    path: 'home',
    builder: (BuildContext context, GoRouterState state) {
      return const Home();
    },
  ),
  // GoRoute(
  //   path: 'socials',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const SocialsHomepage();
  //   },
  //   routes: <RouteBase>[
  //     GoRoute(
  //       path: 'post/:postId',
  //       builder: (BuildContext context, GoRouterState state) {
  //         final String? postId = state.pathParameters['postId'];
  //         return PostPage(postId: postId);
  //       },
  //     ),
  //     GoRoute(
  //       path: 'post/:postId/media/:mediaId',
  //       builder: (BuildContext context, GoRouterState state) {
  //         final String? postId = state.pathParameters['postId'];
  //         final String? mediaId = state.pathParameters['mediaId'];
  //         return PostMediaViewPage(postId: postId, mediaId: mediaId);
  //       },
  //     ),
  //     GoRoute(
  //       path: 'post/:postId/comments/add_comment',
  //       builder: (BuildContext context, GoRouterState state) {
  //         final String? postId = state.pathParameters['postId'];
  //         return AddCommentPage(postId: postId);
  //       },
  //     ),
  //   ],
  // ),
  // GoRoute(
  //   path: 'profile',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const ProfilePage();
  //   },
  //   routes: <RouteBase>[
  //     GoRoute(
  //       path: 'edit_profile',
  //       builder: (BuildContext context, GoRouterState state) {
  //         return const EditProfilePage();
  //       },
  //     ),
  //     GoRoute(
  //       path: 'settings',
  //       builder: (BuildContext context, GoRouterState state) {
  //         return const ProfileSettingsPage();
  //       },
  //     ),
  //     GoRoute(
  //       path: 'update_password',
  //       builder: (BuildContext context, GoRouterState state) {
  //         return const UpdatePassword();
  //       },
  //     ),
  //   ],
  // ),
];
