import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laya/features/home/data/models/content_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/services/series_service.dart';

final activeTabProvider = StateProvider<String>((ref) => "Home");

final scrollOffsetProvider = StateProvider<double>((ref) => 0);

final loadingProvider = StateProvider<bool>((ref) => true);

final featuredSeriesProvider = FutureProvider<Series?>((ref) async {
  final seriesService = SeriesService();
  // Get the first featured series that is also published
  final snapshot = await FirebaseFirestore.instance
      .collection('series')
      .where('is_featured', isEqualTo: true)
      .where('is_published', isEqualTo: true)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return null;
  return Series.fromFirestore(snapshot.docs.first);
});

final contentCategoriesProvider = Provider<List<ContentCategory>>((ref) {
  // This would typically come from a repository
  return [
    ContentCategory(id: "1", title: "Continue Reading", data: [
      ContentItem(
          id: "1-1",
          title: "The Wind's Promise",
          author: "Haruki Tanaka",
          progress: 68,
          coverUrl:
              "https://api.a0.dev/assets/image?text=illustrated%20book%20cover%20with%20wind%20and%20cherry%20blossoms&aspect=9:16&seed=101"),
      ContentItem(
          id: "1-2",
          title: "Eternal Moon",
          author: "Yua Nakamura",
          progress: 42,
          coverUrl:
              "https://api.a0.dev/assets/image?text=manga%20style%20book%20cover%20with%20moon%20and%20silhouette&aspect=9:16&seed=102"),
      ContentItem(
          id: "1-3",
          title: "Electric Dreams",
          author: "Rei Kimura",
          progress: 17,
          coverUrl:
              "https://api.a0.dev/assets/image?text=cyberpunk%20book%20cover%20with%20neon%20colors&aspect=9:16&seed=103"),
      ContentItem(
          id: "1-4",
          title: "Sakura's Journey",
          author: "Hina Suzuki",
          progress: 89,
          coverUrl:
              "https://api.a0.dev/assets/image?text=manga%20cover%20with%20cherry%20blossom%20and%20journey&aspect=9:16&seed=104"),
    ]),
    ContentCategory(id: "2", title: "Popular Manga Series", data: [
      ContentItem(
          id: "2-1",
          title: "Blade of Destiny",
          author: "Takeshi Mori",
          coverUrl:
              "https://api.a0.dev/assets/image?text=action%20manga%20cover%20with%20samurai%20and%20sword&aspect=9:16&seed=201"),
      ContentItem(
          id: "2-2",
          title: "Tokyo Nights",
          author: "Akira Yamaguchi",
          coverUrl:
              "https://api.a0.dev/assets/image?text=noir%20manga%20cover%20with%20tokyo%20cityscape%20at%20night&aspect=9:16&seed=202"),
      ContentItem(
          id: "2-3",
          title: "Spirit Hunter",
          author: "Yuki Tanaka",
          coverUrl:
              "https://api.a0.dev/assets/image?text=supernatural%20manga%20cover%20with%20ghost%20hunter&aspect=9:16&seed=203"),
      ContentItem(
          id: "2-4",
          title: "Academy of Magic",
          author: "Mei Kobayashi",
          coverUrl:
              "https://api.a0.dev/assets/image?text=magical%20school%20manga%20cover%20with%20students&aspect=9:16&seed=204"),
    ]),
    ContentCategory(id: "3", title: "New Releases", data: [
      ContentItem(
          id: "3-1",
          title: "The Last Oracle",
          author: "Hiroshi Yamada",
          coverUrl:
              "https://api.a0.dev/assets/image?text=fantasy%20book%20cover%20with%20prophet%20and%20ancient%20symbols&aspect=9:16&seed=301"),
      ContentItem(
          id: "3-2",
          title: "Quantum Heart",
          author: "Sakura Ito",
          coverUrl:
              "https://api.a0.dev/assets/image?text=sci-fi%20romance%20book%20cover%20with%20futuristic%20heart&aspect=9:16&seed=302"),
      ContentItem(
          id: "3-3",
          title: "Shadows of Kyoto",
          author: "Ryu Nakamura",
          coverUrl:
              "https://api.a0.dev/assets/image?text=historical%20mystery%20book%20cover%20set%20in%20ancient%20kyoto&aspect=9:16&seed=303"),
      ContentItem(
          id: "3-4",
          title: "Digital Dreamers",
          author: "Emi Sato",
          coverUrl:
              "https://api.a0.dev/assets/image?text=cyberpunk%20book%20cover%20with%20virtual%20reality%20theme&aspect=9:16&seed=304"),
    ]),
    ContentCategory(id: "4", title: "Recommended For You", data: [
      ContentItem(
          id: "4-1",
          title: "Garden of Memories",
          author: "Hana Takahashi",
          coverUrl:
              "https://api.a0.dev/assets/image?text=slice%20of%20life%20book%20cover%20with%20garden%20and%20memories&aspect=9:16&seed=401"),
      ContentItem(
          id: "4-2",
          title: "Midnight Detective",
          author: "Kenji Watanabe",
          coverUrl:
              "https://api.a0.dev/assets/image?text=noir%20detective%20book%20cover%20with%20silhouette%20at%20night&aspect=9:16&seed=402"),
      ContentItem(
          id: "4-3",
          title: "Ocean's Whisper",
          author: "Aoi Miyazaki",
          coverUrl:
              "https://api.a0.dev/assets/image?text=fantasy%20book%20cover%20with%20ocean%20and%20mermaids&aspect=9:16&seed=403"),
      ContentItem(
          id: "4-4",
          title: "The Time Capsule",
          author: "Naoki Kimura",
          coverUrl:
              "https://api.a0.dev/assets/image?text=coming%20of%20age%20book%20cover%20with%20time%20capsule&aspect=9:16&seed=404"),
    ]),
  ];
});
