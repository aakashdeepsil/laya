import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/profile/profile_header.dart';
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
              onPressed: () {},
              icon: const Icon(Icons.add_box_outlined),
            ),
            IconButton(
              onPressed: () => context.go("/profile_settings"),
              icon: const Icon(Icons.menu),
            )
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 1,
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
                          // Tab(text: "Content"),
                          Tab(text: "Posts"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ListView.builder(
                            //   itemCount: 10,
                            //   itemBuilder: (context, index) {
                            //     return ListTile(
                            //       title: Text("Post $index"),
                            //     );
                            //   },
                            // ),
                            ListView.builder(
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text("Post $index"),
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
