import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/enums/media_type.dart';
import 'package:laya/providers/content_provider.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/series_provider.dart';

class CreateChapterScreen extends ConsumerStatefulWidget {
  final Series? series;

  const CreateChapterScreen({super.key, this.series});

  @override
  ConsumerState<CreateChapterScreen> createState() =>
      _CreateChapterScreenState();
}

class _CreateChapterScreenState extends ConsumerState<CreateChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Series? _selectedSeries;

  @override
  void initState() {
    super.initState();
    // If series is provided, set it as selected
    if (widget.series != null) {
      _selectedSeries = widget.series;
      // Initialize content creation state with series ID after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(contentCreationProvider.notifier)
            .setSeriesId(widget.series!.id);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        ref.read(contentCreationProvider.notifier).setThumbnail(
              File(result.files.single.path!),
            );
      }
    } catch (e) {
      _showError('Failed to pick thumbnail: ${e.toString()}');
    }
  }

  Future<void> _pickMediaFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'mp4', 'mov', 'avi', 'txt'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        // Set media type based on file extension
        if (extension == 'pdf' ||
            extension == 'doc' ||
            extension == 'docx' ||
            extension == 'txt') {
          ref
              .read(contentCreationProvider.notifier)
              .setMediaType(MediaType.document);
        } else if (extension == 'mp4' ||
            extension == 'mov' ||
            extension == 'avi') {
          ref
              .read(contentCreationProvider.notifier)
              .setMediaType(MediaType.video);
        }

        ref.read(contentCreationProvider.notifier).setMediaFile(file);
      }
    } catch (e) {
      _showError('Failed to pick media file: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(message),
      ),
    );
  }

  Future<void> _createChapter() async {
    if (!_formKey.currentState!.validate()) return;

    // Get current user from auth state
    final currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text('You must be logged in to create a chapter'),
          ),
        );
      }
      return;
    }

    // If no series is selected, show error
    if (_selectedSeries == null) {
      _showError('Please select a series');
      return;
    }

    // Set the series ID and other content details
    ref.read(contentCreationProvider.notifier)
      ..setSeriesId(_selectedSeries!.id)
      ..setTitle(_titleController.text.trim())
      ..setDescription(_descriptionController.text.trim())
      ..setCategoryId(_selectedSeries!.categoryIds.first);

    final content =
        await ref.read(contentCreationProvider.notifier).createContent(
              currentUser.id,
            );

    if (content != null && mounted) {
      // Navigate based on the scenario
      if (widget.series != null) {
        // If we came from series details, go back to series details
        context.pop();
      } else {
        // If we came from profile, go back to profile
        context.go('/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentCreationProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    // Watch user's series if no series is provided
    final userSeriesAsync = widget.series == null && currentUser != null
        ? ref.watch(userSeriesProvider(currentUser.id))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Chapter'),
        actions: [
          !state.isLoading
              ? IconButton(
                  onPressed: _createChapter,
                  icon: const Icon(LucideIcons.check),
                )
              : const CircularProgressIndicator(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenHeight * 0.015),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show series dropdown only if no series is provided
                if (widget.series == null) ...[
                  Text(
                    'Select Series',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  if (userSeriesAsync != null)
                    userSeriesAsync.when(
                      data: (seriesList) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenHeight * 0.015,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<Series>(
                          value: _selectedSeries,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: seriesList.map((series) {
                            return DropdownMenuItem(
                              value: series,
                              child: Text(series.title),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSeries = value;
                              if (value != null) {
                                ref
                                    .read(contentCreationProvider.notifier)
                                    .setSeriesId(value.id);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a series';
                            }
                            return null;
                          },
                        ),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Text(
                        'Error loading series: ${error.toString()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SizedBox(height: screenHeight * 0.02),
                ],
                InputField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Enter chapter title',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.01),
                InputField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter chapter description',
                  maxLines: 4,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Media Files',
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                MediaButton(
                  label: 'Upload Thumbnail',
                  icon: LucideIcons.image,
                  onTap: _pickThumbnail,
                  selectedFileName: state.thumbnail?.path.split('/').last,
                ),
                SizedBox(height: screenHeight * 0.01),
                if (state.thumbnail != null)
                  Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(state.thumbnail!),
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
                            onPressed: () => ref
                                .read(contentCreationProvider.notifier)
                                .setThumbnail(null),
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
                SizedBox(height: screenHeight * 0.02),
                MediaButton(
                  label: 'Upload Media File',
                  icon: LucideIcons.upload,
                  onTap: _pickMediaFile,
                  selectedFileName: state.mediaFile?.path.split('/').last,
                ),
                SizedBox(height: screenHeight * 0.01),
                if (state.mediaFile != null)
                  Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () => ref
                                .read(contentCreationProvider.notifier)
                                .setMediaFile(null),
                            icon: const Icon(LucideIcons.x),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                state.mediaType == MediaType.document
                                    ? LucideIcons.fileText
                                    : LucideIcons.video,
                                size: screenHeight * 0.05,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                state.mediaFile!.path.split('/').last,
                                style: TextStyle(
                                  fontSize: screenHeight * 0.015,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.error != null)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: screenHeight * 0.015,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
