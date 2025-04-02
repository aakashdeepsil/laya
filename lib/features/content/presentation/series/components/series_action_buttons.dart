import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SeriesActionButtons extends ConsumerWidget {
  final Series series;
  final List<Content> contentList;
  final VoidCallback onStartReading;

  const SeriesActionButtons({
    super.key,
    required this.series,
    required this.contentList,
    required this.onStartReading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    // Watch library status - only watch if user is logged in
    final libraryStatusAsync = user != null
        ? ref.watch(
            libraryStatusProvider(
              (
                seriesId: series.id,
                userId: user.id,
              ),
            ),
          )
        : const AsyncValue<bool>.data(false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: contentList.isNotEmpty ? onStartReading : null,
              icon: Icon(
                LucideIcons.bookOpen,
                size: screenHeight * 0.02,
                color: colorScheme.onPrimary,
              ),
              label: const Text(
                'Start Reading',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: libraryStatusAsync.when(
              data: (inLibrary) => OutlinedButton.icon(
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
                icon: Icon(
                  inLibrary ? LucideIcons.check : LucideIcons.plus,
                  size: screenHeight * 0.02,
                ),
                label: Text(
                  user != null
                      ? (inLibrary ? 'In Library' : 'Add to Library')
                      : 'Sign in to add',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              loading: () => OutlinedButton.icon(
                onPressed: null,
                icon: Icon(
                  LucideIcons.loader,
                  size: screenHeight * 0.02,
                ),
                label: Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              error: (error, stackTrace) => OutlinedButton.icon(
                onPressed: null,
                icon: Icon(
                  LucideIcons.alertCircle,
                  size: screenHeight * 0.02,
                ),
                label: Text(
                  'Error',
                  style: TextStyle(
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
