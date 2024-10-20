import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  List<Map<String, dynamic>> results = [];

  // Search for users based on a keyword
  void searchUsers(String keyword) async {
    final response = await Supabase.instance.client.from('profiles').select();
    print(response);
    if (response.isNotEmpty) {
      setState(() => results = response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.025),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Explore',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => searchUsers(value),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () =>
                          context.push('/profile/${results[index]['id']}'),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            results[index]['avatar_url'],
                          ),
                        ),
                        title: Text(
                          '@${results[index]['username']}',
                          style: TextStyle(fontSize: screenHeight * 0.017),
                        ),
                        subtitle: Text(
                          '${results[index]['first_name']} ${results[index]['last_name']}',
                          style: TextStyle(fontSize: screenHeight * 0.015),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
