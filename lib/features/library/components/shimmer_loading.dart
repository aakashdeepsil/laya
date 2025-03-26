import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant.withOpacity(0.3),
      highlightColor: colorScheme.surfaceVariant.withOpacity(0.1),
      child: child,
    );
  }
}
