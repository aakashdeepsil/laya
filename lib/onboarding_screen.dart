import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/onboarding_model.dart';
import 'package:laya/shared/widgets/onboarding_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State provider for current page index
final currentPageProvider = StateProvider<int>((ref) => 0);

// Provider to track if the user has completed onboarding
final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);

class OnboardingScreen extends ConsumerWidget {
  OnboardingScreen({super.key});

  final PageController _pageController = PageController();

  /// Handles next button or finish button press
  Future<void> _onNextPressed(WidgetRef ref, BuildContext context) async {
    final currentPage = ref.read(currentPageProvider);

    if (currentPage < onboardingData.length - 1) {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page, complete onboarding
      await _completeOnboarding(ref);

      if (context.mounted) {
        // Navigate to login screen
        context.go('/login');
      }
    }
  }

  /// Marks onboarding as completed in local storage
  Future<void> _completeOnboarding(WidgetRef ref) async {
    try {
      // Save that user has completed onboarding
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);

      // Update provider state
      ref.read(hasCompletedOnboardingProvider.notifier).state = true;
    } catch (e) {
      developer.log('Error saving onboarding status: $e');
      // Continue anyway to not block the user
    }
  }

  /// Handles skip button press
  Future<void> _skipOnboarding(WidgetRef ref, BuildContext context) async {
    await _completeOnboarding(ref);

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    // Screen dimension getters moved inside build
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              ref.read(currentPageProvider.notifier).state = index;
            },
            itemBuilder: (context, index) {
              return OnboardingItemWidget(
                item: onboardingData[index],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              );
            },
          ),

          // Skip button (top-right)
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.06,
            child: TextButton(
              onPressed: () => _skipOnboarding(ref, context),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: screenHeight * 0.06,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page indicator
                Row(
                  children: List.generate(
                    onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      width: currentPage == index
                          ? screenWidth * 0.05
                          : screenWidth * 0.02,
                      height: screenHeight * 0.01,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Next/Get Started button
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    color: colorScheme.secondary,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      onTap: () => _onNextPressed(ref, context),
                      child: Center(
                        child: currentPage == onboardingData.length - 1
                            ? Text(
                                'Start',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
