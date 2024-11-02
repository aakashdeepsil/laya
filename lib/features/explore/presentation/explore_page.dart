import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/profile/data/user_repository.dart';
import 'package:laya/features/content/data/series_repository.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';

class ExplorePage extends StatefulWidget {
  final User user;

  const ExplorePage({super.key, required this.user});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final TextEditingController _searchController = TextEditingController();
  final SeriesRepository _seriesRepository = SeriesRepository();
  final UserRepository _userRepository = UserRepository();

  late TabController _tabController;
  bool _isLoading = false;
  List<Series> _series = [];
  List<User> _users = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);
      final series = await _seriesRepository.getRecentlyAddedSeries();
      setState(() => _series = series);
    } catch (e) {
      _showError('Failed to load data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _loadInitialData();
      return;
    }

    try {
      setState(() => _isLoading = true);

      if (_tabController.index == 0) {
        final results = await _seriesRepository.searchSeries(query);
        setState(() => _series = results);
      } else {
        final results = await _userRepository.searchUsers(query);
        setState(() => _users = results);
      }
    } catch (e) {
      _showError('Search failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: screenHeight * 0.02)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Explore',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search series or users...',
                        prefixIcon: Icon(
                          Icons.search,
                          size: screenHeight * 0.03,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenHeight * 0.02,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => _performSearch(_searchController.text),
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Series'),
                  Tab(text: 'Users'),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSeriesGrid(),
                        _buildUsersList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 1,
        user: widget.user,
      ),
    );
  }

  Widget _buildSeriesGrid() {
    if (_series.isEmpty) {
      return _buildEmptyState('No series found');
    }

    return GridView.builder(
      padding: EdgeInsets.all(screenHeight * 0.02),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _series.length,
      itemBuilder: (context, index) {
        final series = _series[index];
        return GestureDetector(
          onTap: () => context.push(
            '/series_details_page',
            extra: {
              'series': series,
              'user': widget.user,
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(series.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    if (_users.isEmpty) {
      return _buildEmptyState('No users found');
    }

    return ListView.separated(
      padding: EdgeInsets.all(screenHeight * 0.02),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          onTap: () => context.push(
            '/user_profile_page',
            extra: {
              'currentUser': widget.user,
              'user': user,
            },
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user.avatarUrl),
            child: Text(
              user.username[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: screenHeight * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(user.username),
          subtitle: Text(
            user.bio,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: screenHeight * 0.1,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
