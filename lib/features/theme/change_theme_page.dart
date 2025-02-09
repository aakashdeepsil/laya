import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/theme/theme_option.dart';
import 'package:laya/features/theme/theme_preview.dart';
import 'package:laya/theme/theme.dart';
import 'package:laya/theme/theme_provider.dart';

class ChangeThemePage extends ConsumerWidget {
  const ChangeThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: TextStyle(
            fontSize: screenSize.height * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: screenSize.height * 0.025,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              ThemeOption(
                title: 'Light',
                icon: Icons.light_mode_outlined,
                isSelected: currentTheme == AppTheme.lightMode,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setTheme(AppTheme.lightMode),
                colorScheme: Theme.of(context).colorScheme,
              ),
              SizedBox(height: screenSize.height * 0.02),
              ThemeOption(
                title: 'Dark',
                icon: Icons.dark_mode_outlined,
                isSelected: currentTheme == AppTheme.darkMode,
                onTap: () => ref
                    .read(themeProvider.notifier)
                    .setTheme(AppTheme.darkMode),
                colorScheme: Theme.of(context).colorScheme,
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: screenSize.height * 0.025,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              ThemePreview(colorScheme: Theme.of(context).colorScheme),
            ],
          ),
        ),
      ),
    );
  }
}
