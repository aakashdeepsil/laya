import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/content/presentation/series/components/toast.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/shared/widgets/content/delete_alert_dialog_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laya/features/content/presentation/series/components/series_header.dart';
import 'package:laya/features/content/presentation/series/components/series_info_section.dart';
import 'package:laya/features/content/presentation/series/components/series_action_buttons.dart';
import 'package:laya/features/content/presentation/series/components/series_categories.dart';
import 'package:laya/features/content/presentation/series/components/series_content_list.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Change from ConsumerWidget to ConsumerStatefulWidget
class SeriesDetailsScreen extends ConsumerStatefulWidget {
  final Series series;

  const SeriesDetailsScreen({
    super.key,
    required this.series,
  });

  @override
  ConsumerState<SeriesDetailsScreen> createState() =>
      _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends ConsumerState<SeriesDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load the series data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(seriesStateProvider.notifier).loadSeries(widget.series.id);
    });
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final deleteNotifier = ref.read(deleteSeriesProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: ref.read(deleteSeriesProvider) is! AsyncLoading,
      builder: (context) => DeleteAlertDialog(
        isDeleting: ref.watch(deleteSeriesProvider) is AsyncLoading,
        deleteContent: null,
        deleteSeries: () async {
          await deleteNotifier.deleteSeries(widget.series);

          final state = ref.read(deleteSeriesProvider);
          if (state is AsyncData && context.mounted) {
            context.pop(); // Close dialog
            // Invalidate the seriesContentProvider to refresh the series details screen
            ref.invalidate(seriesContentProvider(widget.series.id));
            context.go('/profile');
            showToast(
              context: context,
              message: 'Series deleted successfully',
              type: ToastType.success,
            );
          } else if (state is AsyncError && context.mounted) {
            context.pop(); // Close dialog
            showToast(
              context: context,
              message: 'Failed to delete series',
              type: ToastType.error,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the series state
    final seriesState = ref.watch(seriesStateProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    // Check if user is the creator
    final isCreator = user?.id == seriesState.value?.creatorId;
    developer.log('Series details screen - isCreator: $isCreator');

    // Watch series content
    final seriesContentAsync = ref.watch(
      seriesContentProvider(seriesState.value?.id ?? ''),
    );

    // Create menu items for the header
    final menuItems = [
      PopupMenuItem(
        value: 1,
        child: ListTile(
          leading: Icon(
            LucideIcons.pencil,
            color: colorScheme.primary,
            size: screenHeight * 0.022,
          ),
          title: Text(
            'Edit Series',
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        onTap: () {
          // Need to use future to navigate after popup is dismissed
          Future.delayed(Duration.zero, () {
            if (context.mounted && seriesState.value != null) {
              context.push(
                '/edit_series',
                extra: {'series': seriesState.value},
              );
            }
          });
        },
      ),
      PopupMenuItem(
        value: 2,
        child: ListTile(
          leading: Icon(
            LucideIcons.trash,
            color: colorScheme.error,
            size: screenHeight * 0.022,
          ),
          title: Text(
            'Delete Series',
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            _showDeleteConfirmation(context, ref);
          });
        },
      ),
      PopupMenuItem(
        value: 3,
        child: ListTile(
          leading: Icon(
            LucideIcons.upload,
            color: colorScheme.primary,
            size: screenHeight * 0.022,
          ),
          title: Text(
            seriesState.value?.isPublished ?? false
                ? 'Unpublish Series'
                : 'Publish Series',
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            final publishNotifier = ref.read(
              publishSeriesProvider.notifier,
            );
            final publishState = ref.watch(
              publishSeriesProvider,
            );

            // Show loading state in the popup menu
            if (publishState is AsyncLoading) {
              return;
            }

            // Toggle publish status
            if (seriesState.value?.isPublished ?? false) {
              publishNotifier.unpublishSeries(seriesState.value!);
            } else {
              publishNotifier.publishSeries(seriesState.value!);
            }

            // Show toast based on the result
            publishState.whenData((_) {
              showToast(
                context: context,
                message: seriesState.value?.isPublished ?? false
                    ? 'Series unpublished successfully'
                    : 'Series published successfully',
                type: ToastType.success,
              );
            });
          });
        },
      ),
      PopupMenuItem(
        value: 4,
        child: ListTile(
          leading: Icon(
            LucideIcons.plusCircle,
            color: colorScheme.primary,
            size: screenHeight * 0.022,
          ),
          title: Text(
            'Add New Chapter',
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        onTap: () {
          Future.delayed(Duration.zero, () {
            if (context.mounted && seriesState.value != null) {
              context.push('/create_chapter', extra: {
                'series': seriesState.value,
              });
            }
          });
        },
      ),
    ];

    // Create publish status widget
    final publishStatusWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.005,
      ),
      decoration: BoxDecoration(
        color: seriesState.value?.isPublished ?? false
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ref.watch(publishSeriesProvider).when(
            data: (_) => Text(
              seriesState.value?.isPublished ?? false ? 'Published' : 'Draft',
              style: TextStyle(
                fontSize: screenHeight * 0.014,
                color: seriesState.value?.isPublished ?? false
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            loading: () => SizedBox(
              width: screenHeight * 0.02,
              height: screenHeight * 0.02,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  seriesState.value?.isPublished ?? false
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            error: (_, __) => Text(
              seriesState.value?.isPublished ?? false ? 'Published' : 'Draft',
              style: TextStyle(
                fontSize: screenHeight * 0.014,
                color: seriesState.value?.isPublished ?? false
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
    );

    return Scaffold(
      body: seriesState.when(
        data: (currentSeries) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Series Header
            SeriesHeader(
              series: currentSeries,
              isCreator: isCreator,
              onBack: () => context.go('/home'),
              menuItems: menuItems,
            ),

            // Series details and content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Series Info Section
                    SeriesInfoSection(
                      series: currentSeries,
                      isCreator: isCreator,
                      publishStatusWidget: publishStatusWidget,
                    ),

                    // Categories
                    if (currentSeries.categoryIds.isNotEmpty) ...[
                      SizedBox(height: screenHeight * 0.01),
                      SeriesCategories(
                        categoryIds: currentSeries.categoryIds,
                      ),
                    ],

                    // Action Buttons
                    seriesContentAsync.when(
                      data: (contentList) => SeriesActionButtons(
                        series: currentSeries,
                        contentList: contentList,
                        onStartReading: () {
                          if (contentList.isNotEmpty) {
                            final firstContent = contentList.first;
                            context.push('/reader', extra: {
                              'content': firstContent,
                              'series': currentSeries,
                            });
                          } else {
                            showToast(
                              context: context,
                              message: 'No content available to read',
                              type: ToastType.warning,
                            );
                          }
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Content List
                    SeriesContentList(
                      series: currentSeries,
                      isCreator: isCreator,
                      onAddChapter: () => context.push(
                        '/create_chapter',
                        extra: {'series': currentSeries},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading series: $error'),
        ),
      ),
    );
  }
}

Widget buildSeriesImage(String? imageUrl, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        LucideIcons.image,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  return CachedNetworkImage(
    imageUrl: imageUrl,
    errorWidget: (context, url, error) => Container(
      color: colorScheme.surfaceVariant,
      child: Icon(
        LucideIcons.alertCircle,
        color: colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
