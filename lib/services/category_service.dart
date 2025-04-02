// Repository for Firebase operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laya/models/category_model.dart';

class CategoryService {
  final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    final snapshot = await _categoriesCollection.orderBy('name').get();

    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  // Get category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    final doc = await _categoriesCollection.doc(categoryId).get();

    if (!doc.exists) return null;
    return Category.fromFirestore(doc);
  }

  // Create a new category
  Future<String> createCategory(Category category) async {
    final docRef = await _categoriesCollection.add(category.toFirestore());
    return docRef.id;
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    await _categoriesCollection.doc(category.id).update(category.toFirestore());
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCollection.doc(categoryId).delete();
  }

  // Increment series count in category
  Future<void> incrementSeriesCount(String categoryId) async {
    await _categoriesCollection.doc(categoryId).update({
      'series_count': FieldValue.increment(1),
    });
  }

  // Decrement series count in category
  Future<void> decrementSeriesCount(String categoryId) async {
    await _categoriesCollection.doc(categoryId).update({
      'series_count': FieldValue.increment(-1),
    });
  }
}
