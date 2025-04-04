import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:laya/providers/image_generation_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      body: Column(
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
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          Uri.parse(generatedImages[index])
                              .data!
                              .contentAsBytes(),
                          fit: BoxFit.cover,
                        ),
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
              children: [
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: 'Enter your prompt...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _negativePromptController,
                  decoration: InputDecoration(
                    hintText: 'Enter negative prompt (optional)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    developer.log(
                      'Negative prompt submitted via keyboard',
                      name: 'ImageGenerationScreen',
                    );
                    _handleSubmit();
                  },
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
    );
  }
}
