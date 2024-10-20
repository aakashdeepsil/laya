import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/config/schema/posts.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/features/profile/presentation/post_widget.dart';
import 'package:laya/features/profile/presentation/profile_header.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = false;
  List<Post> posts = [];
  List<int> commentsCount = [];
  List<int> likesCount = [];

  List<String> anime = [
    'https://qph.cf2.quoracdn.net/main-qimg-5abcf39750a6e0f1074f1249b66d6445',
    'https://wallpapercave.com/wp/wp10508780.jpg',
    'https://mlpnk72yciwc.i.optimole.com/cqhiHLc.IIZS~2ef73/w:auto/h:auto/q:75/https://bleedingcool.com/wp-content/uploads/2020/10/ChainsawMan_GN01_C1_Web-copy.jpg',
    'https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    setState(() => _loading = true);

    try {
      final response = await supabase
          .from('posts')
          .select()
          .eq('user_id', widget.profile.id)
          .order('created_at', ascending: false);

      setState(
        () => posts = (response).map((post) => Post.fromMap(post)).toList(),
      );
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      setState(() => _loading = false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.05),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            widget.profile.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.post_add, size: screenHeight * 0.03),
              onPressed: showAddPostModal,
            ),
            IconButton(
              onPressed: () => context.push(
                "/profile_settings_page",
                extra: widget.profile,
              ),
              icon: Icon(Icons.menu, size: screenHeight * 0.03),
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    ProfileHeader(profile: widget.profile),
                  ],
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
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return PostWidget(
                                avatarUrl: widget.profile.avatarUrl,
                                post: post,
                                username: widget.profile.username,
                              );
                            },
                          ),
                    ListView.builder(
                      itemCount: anime.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Anime $index'),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(anime[index]),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 4,
        profile: widget.profile,
      ),
    );
  }
}
