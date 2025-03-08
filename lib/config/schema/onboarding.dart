// Onboarding data model
class OnboardingItem {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

// Onboarding data
final onboardingData = [
  OnboardingItem(
    title: "Your Perfect Reading Companion",
    description:
        "Discover a vast library of books and manga, all in one place. Read the way you want, when you want.",
    imageUrl: "assets/images/onboarding/indian_lady_reading_book.png",
  ),
  OnboardingItem(
    title: "Customizable Experience",
    description:
        "Personalize your reading experience with custom themes, fonts, and reading modes.",
    imageUrl: "assets/images/onboarding/customized_themes_and_ui.png",
  ),
  OnboardingItem(
    title: "Track Your Progress",
    description:
        "Keep track of your reading progress, bookmarks, and favorite moments across all your books.",
    imageUrl: "assets/images/onboarding/indian_man_tracking_progress.png",
  ),
  OnboardingItem(
    title: "Join Our Community",
    description:
        "Connect with fellow readers, share your thoughts, and discover new stories together.",
    imageUrl: "assets/images/onboarding/community_reading_book.png",
  ),
];
