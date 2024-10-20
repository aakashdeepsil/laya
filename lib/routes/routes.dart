import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/about_us.dart';
import 'package:laya/complete_profile.dart';
import 'package:laya/create_post.dart';
import 'package:laya/explore/search.dart';
import 'package:laya/home.dart';
import 'package:laya/landing.dart';
import 'package:laya/posts/post_detail.dart';
import 'package:laya/profile/edit_profile.dart';
import 'package:laya/profile/profile.dart';
import 'package:laya/profile/profile_settings.dart';
import 'package:laya/sign_in.dart';
import 'package:laya/profile/update_password.dart';
import 'package:laya/comments/add_comment_page.dart';
import 'package:laya/socials/socials_homepage.dart';

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
    path: 'complete_profile',
    builder: (BuildContext context, GoRouterState state) {
      return const CompleteProfile();
    },
  ),
  GoRoute(
    path: 'home',
    builder: (BuildContext context, GoRouterState state) {
      return const Home();
    },
  ),
  GoRoute(
    path: 'socials',
    builder: (BuildContext context, GoRouterState state) {
      return const Socials();
    },
  ),
  GoRoute(
    path: 'post_details/:postID',
    builder: (BuildContext context, GoRouterState state) {
      final extraData = state.extra as Map<String, dynamic>?;

      return PostDetail(
        postID: state.pathParameters['postID']!,
        avatarURL: extraData?['avatarUrl'],
        post: extraData?['postItem'],
        username: extraData?['username'],
      );
    },
  ),
  GoRoute(
    path: 'create_post',
    builder: (BuildContext context, GoRouterState state) => const CreatePost(),
  ),
  GoRoute(
      path: 'post_details/:postID/add_comment',
      builder: (BuildContext context, GoRouterState state) {
        return AddCommentPage(postId: state.pathParameters['postID']!);
      }),
  GoRoute(
    path: 'profile/:userID',
    builder: (BuildContext context, GoRouterState state) {
      return ProfilePage(userID: state.pathParameters['userID']!);
    },
  ),
  GoRoute(
    path: 'edit_profile',
    builder: (BuildContext context, GoRouterState state) {
      return const EditProfilePage();
    },
  ),
  GoRoute(
    path: 'profile_settings',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfileSettings();
    },
  ),
  GoRoute(
    path: 'update_password',
    builder: (BuildContext context, GoRouterState state) {
      return const UpdatePassword();
    },
  ),
  GoRoute(
    path: 'explore',
    builder: (BuildContext context, GoRouterState state) {
      return const Search();
    },
  ),
];
