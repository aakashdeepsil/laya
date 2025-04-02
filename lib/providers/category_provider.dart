import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/category_model.dart';
import 'package:laya/services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryServiceProvider);
  return repository.getAllCategories();
});

final categoryProvider =
    FutureProvider.family<Category?, String>((ref, categoryId) {
  final repository = ref.watch(categoryServiceProvider);
  return repository.getCategoryById(categoryId);
});
