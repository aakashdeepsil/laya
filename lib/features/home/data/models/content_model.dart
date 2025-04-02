class ContentItem {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final int? progress;

  ContentItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.progress,
  });
}

class ContentCategory {
  final String id;
  final String title;
  final List<ContentItem> data;

  ContentCategory({
    required this.id,
    required this.title,
    required this.data,
  });
}

class FeaturedBook {
  final String title;
  final String author;
  final String description;
  final String coverImage;
  final List<String> tags;

  FeaturedBook({
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.tags,
  });
}
