import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/enums/media_type.dart';
import 'package:laya/providers/content_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditChapterScreen extends ConsumerStatefulWidget {
  final Content content;

  const EditChapterScreen({super.key, required this.content});

  @override
  ConsumerState<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends ConsumerState<EditChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _showCurrentThumbnail = true;
  bool _showCurrentMedia = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.content.title);
    _descriptionController = TextEditingController(
      text: widget.content.description,
    );

    // Initialize content creation state with existing content after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentCreationProvider.notifier)
        ..setTitle(widget.content.title)
        ..setDescription(widget.content.description)
        ..setCategoryId(widget.content.categoryId)
        ..setSeriesId(widget.content.seriesId)
        ..setMediaType(widget.content.mediaType);

      // Initialize chapter state
      ref
          .read(chapterStateProvider(widget.content.id).notifier)
          .setContent(widget.content);
    });
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
        setState(() {
          _showCurrentThumbnail = false;
        });
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
        allowedExtensions: ['pdf', 'doc', 'docx', 'mp4', 'mov', 'avi'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _showCurrentMedia = false;
        });
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        // Set media type based on file extension
        if (extension == 'pdf' || extension == 'doc' || extension == 'docx') {
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

  Future<void> _updateContent() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(contentCreationProvider);
    final chapterState =
        ref.read(chapterStateProvider(widget.content.id).notifier);

    await chapterState.updateChapter(
      contentId: widget.content.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: widget.content.categoryId,
      thumbnail: state.thumbnail,
      mediaFile: state.mediaFile,
      mediaType: state.mediaType,
    );

    // Invalidate the seriesContentProvider to refresh the content list
    ref.invalidate(seriesContentProvider(widget.content.seriesId));

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentCreationProvider);
    final chapterState = ref.watch(chapterStateProvider(widget.content.id));
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Chapter',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        actions: [
          if (!state.isLoading && !chapterState.isLoading)
            IconButton(
              onPressed: _updateContent,
              icon: Icon(
                LucideIcons.check,
                color: colorScheme.primary,
                size: screenHeight * 0.025,
              ),
            ),
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
                if (_showCurrentThumbnail)
                  Container(
                    height: screenHeight * 0.2,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          widget.content.thumbnailUrl,
                        ),
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
                            onPressed: () {
                              setState(() {
                                _showCurrentThumbnail = false;
                              });
                            },
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
                if (_showCurrentMedia)
                  Container(
                    height: screenHeight * 0.1,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenHeight * 0.08,
                          height: screenHeight * 0.08,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.content.mediaType == MediaType.document
                                ? LucideIcons.fileText
                                : LucideIcons.video,
                            size: screenHeight * 0.03,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: screenHeight * 0.01),
                        Expanded(
                          child: Text(
                            widget.content.mediaUrl.split('/').last,
                            style: TextStyle(
                              fontSize: screenHeight * 0.015,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showCurrentMedia = false;
                            });
                          },
                          icon: Icon(
                            LucideIcons.x,
                            size: screenHeight * 0.02,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.mediaFile != null)
                  Container(
                    height: screenHeight * 0.1,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenHeight * 0.08,
                          height: screenHeight * 0.08,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            state.mediaType == MediaType.document
                                ? LucideIcons.fileText
                                : LucideIcons.video,
                            size: screenHeight * 0.03,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: screenHeight * 0.01),
                        Expanded(
                          child: Text(
                            state.mediaFile!.path.split('/').last,
                            style: TextStyle(
                              fontSize: screenHeight * 0.015,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(contentCreationProvider.notifier)
                              .setMediaFile(null),
                          icon: Icon(
                            LucideIcons.x,
                            size: screenHeight * 0.02,
                            color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.error,
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
