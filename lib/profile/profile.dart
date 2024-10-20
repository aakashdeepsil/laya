import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/components/post.dart';
import 'package:laya/profile/profile_header.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfilePage extends StatefulWidget {
  final String userID;

  const ProfilePage({super.key, required this.userID});

  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Get the screen width and height
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Fetching posts state
  bool _isFetchingPosts = false;

  // Loading state
  bool _loading = false;

  // Posts data
  List posts = [];

  // Profile data
  Map<String, dynamic> profile = {};

  // Comments and likes data
  List<int> commentsCount = [];
  List<int> likesCount = [];

  List<String> anime = [
    'https://qph.cf2.quoracdn.net/main-qimg-5abcf39750a6e0f1074f1249b66d6445',
    'https://wallpapercave.com/wp/wp10508780.jpg',
    'https://mlpnk72yciwc.i.optimole.com/cqhiHLc.IIZS~2ef73/w:auto/h:auto/q:75/https://bleedingcool.com/wp-content/uploads/2020/10/ChainsawMan_GN01_C1_Web-copy.jpg',
    'https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',
  ];

  Future<void> _getProfile() async {
    setState(() => _loading = true);
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.userID)
          .single();
      setState(() => profile = data);
      _fetchPosts();
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchPosts() async {
    setState(() => _isFetchingPosts = true);
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      setState(() => posts = data.reversed.toList());

      for (var post in posts) {
        final comments = await Supabase.instance.client
            .from('comments')
            .select()
            .eq('post_id', post['id']);
        final likes = await Supabase.instance.client
            .from('likes')
            .select()
            .eq('post_id', post['id']);

        commentsCount.add(comments.length);
        likesCount.add(likes.length);
      }
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() => _isFetchingPosts = false);
    }
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void showAddPostModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(LucideIcons.stickyNote, size: screenHeight * 0.03),
              title: Text(
                'Add new social post',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () => context.go('/create_post'),
            ),
            ListTile(
              leading: Icon(Icons.library_books, size: screenHeight * 0.03),
              title: Text(
                'Add new content',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.05),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            profile['username'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.post_add, size: screenHeight * 0.03),
              onPressed: showAddPostModal,
            ),
            IconButton(
              onPressed: () => context.push("/profile_settings"),
              icon: Icon(Icons.menu, size: screenHeight * 0.03),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [ProfileHeader(profile: profile)],
                      ),
                    ),
                  ];
                },
                body: Column(
                  children: [
                    TabBar(
                      unselectedLabelColor: Colors.grey[400],
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 1,
                      tabs: const [
                        Tab(icon: Icon(LucideIcons.grid)),
                        Tab(icon: Icon(LucideIcons.activity)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _isFetchingPosts
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        context.push(
                                          '/post_details/${posts[index]['id']}',
                                          extra: {
                                            'avatarUrl': profile['avatar_url'],
                                            'postItem': posts[index],
                                            'username': profile['username'],
                                          },
                                        );
                                      },
                                      child: Post(
                                        avatarUrl: profile['avatar_url'],
                                        postItem: posts[index],
                                        username: profile['username'],
                                      ),
                                    );
                                  },
                                ),
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2.5,
                              mainAxisSpacing: 2.5,
                            ),
                            itemCount: anime.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                anime[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const MyBottomNavigationBar(index: 4),
    );
  }
}
