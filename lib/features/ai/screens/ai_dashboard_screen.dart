import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:laya/providers/ai_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AIDashboardScreen extends ConsumerStatefulWidget {
  const AIDashboardScreen({super.key});

  @override
  ConsumerState<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends ConsumerState<AIDashboardScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    developer.log(
      'Initializing AI Dashboard Screen',
      name: 'AIDashboard',
    );
  }

  @override
  void dispose() {
    developer.log(
      'Disposing AI Dashboard Screen',
      name: 'AIDashboard',
    );
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_promptController.text.trim().isEmpty) {
      developer.log(
        'Empty prompt submission prevented',
        name: 'AIDashboard',
      );
      return;
    }

    if (!mounted) return;

    final prompt = _promptController.text;
    developer.log(
      'Submitting prompt: $prompt',
      name: 'AIDashboard',
    );

    _promptController.clear();

    if (!mounted) return;
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(aiHistoryProvider.notifier).update((state) => [
          ...state,
          {'role': 'user', 'content': prompt}
        ]);

    try {
      developer.log(
        'Generating AI response for prompt',
        name: 'AIDashboard',
      );

      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.generateResponse(prompt);

      if (!mounted) return;

      developer.log(
        'AI response received: ${response.length} characters',
        name: 'AIDashboard',
      );

      ref.read(aiHistoryProvider.notifier).update((state) => [
            ...state,
            {'role': 'assistant', 'content': response}
          ]);

      _scrollToBottom();
    } catch (e, stackTrace) {
      developer.log(
        'Error generating AI response',
        name: 'AIDashboard',
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
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _scrollToBottom() {
    developer.log(
      'Scrolling chat to bottom',
      name: 'AIDashboard',
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearHistory() {
    developer.log(
      'Clearing chat history',
      name: 'AIDashboard',
    );
    ref.read(aiHistoryProvider.notifier).state = [];
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Building AI Dashboard UI',
      name: 'AIDashboard',
    );

    final history = ref.watch(aiHistoryProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final initializationState = ref.watch(aiInitializationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Assistant',
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
      body: initializationState.when(
        data: (_) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final message = history[index];
                  final isUser = message['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message['content'] ?? '',
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ).animate().fadeIn().slideX(
                          begin: isUser ? 1 : -1,
                          duration: const Duration(milliseconds: 300),
                        ),
                  );
                },
              ),
            ),
            if (isLoading)
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _handleSubmit,
                    icon: const Icon(
                      LucideIcons.send,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing AI...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize AI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(aiInitializationProvider);
                  },
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
