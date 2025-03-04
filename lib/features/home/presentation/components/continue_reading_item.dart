// Build an item for "Continue Reading" category with progress bar
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:laya/features/home/data/models/content_model.dart';

Widget buildContinueReadingItem(ContentItem item, Size screenSize) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GestureDetector(
      onTap: () {
        // Handle item selection
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.coverUrl,
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
                value: (item.progress ?? 0) / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
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
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Author
          const SizedBox(height: 2),
          SizedBox(
            width: 140,
            child: Text(
              item.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
