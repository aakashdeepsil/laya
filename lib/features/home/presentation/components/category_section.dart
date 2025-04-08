import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/home/data/models/content_model.dart';
import 'package:laya/features/home/presentation/components/content_item.dart';
import 'package:laya/features/home/presentation/components/continue_reading_item.dart';
import 'package:laya/providers/content_provider.dart';

Widget buildCategorySection(
    ContentCategory category, Size screenSize, BuildContext context) {
  if (category.id == "1") {
    // Continue Reading section
    return Consumer(
      builder: (context, ref, child) {
        final recentProgressAsync = ref.watch(recentReadingProgressProvider);

        return recentProgressAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
          data: (progressList) {
            if (progressList.isEmpty) {
              developer.log('No recent progress', name: 'Continue Reading');
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: progressList.length,
                    itemBuilder: (context, index) {
                      final item = progressList[index];
                      return buildContinueReadingItem(
                        content: item.content,
                        progress: item.progress,
                        screenSize: screenSize,
                        context: context,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Other categories
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          category.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 260,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: category.data.length,
          itemBuilder: (context, index) {
            final item = category.data[index];
            return buildContentItem(item, screenSize);
          },
        ),
      ),
    ],
  );
}
