import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/create_post.dart';
import 'package:laya/home.dart';
import 'package:laya/magic_link.dart';
import 'package:laya/profile/edit_profile.dart';
import 'package:laya/profile/profile.dart';
import 'package:laya/profile/profile_settings.dart';
import 'package:laya/sign_in.dart';
import 'package:laya/profile/update_password.dart';

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
  GoRoute(
    path: 'create_post',
    builder: (BuildContext context, GoRouterState state) => const CreatePost(),
  ),
  GoRoute(
    path: 'profile',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfilePage();
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
];
