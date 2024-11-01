import 'package:laya/config/schema/series.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryRepository {
  Future<List<Series>> getUserLibrary(String userId) async {
    try {
      final response = await supabase
          .from('user_library')
          .select('series_id, series!inner(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Series.fromJson(item['series']))
          .toList();
    } catch (e) {
      throw 'Failed to load library';
    }
  }

  Future<void> addToLibrary({
    required String userId,
    required String seriesId,
  }) async {
    try {
      await supabase.from('user_library').upsert({
        'user_id': userId,
        'series_id': seriesId,
      });
    } catch (e) {
      throw 'Failed to add to library';
    }
  }

  Future<void> removeFromLibrary({
    required String userId,
    required String seriesId,
  }) async {
    try {
      await supabase
          .from('user_library')
          .delete()
          .eq('user_id', userId)
          .eq('series_id', seriesId);
    } catch (e) {
      throw 'Failed to remove from library';
    }
  }

  Future<bool> isSeriesInLibrary({
    required String userId,
    required String seriesId,
  }) async {
    try {
      final response = await supabase
          .from('user_library')
          .select()
          .eq('user_id', userId)
          .eq('series_id', seriesId)
          .single();

      return response.isNotEmpty;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return false;
      }
      throw 'Failed to check library';
    } catch (e) {
      throw 'Failed to check library';
    }
  }
}
