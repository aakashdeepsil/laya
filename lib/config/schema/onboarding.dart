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
    imageUrl:
        "https://api.a0.dev/assets/image?text=person%20reading%20book%20in%20cozy%20setting%20minimal%20illustration&aspect=16:9&seed=1",
  ),
  OnboardingItem(
    title: "Customizable Experience",
    description:
        "Personalize your reading experience with custom themes, fonts, and reading modes.",
    imageUrl:
        "https://api.a0.dev/assets/image?text=customization%20settings%20UI%20minimal%20illustration&aspect=16:9&seed=2",
  ),
  OnboardingItem(
    title: "Track Your Progress",
    description:
        "Keep track of your reading progress, bookmarks, and favorite moments across all your books.",
    imageUrl:
        "https://api.a0.dev/assets/image?text=progress%20tracking%20analytics%20minimal%20illustration&aspect=16:9&seed=3",
  ),
  OnboardingItem(
    title: "Join Our Community",
    description:
        "Connect with fellow readers, share your thoughts, and discover new stories together.",
    imageUrl:
        "https://api.a0.dev/assets/image?text=community%20of%20readers%20sharing%20minimal%20illustration&aspect=16:9&seed=4",
  ),
];
