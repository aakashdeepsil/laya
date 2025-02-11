import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/onboarding.dart';
import 'package:laya/shared/widgets/onboarding_item_widget.dart';

// State provider for current page index
final currentPageProvider = StateProvider<int>((ref) => 0);

class OnboardingScreen extends ConsumerWidget {
  OnboardingScreen({super.key});

  final PageController _pageController = PageController();

  void _onNextPressed(WidgetRef ref, BuildContext context) {
    final currentPage = ref.read(currentPageProvider);
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);

    // Screen dimension getters moved inside build
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          // Skip button
          // Positioned(
          //   top: screenHeight * 0.06,
          //   right: screenWidth * 0.08,
          //   child: TextButton(
          //     onPressed: () => context.push('/login'),
          //     child: Text(
          //       'Skip',
          //       style: TextStyle(
          //         color: Theme.of(context).colorScheme.secondary,
          //         fontSize: screenHeight * 0.025,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),

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
                        color: Theme.of(context).colorScheme.secondary,
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
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      onTap: () => _onNextPressed(ref, context),
                      child: Center(
                        child: currentPage == onboardingData.length - 1
                            ? const Text(
                                'Start',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
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
