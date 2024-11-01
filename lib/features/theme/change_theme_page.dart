import 'package:flutter/material.dart';
import 'package:laya/features/theme/theme_option.dart';
import 'package:laya/features/theme/theme_preview.dart';
import 'package:laya/theme/theme.dart';
import 'package:laya/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ChangeThemePage extends StatefulWidget {
  const ChangeThemePage({super.key});

  @override
  State<ChangeThemePage> createState() => _ChangeThemePageState();
}

class _ChangeThemePageState extends State<ChangeThemePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              ThemeOption(
                title: 'Light',
                icon: Icons.light_mode_outlined,
                isSelected: themeProvider.themeData == AppTheme.lightMode,
                onTap: () => themeProvider.themeData = AppTheme.lightMode,
                colorScheme: Theme.of(context).colorScheme,
              ),
              SizedBox(height: screenHeight * 0.02),
              ThemeOption(
                title: 'Dark',
                icon: Icons.dark_mode_outlined,
                isSelected: themeProvider.themeData == AppTheme.darkMode,
                onTap: () => themeProvider.themeData = AppTheme.darkMode,
                colorScheme: Theme.of(context).colorScheme,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              ThemePreview(colorScheme: Theme.of(context).colorScheme),
            ],
          ),
        ),
      ),
    );
  }
}
