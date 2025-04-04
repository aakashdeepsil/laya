import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:laya/providers/image_generation_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageGenerationScreen extends ConsumerStatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  ConsumerState<ImageGenerationScreen> createState() =>
      _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends ConsumerState<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _negativePromptController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    developer.log(
      'Initializing Image Generation Screen',
      name: 'ImageGenerationScreen',
    );
  }

  @override
  void dispose() {
    developer.log(
      'Disposing Image Generation Screen',
      name: 'ImageGenerationScreen',
    );
    _promptController.dispose();
    _negativePromptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_promptController.text.trim().isEmpty) {
      developer.log(
        'Empty prompt submission prevented',
        name: 'ImageGenerationScreen',
      );
      return;
    }

    final prompt = _promptController.text.trim();
    final negativePrompt = _negativePromptController.text.trim();

    developer.log(
      'Submitting image generation request - Prompt: $prompt, Negative Prompt: $negativePrompt',
      name: 'ImageGenerationScreen',
    );

    try {
      await ref.read(imageGenerationControllerProvider).generateImage(
            prompt,
            negativePrompt: negativePrompt.isNotEmpty ? negativePrompt : null,
          );

      if (!mounted) return;

      developer.log(
        'Image generation successful, clearing input fields',
        name: 'ImageGenerationScreen',
      );

      _promptController.clear();
      _negativePromptController.clear();
    } catch (e, stackTrace) {
      developer.log(
        'Error generating image',
        name: 'ImageGenerationScreen',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearHistory() {
    developer.log(
      'Clearing generated images history',
      name: 'ImageGenerationScreen',
    );
    ref.read(generatedImagesProvider.notifier).state = [];
  }

  Future<void> _downloadImage(String imageUrl, int index) async {
    try {
      // Request appropriate permissions based on Android version
      if (Platform.isAndroid) {
        // For Android 13 and above
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;

        developer.log(
          'Permission status - Photos: ${photos.name}, Videos: ${videos.name}',
          name: 'ImageGenerationScreen',
        );

        // If any permission is not granted, request them
        if (!photos.isGranted || !videos.isGranted) {
          final photosRequest = await Permission.photos.request();
          final videosRequest = await Permission.videos.request();

          developer.log(
            'Permission request results - Photos: ${photosRequest.name}, Videos: ${videosRequest.name}',
            name: 'ImageGenerationScreen',
          );

          // Check if permissions were granted after request
          if (!photosRequest.isGranted || !videosRequest.isGranted) {
            // Show settings dialog if any permission is permanently denied
            if (photosRequest.isPermanentlyDenied ||
                videosRequest.isPermanentlyDenied) {
              if (!mounted) return;

              final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Permission Required'),
                  content: const Text(
                      'Permission to save images is required. Please enable it in settings.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );

              if (shouldOpenSettings == true) {
                await openAppSettings();
                return; // Return here to let user try again after changing settings
              }
            }
            throw Exception(
              'Permission denied. Status - Photos: ${photosRequest.name}, Videos: ${videosRequest.name}',
            );
          }
        }
      }

      // Get image bytes
      final bytes = Uri.parse(imageUrl).data!.contentAsBytes();

      // Get the pictures directory
      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Pictures/Laya')
          : await getApplicationDocumentsDirectory();

      developer.log(
        'Attempting to save to directory: ${directory.path}',
        name: 'ImageGenerationScreen',
      );

      // Create the directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        developer.log(
          'Created directory: ${directory.path}',
          name: 'ImageGenerationScreen',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created new Laya folder in Pictures directory'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Generate unique filename
      final fileName = 'laya_generated_image_${const Uuid().v4()}.png';
      final filePath = path.join(directory.path, fileName);

      developer.log(
        'Saving file to: $filePath',
        name: 'ImageGenerationScreen',
      );

      // Save the file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      developer.log(
        'File saved successfully',
        name: 'ImageGenerationScreen',
      );

      // Notify media store on Android
      if (Platform.isAndroid) {
        try {
          await _scanFile(filePath);
        } catch (e) {
          developer.log(
            'Warning: Could not scan file for media store',
            name: 'ImageGenerationScreen',
            error: e,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image saved to ${Platform.isAndroid ? "Pictures/Laya" : "Documents"} folder',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error saving image',
        name: 'ImageGenerationScreen',
        error: e,
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _scanFile(String filePath) async {
    // This is a placeholder for media scanning
    // On newer Android versions, the media store is automatically updated
    // For older versions, you might need to use platform channels to trigger a media scan
    developer.log(
      'File saved, media store will scan: $filePath',
      name: 'ImageGenerationScreen',
    );
  }

  void _removeImage(int index) {
    developer.log(
      'Removing image at index $index',
      name: 'ImageGenerationScreen',
    );
    final currentImages = List<String>.from(ref.read(generatedImagesProvider));
    currentImages.removeAt(index);
    ref.read(generatedImagesProvider.notifier).state = currentImages;
  }

  void _viewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                Uri.parse(imageUrl).data!.contentAsBytes(),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Building Image Generation Screen UI',
      name: 'ImageGenerationScreen',
    );

    final isGenerating = ref.watch(isGeneratingProvider);
    final generatedImages = ref.watch(generatedImagesProvider);

    developer.log(
      'Current state - IsGenerating: $isGenerating, Images Count: ${generatedImages.length}',
      name: 'ImageGenerationScreen',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Generation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: generatedImages.isEmpty
                  ? Center(
                      child: Text(
                        'No images generated yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: generatedImages.length,
                      itemBuilder: (context, index) {
                        developer.log(
                          'Building grid item for image $index',
                          name: 'ImageGenerationScreen',
                        );
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _viewImage(generatedImages[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  Uri.parse(generatedImages[index])
                                      .data!
                                      .contentAsBytes(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.download),
                                    onPressed: () => _downloadImage(
                                      generatedImages[index],
                                      index,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2),
                                    onPressed: () => _removeImage(index),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn().scale(
                              begin: const Offset(0.8, 0.8),
                              duration: const Duration(milliseconds: 300),
                            );
                      },
                    ),
            ),
            if (isGenerating)
              Padding(
                padding: const EdgeInsets.all(16),
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Enter your prompt...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: TextField(
                      controller: _negativePromptController,
                      decoration: InputDecoration(
                        hintText: 'Enter negative prompt (optional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 14),
                      onSubmitted: (_) {
                        developer.log(
                          'Negative prompt submitted via keyboard',
                          name: 'ImageGenerationScreen',
                        );
                        _handleSubmit();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isGenerating
                          ? null
                          : () {
                              developer.log(
                                'Generate button pressed',
                                name: 'ImageGenerationScreen',
                              );
                              _handleSubmit();
                            },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      child: Text(
                        isGenerating ? 'Generating...' : 'Generate Image',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
