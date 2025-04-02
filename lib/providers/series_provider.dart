import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/services/library_service.dart';
import 'package:laya/services/content_service.dart';
import 'package:laya/services/series_service.dart';

// Repository providers
final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService();
});

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

final seriesServiceProvider = Provider<SeriesService>((ref) {
  return SeriesService();
});

// User series provider
final userSeriesProvider = StateNotifierProvider.family<UserSeriesNotifier,
    AsyncValue<List<Series>>, String>(
  (ref, userId) {
    final repository = ref.watch(seriesServiceProvider);
    return UserSeriesNotifier(repository, userId);
  },
);

class UserSeriesNotifier extends StateNotifier<AsyncValue<List<Series>>> {
  final SeriesService _repository;
  final String _userId;

  UserSeriesNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    loadUserSeries();
  }

  Future<void> loadUserSeries() async {
    try {
      state = const AsyncValue.loading();
      final series = await _repository.getUserSeries(_userId);
      state = AsyncValue.data(series);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadUserSeries();
  }
}

// Series content provider
final seriesContentProvider = FutureProvider.family<List<Content>, String>(
  (ref, seriesId) async {
    developer.log('Fetching content for series: $seriesId');
    final repository = ref.watch(contentServiceProvider);
    return repository.getContentsBySeries(seriesId);
  },
);

// Library status provider
final libraryStatusProvider = StateNotifierProvider.family<
    LibraryStatusNotifier,
    AsyncValue<bool>,
    ({String seriesId, String userId})>(
  (ref, params) {
    final repository = ref.watch(libraryServiceProvider);
    return LibraryStatusNotifier(
        repository: repository,
        seriesId: params.seriesId,
        userId: params.userId);
  },
);

class LibraryStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  final LibraryService repository;
  final String seriesId;
  final String userId;

  LibraryStatusNotifier({
    required this.repository,
    required this.seriesId,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      developer.log(
        'Checking library status for series: $seriesId, user: $userId',
      );
      final status = await repository.isSeriesInLibrary(
        seriesId: seriesId,
        userId: userId,
      );
      state = AsyncValue.data(status);
      developer.log('Library status result: $status');
    } catch (e, stack) {
      developer.log('Error checking library status',
          error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleStatus() async {
    if (state is AsyncLoading) return;

    try {
      final currentValue = state.value ?? false;
      developer.log(
        'Toggling library status from $currentValue for series: $seriesId',
      );

      // Optimistic update
      state = AsyncValue.data(!currentValue);

      if (!currentValue) {
        await repository.addToLibrary(
          seriesId: seriesId,
          userId: userId,
        );
        developer.log('Series added to library');
      } else {
        await repository.removeFromLibrary(
          seriesId: seriesId,
          userId: userId,
        );
        developer.log('Series removed from library');
      }
    } catch (e, stack) {
      developer.log(
        'Error toggling library status',
        error: e,
        stackTrace: stack,
      );
      // Revert on error
      state = AsyncValue.error(e, stack);
      // Re-check to ensure state consistency
      _checkStatus();
    }
  }
}

// Delete series provider
final deleteSeriesProvider =
    StateNotifierProvider.autoDispose<DeleteSeriesNotifier, AsyncValue<void>>(
        (ref) {
  final repository = ref.watch(seriesServiceProvider);
  return DeleteSeriesNotifier(service: repository);
});

class DeleteSeriesNotifier extends StateNotifier<AsyncValue<void>> {
  final SeriesService service;

  DeleteSeriesNotifier({required this.service})
      : super(const AsyncValue.data(null));

  Future<void> deleteSeries(Series series) async {
    if (state is AsyncLoading) return;

    try {
      developer.log('Deleting series: ${series.id}');
      state = const AsyncValue.loading();
      await service.deleteSeries(series.id);
      state = const AsyncValue.data(null);
      developer.log('Series deleted successfully');
    } catch (e, stack) {
      developer.log('Error deleting series', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }
}

// Series state provider
final seriesStateProvider =
    StateNotifierProvider.autoDispose<SeriesStateNotifier, AsyncValue<Series>>(
  (ref) => SeriesStateNotifier(ref.watch(seriesServiceProvider)),
);

class SeriesStateNotifier extends StateNotifier<AsyncValue<Series>> {
  final SeriesService _service;

  SeriesStateNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadSeries(String seriesId) async {
    try {
      state = const AsyncValue.loading();
      final series = await _service.getSeriesById(seriesId);
      if (series != null) {
        state = AsyncValue.data(series);
      } else {
        state = const AsyncValue.error('Series not found', StackTrace.empty);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSeries(Series series) async {
    try {
      state = const AsyncValue.loading();
      final updatedSeries = await _service.updateSeries(series: series);
      state = AsyncValue.data(updatedSeries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Publish series provider
final publishSeriesProvider =
    StateNotifierProvider.autoDispose<PublishSeriesNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(seriesServiceProvider);
    final seriesStateNotifier = ref.watch(seriesStateProvider.notifier);
    return PublishSeriesNotifier(
      service: repository,
      seriesStateNotifier: seriesStateNotifier,
    );
  },
);

class PublishSeriesNotifier extends StateNotifier<AsyncValue<void>> {
  final SeriesService service;
  final SeriesStateNotifier seriesStateNotifier;

  PublishSeriesNotifier({
    required this.service,
    required this.seriesStateNotifier,
  }) : super(const AsyncValue.data(null));

  Future<void> publishSeries(Series series) async {
    if (state is AsyncLoading) return;

    try {
      if (!mounted) return;
      state = const AsyncValue.loading();

      await service.publishSeries(series.id);

      // Reload the series data to get the latest state
      await seriesStateNotifier.loadSeries(series.id);

      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      developer.log('Error publishing series', error: e, stackTrace: stack);
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unpublishSeries(Series series) async {
    if (state is AsyncLoading) return;

    try {
      if (!mounted) return;
      state = const AsyncValue.loading();

      await service.unpublishSeries(series.id);

      // Reload the series data to get the latest state
      await seriesStateNotifier.loadSeries(series.id);

      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      developer.log('Error unpublishing series', error: e, stackTrace: stack);
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }
}
