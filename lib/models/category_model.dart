import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final int seriesCount;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.seriesCount = 0,
  });

  // Create from Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      iconName: data['icon_name'],
      seriesCount: data['series_count'] ?? 0,
    );
  }

  // Create from JSON (for API responses)
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        iconName: json['icon_name'] as String?,
        seriesCount: json['series_count'] as int? ?? 0,
      );

  // Convert to JSON for Firestore
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'description': description,
        'icon_name': iconName,
        'series_count': seriesCount,
      };

  // Regular JSON conversion
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon_name': iconName,
        'series_count': seriesCount,
      };

  // Copy with method for immutability
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    DateTime? createdAt,
    int? seriesCount,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      seriesCount: seriesCount ?? this.seriesCount,
    );
  }
}
