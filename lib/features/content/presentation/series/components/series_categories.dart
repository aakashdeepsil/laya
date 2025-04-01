import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/providers/category_provider.dart';

class SeriesCategories extends ConsumerWidget {
  final List<String> categoryIds;

  const SeriesCategories({
    super.key,
    required this.categoryIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    if (categoryIds.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryIds.map((categoryId) {
          final category = ref.watch(categoryProvider(categoryId));
          return category.when(
            data: (category) => Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category?.name ?? 'Unnamed Category',
                  style: TextStyle(
                    fontSize: screenHeight * 0.014,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        }).toList(),
      ),
    );
  }
}
