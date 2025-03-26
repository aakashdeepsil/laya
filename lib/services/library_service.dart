import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laya/models/series_model.dart';

class LibraryService {
  final CollectionReference _libraryCollection =
      FirebaseFirestore.instance.collection('user_library');

  Future<List<Series>> getUserLibrary(String userId) async {
    try {
      // Get user's library entries
      final librarySnapshot = await _libraryCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      // Get all series IDs from library
      final seriesIds = librarySnapshot.docs
          .map((doc) => doc.get('series_id') as String)
          .toList();

      if (seriesIds.isEmpty) return [];

      // Get all series documents
      final seriesCollection = FirebaseFirestore.instance.collection('series');
      final seriesSnapshots = await Future.wait(
        seriesIds.map((id) => seriesCollection.doc(id).get()),
      );

      // Convert to Series objects, filtering out any that don't exist
      return seriesSnapshots
          .where((doc) => doc.exists)
          .map((doc) => Series.fromFirestore(doc))
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
      // Create a unique document ID based on user and series
      final docId = '${userId}_$seriesId';

      await _libraryCollection.doc(docId).set({
        'user_id': userId,
        'series_id': seriesId,
        'created_at': FieldValue.serverTimestamp(),
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
      // Use the same unique document ID format
      final docId = '${userId}_$seriesId';
      await _libraryCollection.doc(docId).delete();
    } catch (e) {
      throw 'Failed to remove from library';
    }
  }

  Future<bool> isSeriesInLibrary({
    required String userId,
    required String seriesId,
  }) async {
    try {
      // Use the same unique document ID format
      final docId = '${userId}_${seriesId}';
      final doc = await _libraryCollection.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check library';
    }
  }
}
