import 'package:flutter/material.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/shared/widgets/cached_image_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SeriesHeader extends StatelessWidget {
  final Series series;
  final bool isCreator;
  final VoidCallback onBack;
  final List<PopupMenuItem<int>> menuItems;

  const SeriesHeader({
    super.key,
    required this.series,
    required this.isCreator,
    required this.onBack,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: screenHeight * 0.25,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            CachedImageWidget(
              imageUrl: series.coverImageUrl ?? '',
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        onPressed: onBack,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      actions: isCreator
          ? [
              PopupMenuButton<int>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.moreVertical),
                ),
                itemBuilder: (context) => menuItems,
              ),
            ]
          : null,
    );
  }
}
