import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/services/image_generation_service.dart';

final imageGenerationServiceProvider = Provider<ImageGenerationService>((ref) {
  developer.log(
    'Creating ImageGenerationService instance',
    name: 'ImageGenerationProvider',
  );
  return ImageGenerationService();
});

final isGeneratingProvider = StateProvider<bool>((ref) {
  developer.log(
    'Initializing isGenerating state to false',
    name: 'ImageGenerationProvider',
  );
  return false;
});

final generatedImagesProvider = StateProvider<List<String>>((ref) {
  developer.log(
    'Initializing generatedImages state to empty list',
    name: 'ImageGenerationProvider',
  );
  return [];
});

final imageGenerationControllerProvider = Provider((ref) {
  developer.log(
    'Creating ImageGenerationController instance',
    name: 'ImageGenerationProvider',
  );
  return ImageGenerationController(ref);
});

class ImageGenerationController {
  final Ref _ref;

  ImageGenerationController(this._ref) {
    developer.log(
      'Initializing ImageGenerationController',
      name: 'ImageGenerationController',
    );
  }

  Future<void> generateImage(String prompt, {String? negativePrompt}) async {
    developer.log(
      'Generating image with prompt: $prompt, negative prompt: $negativePrompt',
      name: 'ImageGenerationController',
    );

    try {
      developer.log(
        'Setting isGenerating state to true',
        name: 'ImageGenerationController',
      );
      _ref.read(isGeneratingProvider.notifier).state = true;

      developer.log(
        'Getting ImageGenerationService instance',
        name: 'ImageGenerationController',
      );
      final imageService = _ref.read(imageGenerationServiceProvider);

      developer.log(
        'Calling service to generate image',
        name: 'ImageGenerationController',
      );
      final imageData = await imageService.generateImage(
        prompt: prompt,
        negativePrompt: negativePrompt,
      );

      developer.log(
        'Image generated successfully, updating state',
        name: 'ImageGenerationController',
      );
      final currentImages = List<String>.from(
        _ref.read(generatedImagesProvider),
      );
      currentImages.insert(0, imageData);
      _ref.read(generatedImagesProvider.notifier).state = currentImages;

      developer.log(
        'State updated with new image',
        name: 'ImageGenerationController',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error in generateImage',
        name: 'ImageGenerationController',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      developer.log(
        'Setting isGenerating state to false',
        name: 'ImageGenerationController',
      );
      _ref.read(isGeneratingProvider.notifier).state = false;
    }
  }
}
