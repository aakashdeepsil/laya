class Series {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String coverImageUrl;
  final String thumbnailUrl;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Series({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.coverImageUrl,
    required this.thumbnailUrl,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        creatorId: json['creator_id'],
        coverImageUrl: json['cover_image_url'],
        thumbnailUrl: json['thumbnail_url'],
        categoryId: json['category_id'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'cover_image_url': coverImageUrl,
        'thumbnail_url': thumbnailUrl,
        'category_id': categoryId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
