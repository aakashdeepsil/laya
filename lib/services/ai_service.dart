import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  static GenerativeModel? _model;
  static bool _initialized = false;
  static Future<void>? _initializationFuture;

  factory AIService() {
    developer.log(
      'Getting AIService instance',
      name: 'AIService',
    );
    if (!_initialized && _initializationFuture == null) {
      _initializationFuture = _instance._initialize();
    }
    return _instance;
  }

  AIService._internal();

  Future<void> _initialize() async {
    if (_initialized) return;

    developer.log(
      'Initializing AIService',
      name: 'AIService',
    );

    String? apiKey;
    try {
      apiKey = dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      developer.log(
        'Error accessing environment variables. Make sure .env is loaded.',
        name: 'AIService',
        error: e,
        level: 1000,
      );
      throw Exception(
          'Failed to access environment variables. Is .env loaded?');
    }

    if (apiKey == null || apiKey.isEmpty) {
      developer.log(
        'GEMINI_API_KEY is not configured in .env file',
        name: 'AIService',
        level: 900, // Level.warning
      );
      throw Exception('GEMINI_API_KEY is not configured in .env file');
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-pro-exp-03-25',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 2048,
        ),
      );

      // Test the model with a simple prompt to ensure it's properly initialized
      final testResponse = await _model!.generateContent(
        [Content.text('test')],
      );
      if (testResponse.text == null) {
        throw Exception('Model initialization test failed');
      }

      _initialized = true;
      _initializationFuture = null;

      developer.log(
        'AIService successfully initialized with model: gemini-pro',
        name: 'AIService',
      );
    } catch (e, stackTrace) {
      _initialized = false;
      _model = null;
      _initializationFuture = null;

      developer.log(
        'Error initializing Gemini model',
        name: 'AIService',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Level.error
      );
      rethrow;
    }
  }

  Future<String> generateResponse(String prompt) async {
    try {
      // Wait for initialization if it's in progress
      if (_initializationFuture != null) {
        developer.log(
          'Waiting for AIService initialization to complete',
          name: 'AIService',
        );
        await _initializationFuture;
      }

      if (!_initialized || _model == null) {
        developer.log(
          'Error: AIService not properly initialized',
          name: 'AIService',
          level: 1000, // Level.error
        );
        return 'Error: AI Service not properly initialized';
      }

      developer.log(
        'Generating response for prompt: ${prompt.length} characters',
        name: 'AIService',
      );

      final content = [Content.text(prompt)];
      developer.log(
        'Sending request to Gemini API',
        name: 'AIService',
      );

      final response = await _model!.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        developer.log(
          'Warning: Empty response received from Gemini API',
          name: 'AIService',
          level: 900, // Level.warning
        );
        return 'No response generated';
      }

      developer.log(
        'Response received: ${responseText.length} characters',
        name: 'AIService',
      );

      return responseText;
    } catch (e, stackTrace) {
      developer.log(
        'Error generating response',
        name: 'AIService',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Level.error
      );
      return 'Error generating response: $e';
    }
  }

  Future<Stream<String>> streamResponse(String prompt) async {
    try {
      // Wait for initialization if it's in progress
      if (_initializationFuture != null) {
        developer.log(
          'Waiting for AIService initialization to complete',
          name: 'AIService',
        );
        await _initializationFuture;
      }

      if (!_initialized || _model == null) {
        developer.log(
          'Error: AIService not properly initialized',
          name: 'AIService',
          level: 1000, // Level.error
        );
        return Stream.value('Error: AI Service not properly initialized');
      }

      developer.log(
        'Starting streaming response for prompt: ${prompt.length} characters',
        name: 'AIService',
      );

      final content = [Content.text(prompt)];
      developer.log(
        'Initiating stream from Gemini API',
        name: 'AIService',
      );

      final response = _model!.generateContentStream(content);

      developer.log(
        'Stream connection established',
        name: 'AIService',
      );

      return response.map((chunk) {
        final text = chunk.text ?? '';
        developer.log(
          'Received stream chunk: ${text.length} characters',
          name: 'AIService',
        );
        return text;
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error in stream response',
        name: 'AIService',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // Level.error
      );
      return Stream.value('Error generating response: $e');
    }
  }
}
