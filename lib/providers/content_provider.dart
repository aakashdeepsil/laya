import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/services/content_service.dart';
import 'package:laya/enums/content_status.dart';
import 'package:laya/enums/media_type.dart';
import 'dart:io';

// Content service provider
final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService();
});

// Content creation state
class ContentCreationState {
  final bool isLoading;
  final String? error;
  final File? thumbnail;
  final File? mediaFile;
  final MediaType mediaType;
  final String title;
  final String description;
  final String categoryId;
  final String seriesId;

  const ContentCreationState({
    this.isLoading = false,
    this.error,
    this.thumbnail,
    this.mediaFile,
    this.mediaType = MediaType.none,
    this.title = '',
    this.description = '',
    this.categoryId = '',
    this.seriesId = '',
  });

  ContentCreationState copyWith({
    bool? isLoading,
    String? error,
    File? thumbnail,
    File? mediaFile,
    MediaType? mediaType,
    String? title,
    String? description,
    String? categoryId,
    String? seriesId,
  }) {
    return ContentCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      thumbnail: thumbnail ?? this.thumbnail,
      mediaFile: mediaFile ?? this.mediaFile,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      seriesId: seriesId ?? this.seriesId,
    );
  }
}

class ContentCreationNotifier extends StateNotifier<ContentCreationState> {
  final ContentService _contentService;

  ContentCreationNotifier(this._contentService)
      : super(const ContentCreationState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setCategoryId(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setSeriesId(String seriesId) {
    state = state.copyWith(seriesId: seriesId);
  }

  void setThumbnail(File? thumbnail) {
    state = state.copyWith(thumbnail: thumbnail);
  }

  void setMediaFile(File? mediaFile) {
    state = state.copyWith(mediaFile: mediaFile);
  }

  void setMediaType(MediaType mediaType) {
    state = state.copyWith(mediaType: mediaType);
  }

  Future<Content?> createContent(String creatorId) async {
    if (state.thumbnail == null ||
        state.mediaFile == null ||
        state.mediaType == MediaType.none ||
        state.title.isEmpty ||
        state.description.isEmpty ||
        state.categoryId.isEmpty ||
        state.seriesId.isEmpty) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return null;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final content = await _contentService.createContent(
        categoryId: state.categoryId,
        creatorId: creatorId,
        seriesId: state.seriesId,
        description: state.description,
        title: state.title,
        mediaFile: state.mediaFile!,
        thumbnail: state.thumbnail!,
        mediaType: state.mediaType,
      );

      state = const ContentCreationState();
      return content;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<Content?> updateContent(String contentId) async {
    if (state.title.isEmpty ||
        state.description.isEmpty ||
        state.categoryId.isEmpty) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return null;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final content = await _contentService.updateContent(
        contentId: contentId,
        title: state.title,
        description: state.description,
        categoryId: state.categoryId,
        thumbnail: state.thumbnail ?? File(''),
        mediaFile: state.mediaFile ?? File(''),
        mediaType: state.mediaType,
      );

      state = const ContentCreationState();
      return content;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ContentCreationState();
  }
}

// Content creation provider
final contentCreationProvider =
    StateNotifierProvider<ContentCreationNotifier, ContentCreationState>((ref) {
  final contentService = ref.watch(contentServiceProvider);
  return ContentCreationNotifier(contentService);
});

// Content state notifier
class ContentNotifier extends StateNotifier<AsyncValue<List<Content>>> {
  final ContentService _contentService;

  ContentNotifier(this._contentService) : super(const AsyncValue.loading());

  Future<void> loadContentsBySeries(String seriesId) async {
    try {
      state = const AsyncValue.loading();
      final contents = await _contentService.getContentsBySeries(seriesId);
      state = AsyncValue.data(contents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateContentStatus({
    required String contentId,
    required ContentStatus status,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.updateContentStatus(
        contentId: contentId,
        status: status,
      );
      // Refresh content list
      final contents = await _contentService.getContentsBySeries(contentId);
      state = AsyncValue.data(contents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.deleteContent(contentId);
      // Refresh content list
      final contents = await _contentService.getContentsBySeries(contentId);
      state = AsyncValue.data(contents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Content provider
final contentProvider = StateNotifierProvider.family<ContentNotifier,
    AsyncValue<List<Content>>, String>((ref, seriesId) {
  final contentService = ref.watch(contentServiceProvider);
  return ContentNotifier(contentService);
});

// Reading progress notifier
class ReadingProgressNotifier extends StateNotifier<AsyncValue<double>> {
  final ContentService _contentService;

  ReadingProgressNotifier(this._contentService)
      : super(const AsyncValue.loading());

  Future<void> loadReadingProgress({
    required String contentId,
    required String userId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final progress = await _contentService.getReadingProgress(
        contentId: contentId,
        userId: userId,
      );
      state = AsyncValue.data(progress?.progress ?? 0.0);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateReadingProgress({
    required String contentId,
    required String userId,
    required double progress,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.updateReadingProgress(
        contentId: contentId,
        userId: userId,
        progress: progress,
      );
      state = AsyncValue.data(progress);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Reading progress provider
final readingProgressProvider = StateNotifierProvider.family<
    ReadingProgressNotifier,
    AsyncValue<double>,
    ({String contentId, String userId})>((ref, params) {
  final contentService = ref.watch(contentServiceProvider);
  return ReadingProgressNotifier(contentService);
});

// Chapter state notifier
class ChapterStateNotifier extends StateNotifier<AsyncValue<Content?>> {
  final ContentService _contentService;

  ChapterStateNotifier(this._contentService)
      : super(const AsyncValue.loading());

  void setContent(Content content) {
    state = AsyncValue.data(content);
  }

  Future<void> updateChapter({
    required String contentId,
    required String title,
    required String description,
    required String categoryId,
    File? thumbnail,
    File? mediaFile,
    required MediaType mediaType,
  }) async {
    try {
      state = const AsyncValue.loading();
      final content = await _contentService.updateContent(
        contentId: contentId,
        title: title,
        description: description,
        categoryId: categoryId,
        thumbnail: thumbnail ?? File(''),
        mediaFile: mediaFile ?? File(''),
        mediaType: mediaType,
      );
      state = AsyncValue.data(content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteChapter(String contentId) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.deleteContent(contentId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> publishChapter(String contentId) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.updateContentStatus(
        contentId: contentId,
        status: ContentStatus.published,
      );
      final content = await _contentService.getContent(contentId);
      state = AsyncValue.data(content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unpublishChapter(String contentId) async {
    try {
      state = const AsyncValue.loading();
      await _contentService.updateContentStatus(
        contentId: contentId,
        status: ContentStatus.draft,
      );
      final content = await _contentService.getContent(contentId);
      state = AsyncValue.data(content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Chapter state provider
final chapterStateProvider = StateNotifierProvider.family<ChapterStateNotifier,
    AsyncValue<Content?>, String>((ref, contentId) {
  final contentService = ref.watch(contentServiceProvider);
  return ChapterStateNotifier(contentService);
});
