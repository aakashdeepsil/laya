import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/profile/presentation/components/empty_state.dart';
import 'package:laya/features/profile/presentation/components/series_grid_item.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/profile_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user and profile user from providers
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final profileUser = ref.watch(profileProvider).valueOrNull;

    if (currentUser == null || profileUser == null) {
      return const SizedBox.shrink();
    }

    final isCurrentUser = profileUser.id == currentUser.id;
    developer.log(
      'Building profile tabs for user: ${profileUser.id}, isCurrentUser: $isCurrentUser',
    );
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(LucideIcons.library, size: 20),
                ),
                Tab(
                  icon: Icon(LucideIcons.bookOpen, size: 20),
                ),
                Tab(
                  icon: Icon(LucideIcons.listChecks, size: 20),
                ),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor:
                  colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              onTap: (index) {
                developer.log(
                  'Tab selected: ${[
                    'Library',
                    'Reading',
                    'Lists'
                  ][index]} for user: ${profileUser.id}',
                );
              },
            ),
          ),
          SizedBox(
            height: 400, // Increased height for content
            child: TabBarView(
              children: [
                // Library tab (series created by user)
                Consumer(
                  builder: (context, ref, child) {
                    developer.log(
                      'Building Library tab content for user: ${profileUser.id}',
                    );
                    final seriesAsyncValue = ref.watch(
                      userSeriesProvider(profileUser.id),
                    );

                    return seriesAsyncValue.when(
                      data: (seriesList) {
                        developer.log(
                          'Received ${seriesList.length} series for user: ${profileUser.id}',
                        );
                        if (seriesList.isEmpty) {
                          developer.log(
                            'No series found for user: ${profileUser.id}',
                          );
                          return emptyState(
                            'You haven\'t created any series yet',
                            'Create your first series to see it here.',
                            colorScheme,
                            ElevatedButton.icon(
                              onPressed: () => context.push('/create_series'),
                              icon: const Icon(LucideIcons.plusCircle),
                              label: const Text('Create Series'),
                            ),
                          );
                        }

                        developer.log(
                          'Building GridView for ${seriesList.length} series items',
                        );
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: seriesList.length,
                            itemBuilder: (context, index) {
                              final series = seriesList[index];
                              developer.log(
                                  'Building grid item for series: ${series.id}, title: ${series.title}');
                              return SeriesGridItem(
                                series: series,
                                creator: profileUser,
                              );
                            },
                          ),
                        );
                      },
                      loading: () {
                        developer.log(
                            'Loading series data for user: ${profileUser.id}');
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        );
                      },
                      error: (error, stackTrace) {
                        developer.log(
                          'Error loading series for user: ${profileUser.id}',
                          error: error,
                          stackTrace: stackTrace,
                        );
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.alertTriangle,
                                color: colorScheme.error,
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading series',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (isCurrentUser)
                                TextButton(
                                  onPressed: () {
                                    developer.log(
                                      'Refreshing series data for user: ${profileUser.id}',
                                    );
                                    ref
                                        .read(userSeriesProvider(profileUser.id)
                                            .notifier)
                                        .refresh();
                                  },
                                  child: Text(
                                    'Try Again',
                                    style:
                                        TextStyle(color: colorScheme.primary),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                // Reading tab (currently reading)
                Builder(
                  builder: (context) {
                    developer.log(
                      'Building Reading tab (empty state) for user: ${profileUser.id}',
                    );
                    return emptyState(
                      'Not reading anything yet',
                      'Start reading a book to see it here.',
                      colorScheme,
                      null,
                    );
                  },
                ),

                // Lists tab (reading lists/collections)
                Builder(
                  builder: (context) {
                    developer.log(
                      'Building Lists tab (empty state) for user: ${profileUser.id}',
                    );
                    return emptyState(
                      'No reading lists yet',
                      'Create lists to organize your books.',
                      colorScheme,
                      null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
