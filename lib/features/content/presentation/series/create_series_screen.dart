import 'dart:io';
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/models/category_model.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/category_provider.dart';
import 'package:laya/services/category_service.dart';
import 'package:laya/services/series_service.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laya/providers/series_provider.dart';

// State notifier for creating a series
class CreateSeriesNotifier extends StateNotifier<AsyncValue<void>> {
  final CategoryService _categoryService;
  final SeriesService _seriesService;

  CreateSeriesNotifier({
    required CategoryService categoryService,
    required SeriesService seriesService,
  })  : _categoryService = categoryService,
        _seriesService = seriesService,
        super(const AsyncValue.data(null));

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // Load all categories
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      _categories = await _categoryService.getAllCategories();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading categories: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Create a new series
  Future<Series?> createSeries({
    required List<String> categoryIds,
    required String creatorId,
    required String description,
    required String title,
    required File coverImageFile,
    required File thumbnailFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Create a new Series object first to get the ID
      final newSeries = Series(
        id: '', // This will be assigned by Firestore
        title: title,
        description: description,
        creatorId: creatorId,
        categoryIds: categoryIds,
        coverImageUrl: '',
        thumbnailUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: false,
        viewCount: 0,
      );

      // Create the series in Firestore to get the ID
      final seriesId = await _seriesService.createSeries(newSeries);

      // Update the series with the image URLs
      final updatedSeries = await _seriesService.updateSeries(
        series: newSeries.copyWith(id: seriesId),
        newCoverImage: coverImageFile.path.isNotEmpty ? coverImageFile : null,
        newThumbnail: thumbnailFile.path.isNotEmpty ? thumbnailFile : null,
      );

      state = const AsyncValue.data(null);
      return updatedSeries;
    } catch (e, stackTrace) {
      developer.log(
        'Error creating series: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }
}

// Provider for CreateSeriesNotifier
final createSeriesProvider =
    StateNotifierProvider.autoDispose<CreateSeriesNotifier, AsyncValue<void>>(
  (ref) {
    return CreateSeriesNotifier(
      categoryService: ref.watch(categoryServiceProvider),
      seriesService: ref.watch(seriesServiceProvider),
    );
  },
);

// User provider - assuming you have a current user provider somewhere
final currentUserProvider = Provider<User?>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    return authState.whenData((user) => user).value;
  },
);

class CreateSeriesScreen extends ConsumerStatefulWidget {
  const CreateSeriesScreen({super.key});

  @override
  ConsumerState<CreateSeriesScreen> createState() => _CreateSeriesScreenState();
}

class _CreateSeriesScreenState extends ConsumerState<CreateSeriesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _seriesDescriptionController =
      TextEditingController();
  final TextEditingController _seriesTitleController = TextEditingController();

  File? _coverImage;
  File? _thumbnail;
  final Set<String> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    // Load categories when page initializes
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.read(createSeriesProvider.notifier).loadCategories();
      },
    );
  }

  @override
  void dispose() {
    _seriesDescriptionController.dispose();
    _seriesTitleController.dispose();
    super.dispose();
  }

  // Pick a thumbnail for the series
  Future<void> _pickThumbnail() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
      );

      if (result == null) return;

      setState(() => _thumbnail = File(result.files.single.path!));
    } catch (e) {
      _showErrorSnackBar('Failed to pick thumbnail: ${e.toString()}');
    }
  }

  // Pick a cover image for the series
  Future<void> _pickCoverImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
      );

      if (result == null) return;

      setState(() => _coverImage = File(result.files.single.path!));
    } catch (e) {
      _showErrorSnackBar('Failed to pick cover image: ${e.toString()}');
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool _validateSubmission() {
    // Check if user is logged in
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _showErrorSnackBar('You must be logged in to create a series');
      return false;
    }

    if (_selectedCategoryIds.isEmpty) {
      _showErrorSnackBar('Please select at least one category for your series');
      return false;
    }

    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _createSeries() async {
    // Get the current user from provider
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _showErrorSnackBar('You must be logged in to create a series');
      return;
    }

    if (!_validateSubmission()) return;

    final title = _seriesTitleController.text.trim();
    final description = _seriesDescriptionController.text.trim();

    final series = await ref.read(createSeriesProvider.notifier).createSeries(
          categoryIds: _selectedCategoryIds.toList(),
          creatorId: currentUser.id,
          description: description,
          title: title,
          coverImageFile: _coverImage ?? File(''),
          thumbnailFile: _thumbnail ?? File(''),
        );

    if (series != null && mounted) {
      _showSuccessSnackBar('Series created successfully');

      // Navigate to series details page
      context.go(
        '/series_details',
        extra: {'series': series},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSeriesProvider);
    final notifier = ref.watch(createSeriesProvider.notifier);
    final categories = notifier.categories;

    // Watch the current user (this will rebuild if auth state changes)
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = currentUser != null;

    final isLoading = state is AsyncLoading;
    final hasError = state is AsyncError;

    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar((state).error.toString());
      });
    }

    // If not authenticated, show auth required screen
    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Create Series',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.userX,
                size: 48,
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please log in to create a series',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Series'),
        actions: [
          !isLoading
              ? IconButton(
                  onPressed: _createSeries,
                  icon: Icon(
                    LucideIcons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  tooltip: 'Create Series',
                )
              : CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.isLoading ? 'Creating series...' : 'Loading...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          controller: _seriesTitleController,
                          hint: 'Enter your series title',
                          label: 'Series Title',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a series title';
                            }
                            if (value!.length < 3) {
                              return 'Title must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          controller: _seriesDescriptionController,
                          hint: 'Enter your series description',
                          label: 'Series Description',
                          maxLines: 4,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a series description';
                            }
                            if (value!.length < 10) {
                              return 'Description must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((category) {
                            final isSelected =
                                _selectedCategoryIds.contains(category.id);
                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              onSelected: (_) => _toggleCategory(category.id),
                              showCheckmark: true,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              checkmarkColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Media Files',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MediaButton(
                          icon: LucideIcons.imagePlus,
                          label: 'Upload Thumbnail',
                          onTap: _pickThumbnail,
                          selectedFileName: _thumbnail?.path.split('/').last,
                        ),
                        const SizedBox(height: 12),
                        if (_thumbnail != null)
                          Container(
                            height: 180,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_thumbnail!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () =>
                                        setState(() => _thumbnail = null),
                                    icon: const Icon(LucideIcons.x),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        MediaButton(
                          icon: LucideIcons.upload,
                          label: 'Upload Cover Image',
                          onTap: _pickCoverImage,
                          selectedFileName: _coverImage?.path.split('/').last,
                        ),
                        const SizedBox(height: 12),
                        if (_coverImage != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () =>
                                        setState(() => _coverImage = null),
                                    icon: const Icon(LucideIcons.x),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
