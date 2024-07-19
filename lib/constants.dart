import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

AppBar appBar(String title, {bool automaticallyImplyLeading = false}) => AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
    );

const optionText = Text(
  'OR',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
);

const spacer = SizedBox(
  height: 12,
);

List<OAuthProvider> get socialProviders => [OAuthProvider.google];
