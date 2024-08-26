import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatefulWidget {
  final GoException? error;
  const ErrorScreen({super.key, this.error});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Page Not Found',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/'),
          child: Text('Home', style: TextStyle(fontSize: screenHeight * 0.025)),
        ),
      ),
    );
  }
}
