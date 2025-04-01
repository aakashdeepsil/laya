import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/user_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ContentGridView extends StatefulWidget {
  final User user;
  final bool isLoading;
  final String? error;

  const ContentGridView({
    super.key,
    required this.user,
    this.isLoading = false,
    this.error,
  });

  @override
  State<ContentGridView> createState() => _ContentGridViewState();
}

class _ContentGridViewState extends State<ContentGridView> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceVariant
                .withValues(alpha: 0.3),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: screenHeight * 0.05,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              widget.error!,
              style: TextStyle(
                fontSize: screenHeight * 0.018,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            TextButton.icon(
              onPressed: () {
                // Refresh content
              },
              icon: Icon(
                LucideIcons.refreshCw,
                size: screenHeight * 0.02,
              ),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: screenHeight * 0.015,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 4, // Replace with actual content count
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Navigate to content detail
            context.push('/content/$index');
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/anime_$index.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
