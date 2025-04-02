import 'package:flutter/material.dart';
import 'package:laya/features/home/data/models/content_model.dart';
import 'package:laya/features/home/presentation/components/content_item.dart';
import 'package:laya/features/home/presentation/components/continue_reading_item.dart';

Widget buildCategorySection(ContentCategory category, Size screenSize) {
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
        height: category.id == "1"
            ? 270
            : 260, // Taller for "Continue Reading" with progress bars
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: category.data.length,
          itemBuilder: (context, index) {
            final item = category.data[index];
            return category.id == "1"
                ? buildContinueReadingItem(item, screenSize)
                : buildContentItem(item, screenSize);
          },
        ),
      ),
    ],
  );
}
