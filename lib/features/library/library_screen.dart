import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/library/components/loading_grid.dart';
import 'package:laya/features/library/components/series_card.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/services/library_service.dart';

final libraryProvider = FutureProvider.autoDispose<List<Series>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  final libraryService = LibraryService();
  return await libraryService.getUserLibrary(user.id);
});

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        backgroundColor: const Color(0xFF0f172a),
      ),
      body: libraryAsync.when(
        loading: () => const LoadingGrid(),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (series) {
          if (series.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your library is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add series to your library to see them here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: series.length,
            itemBuilder: (context, index) {
              final item = series[index];
              return SeriesCard(series: item);
            },
          );
        },
      ),
    );
  }
}
