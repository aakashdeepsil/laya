// Build an item for "Continue Reading" category with progress bar
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/content_model.dart';

Widget buildContinueReadingItem({
  required Content content,
  required double progress,
  required Size screenSize,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GestureDetector(
      onTap: () {
        // Navigate to reader screen
        context.push('/reader', extra: {'content': content});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: content.thumbnailUrl ?? '',
              height: 210,
              width: 140,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF1e293b),
                height: 210,
                width: 140,
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF1e293b),
                height: 210,
                width: 140,
                child: const Icon(Icons.error),
              ),
            ),
          ),

          // Progress bar
          const SizedBox(height: 4),
          SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: const Color(0xFFe50914),
                minHeight: 3,
              ),
            ),
          ),

          // Title
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: Text(
              content.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Progress percentage
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ),
  );
}
