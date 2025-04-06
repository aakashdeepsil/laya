import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget heroBanner(Series? series, Size screenSize, BuildContext context) {
  if (series == null) {
    return Container(
      height: screenSize.height * 0.7,
      color: const Color(0xFF1e293b),
      child: const Center(
        child: Text(
          'No featured content available',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  return Stack(
    children: [
      // Banner image
      CachedNetworkImage(
        imageUrl: series.coverImageUrl ?? '',
        height: screenSize.height * 0.7,
        width: screenSize.width,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1e293b),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF1e293b),
          child: const Icon(Icons.error, color: Colors.white),
        ),
      ),

      // Gradient overlay
      Container(
        height: screenSize.height * 0.7,
        width: screenSize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),

      // Content overlay
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                series.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                  ],
                ),
              ),

              // Description
              const SizedBox(height: 12),
              Text(
                series.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              // Buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  // Read Now button
                  ElevatedButton(
                    onPressed: () => context.push(
                      '/series_details',
                      extra: {'series': series},
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe50914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Read Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Add to list button
                  Consumer(
                    builder: (context, ref, child) {
                      final user = ref.watch(authStateProvider).valueOrNull;
                      final libraryStatusAsync = user != null
                          ? ref.watch(
                              libraryStatusProvider(
                                (
                                  seriesId: series!.id,
                                  userId: user.id,
                                ),
                              ),
                            )
                          : const AsyncValue<bool>.data(false);

                      return ElevatedButton.icon(
                        onPressed: user != null
                            ? () {
                                ref
                                    .read(libraryStatusProvider((
                                      seriesId: series.id,
                                      userId: user.id,
                                    )).notifier)
                                    .toggleStatus();
                              }
                            : null,
                        icon: libraryStatusAsync.when(
                          data: (inLibrary) => Icon(
                            inLibrary ? LucideIcons.check : LucideIcons.plus,
                            size: 16,
                          ),
                          loading: () => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          error: (_, __) =>
                              const Icon(LucideIcons.plus, size: 16),
                        ),
                        label: libraryStatusAsync.when(
                          data: (inLibrary) => Text(
                            user != null
                                ? (inLibrary ? 'In List' : 'My List')
                                : 'Sign in to add',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          loading: () => const Text(
                            'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          error: (_, __) => const Text(
                            'My List',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
