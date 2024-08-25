import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/post.dart';
import 'package:laya/profile/profile_header.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = true;
  bool _isFetchingPosts = false;

  List posts = [];

  String avatarUrl = '';
  String bio = '';
  String firstName = '';
  String lastName = '';
  String username = '';

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentSession!.user.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      avatarUrl = (data['avatar_url'] ?? '') as String;
      bio = (data['bio'] ?? '') as String;
      firstName = (data['first_name'] ?? '') as String;
      lastName = (data['last_name'] ?? '') as String;
      username = (data['username'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) {
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBar(
          content: const Text('Unexpected error occurred. Try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _fetchPosts();
      }
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isFetchingPosts = true;
    });

    try {
      final userEmail =
          Supabase.instance.client.auth.currentSession?.user.email;

      if (userEmail == null) {
        throw Exception('User email not found');
      }

      final data = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('email', userEmail);

      setState(() {
        posts = data;
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unexpected error occurred. Try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingPosts = false;
        });
      }
    }
  }

  @override
  void initState() {
    _getProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> kDemoImages = [
    'https://i.pinimg.com/originals/7f/91/a1/7f91a18bcfbc35570c82063da8575be8.jpg',
    'https://www.absolutearts.com/portfolio3/a/afifaridasiddique/Still_Life-1545967888l.jpg',
    'https://cdn11.bigcommerce.com/s-x49po/images/stencil/1280x1280/products/53415/72138/1597120261997_IMG_20200811_095922__49127.1597493165.jpg?c=2',
    'https://i.pinimg.com/originals/47/7e/15/477e155db1f8f981c4abb6b2f0092836.jpg',
    'https://images.saatchiart.com/saatchi/770124/art/3760260/2830144-QFPTZRUH-7.jpg',
    'https://images.unsplash.com/photo-1471943311424-646960669fbc?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c3RpbGwlMjBsaWZlfGVufDB8fDB8&ixlib=rb-1.2.1&w=1000&q=80',
    'https://cdn11.bigcommerce.com/s-x49po/images/stencil/1280x1280/products/40895/55777/1526876829723_P211_24X36__2018_Stilllife_15000_20090__91926.1563511650.jpg?c=2',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIUsxpakPiqVF4W_rOlq6eoLYboOFoxw45qw&usqp=CAU',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.05),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.post_add, size: screenHeight * 0.03),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: Icon(
                            LucideIcons.stickyNote,
                            size: screenHeight * 0.03,
                          ),
                          title: Text(
                            'Add new social post',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                          onTap: () {
                            context.go('/create_post');
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.library_books,
                            size: screenHeight * 0.03,
                          ),
                          title: Text(
                            'Add new content',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                          onTap: () {
                            // context.go('/post_video');
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              onPressed: () => context.go("/profile_settings"),
              icon: Icon(Icons.menu, size: screenHeight * 0.03),
            )
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
                          [
                            ProfileHeader(
                              firstName: firstName,
                              lastName: lastName,
                              username: username,
                              bio: bio,
                              avatarUrl: avatarUrl,
                            ),
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
                            _isFetchingPosts
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      return Post(postItem: posts[index]);
                                    },
                                  ),
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2.5,
                                mainAxisSpacing: 2.5,
                              ),
                              itemCount: kDemoImages.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  kDemoImages[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
      bottomNavigationBar: const MyBottomNavigationBar(index: 4),
    );
  }
}
