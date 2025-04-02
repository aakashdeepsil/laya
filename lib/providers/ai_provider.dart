import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/services/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  developer.log(
    'Creating AIService provider',
    name: 'AIProvider',
  );
  return AIService();
});

final aiResponseProvider = StateProvider<String>((ref) => '');

final isLoadingProvider = StateProvider<bool>((ref) => false);

final aiHistoryProvider = StateProvider<List<Map<String, String>>>((ref) => []);

final promptControllerProvider = StateProvider.autoDispose<String>((ref) => '');

final aiInitializationProvider = FutureProvider<void>((ref) async {
  developer.log(
    'Initializing AI service through provider',
    name: 'AIProvider',
  );

  final aiService = ref.watch(aiServiceProvider);
  // This will trigger the initialization
  await aiService.generateResponse('');
});
