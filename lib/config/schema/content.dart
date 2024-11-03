import 'package:laya/enums/content_status.dart';
import 'package:laya/enums/media_type.dart';

class Content {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String seriesId;
  final String categoryId;
  final String thumbnailUrl;
  final String mediaUrl;
  final MediaType mediaType;
  final ContentStatus status;
  final bool isPremium;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Content({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.seriesId,
    required this.categoryId,
    required this.thumbnailUrl,
    required this.mediaUrl,
    this.mediaType = MediaType.none,
    this.status = ContentStatus.draft,
    this.isPremium = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        creatorId: json['creator_id'] as String,
        seriesId: json['series_id'] as String,
        categoryId: json['category_id'] as String,
        thumbnailUrl: json['thumbnail_url'] as String,
        mediaUrl: json['media_url'] as String,
        mediaType: MediaType.values.firstWhere(
          (e) => e.name == (json['media_type'] as String),
          orElse: () => MediaType.none,
        ),
        status: ContentStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String),
          orElse: () => ContentStatus.draft,
        ),
        isPremium: json['is_premium'] as bool? ?? false,
        publishedAt: json['published_at'] != null
            ? DateTime.parse(json['published_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'series_id': seriesId,
        'category_id': categoryId,
        'thumbnail_url': thumbnailUrl,
        'media_url': mediaUrl,
        'media_type': mediaType.name,
        'status': status.name,
        'is_premium': isPremium,
        'published_at': publishedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Content copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? seriesId,
    String? categoryId,
    String? thumbnailUrl,
    String? mediaUrl,
    MediaType? mediaType,
    ContentStatus? status,
    bool? isPremium,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Content(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      seriesId: seriesId ?? this.seriesId,
      categoryId: categoryId ?? this.categoryId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get canPublish =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      thumbnailUrl.isNotEmpty &&
      mediaUrl.isNotEmpty &&
      !mediaType.isNone;

  bool get isEditable => status == ContentStatus.draft;
}
