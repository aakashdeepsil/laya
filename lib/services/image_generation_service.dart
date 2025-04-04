import 'dart:developer' as developer;
import 'package:cloud_functions/cloud_functions.dart';

class ImageGenerationService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> generateImage({
    required String prompt,
    String? negativePrompt,
  }) async {
    developer.log(
      'Generating image with prompt: $prompt, negative prompt: $negativePrompt',
      name: 'ImageGenerationService',
    );

    try {
      developer.log(
        'Calling Firebase Function: generateImage',
        name: 'ImageGenerationService',
      );

      final callable = _functions.httpsCallable('generateImage');
      final result = await callable.call({
        'prompt': prompt,
        'negativePrompt': negativePrompt,
      });

      developer.log(
        'Firebase Function response received',
        name: 'ImageGenerationService',
      );

      if (result.data['success'] == true) {
        developer.log(
          'Image generated successfully',
          name: 'ImageGenerationService',
        );
        return result.data['imageData'] as String;
      } else {
        developer.log(
          'Image generation failed: success flag is false',
          name: 'ImageGenerationService',
        );
        throw Exception('Failed to generate image');
      }
    } on FirebaseFunctionsException catch (e) {
      developer.log(
        'Firebase Functions Error: ${e.message}',
        name: 'ImageGenerationService',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw Exception('Firebase Functions Error: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Error generating image',
        name: 'ImageGenerationService',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error generating image: $e');
    }
  }
}
