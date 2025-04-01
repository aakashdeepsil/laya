import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/features/content/presentation/series/components/content_list_item.dart';
import 'package:laya/features/content/presentation/series/components/content_skeleton_item.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class SeriesContentList extends ConsumerWidget {
  final Series series;
  final bool isCreator;
  final VoidCallback onAddChapter;

  const SeriesContentList({
    super.key,
    required this.series,
    required this.isCreator,
    required this.onAddChapter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    // Watch series content
    final seriesContentAsync = ref.watch(
      seriesContentProvider(series.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content list header
        Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            bottom: screenHeight * 0.01,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapters',
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (isCreator)
                IconButton(
                  onPressed: onAddChapter,
                  icon: Icon(
                    LucideIcons.plus,
                    size: screenHeight * 0.022,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),

        // Content list
        seriesContentAsync.when(
          data: (contentList) {
            if (contentList.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: Text(
                    'No chapters yet',
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contentList.length,
              itemBuilder: (context, index) {
                final content = contentList[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  child: ContentListItem(
                    content: content,
                    series: series,
                    isCreator: isCreator,
                    onTap: () {
                      GoRouter.of(context).go(
                        '/reader',
                        extra: {'content': content},
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                child: const ContentSkeletonItem(),
              );
            },
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Text(
                'Error loading chapters: ${error.toString()}',
                style: TextStyle(
                  fontSize: screenHeight * 0.016,
                  color: colorScheme.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
