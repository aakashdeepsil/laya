import 'package:laya/config/schema/category.dart';
import 'package:laya/config/supabase_config.dart';

class CategoryRepository {
  Future<List<Category>> getCategories() async {
    final response = await supabase.from('categories').select();

    return (response as List).map((json) => Category.fromJson(json)).toList();
  }
}
