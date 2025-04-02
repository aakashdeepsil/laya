import 'package:cloud_firestore/cloud_firestore.dart';

class Series {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String? coverImageUrl;
  final String? thumbnailUrl;
  final List<String> categoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int viewCount;

  const Series({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    this.coverImageUrl,
    this.thumbnailUrl,
    required this.categoryIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
    this.viewCount = 0,
  });

  // Create from Firestore document
  factory Series.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Series(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creator_id'] ?? '',
      coverImageUrl: data['cover_image_url'],
      thumbnailUrl: data['thumbnail_url'],
      categoryIds: List<String>.from(data['category_ids'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      isPublished: data['is_published'] ?? false,
      viewCount: data['view_count'] ?? 0,
    );
  }

  // Create from JSON (for API responses and other sources)
  factory Series.fromJson(Map<String, dynamic> json) => Series(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        creatorId: json['creator_id'] ?? '',
        coverImageUrl: json['cover_image_url'],
        thumbnailUrl: json['thumbnail_url'],
        categoryIds: List<String>.from(json['category_ids'] ?? []),
        createdAt: json['created_at'] != null
            ? (json['created_at'] is Timestamp
                ? (json['created_at'] as Timestamp).toDate()
                : DateTime.parse(json['created_at']))
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? (json['updated_at'] is Timestamp
                ? (json['updated_at'] as Timestamp).toDate()
                : DateTime.parse(json['updated_at']))
            : DateTime.now(),
        isPublished: json['is_published'] ?? false,
        viewCount: json['view_count'] ?? 0,
      );

  // Convert to JSON for Firestore
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'cover_image_url': coverImageUrl,
        'thumbnail_url': thumbnailUrl,
        'category_ids': categoryIds,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
        'is_published': isPublished,
        'view_count': viewCount,
      };

  // Regular JSON conversion (for APIs, localStorage, etc.)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'cover_image_url': coverImageUrl,
        'thumbnail_url': thumbnailUrl,
        'category_ids': categoryIds,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_published': isPublished,
        'view_count': viewCount,
      };

  // Copy with method for immutability
  Series copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? coverImageUrl,
    String? thumbnailUrl,
    List<String>? categoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? viewCount,
  }) {
    return Series(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
