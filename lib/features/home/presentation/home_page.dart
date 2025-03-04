import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/home/presentation/components/category_section.dart';
import 'package:laya/features/home/presentation/components/hero_banner.dart';
import 'package:laya/features/home/presentation/components/navigation_drawer.dart';
import 'package:laya/features/home/presentation/providers/home_providers.dart';
import 'package:laya/providers/auth_provider.dart';
import 'dart:developer' as developer;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    developer.log('HomePage initialized', name: 'HomePage');
    _scrollController.addListener(_onScroll);

    // Simulate loading for demo purposes
    developer.log('Starting simulated loading delay', name: 'HomePage');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        developer.log(
          'Simulated loading complete, updating state',
          name: 'HomePage',
        );
        ref.read(loadingProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    developer.log('Disposing HomePage', name: 'HomePage');
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    ref.read(scrollOffsetProvider.notifier).state = offset;
    // Log scroll position at intervals to avoid excessive logging
    if (offset % 100 < 1) {
      developer.log(
        'Scrolled to position: ${offset.toStringAsFixed(1)}',
        name: 'HomePage',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building HomePage UI', name: 'HomePage');
    final screenSize = MediaQuery.of(context).size;
    final featuredBook = ref.watch(featuredBookProvider);
    final contentCategories = ref.watch(contentCategoriesProvider);
    final scrollOffset = ref.watch(scrollOffsetProvider);
    final isLoading = ref.watch(loadingProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    developer.log(
      'UI build with: scrollOffset=$scrollOffset, isLoading=$isLoading, user=${user?.id ?? "guest"}',
      name: 'HomePage',
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: navigationDrawer(context, user, ref),
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero banner
              SliverToBoxAdapter(
                child: buildHeroBanner(featuredBook, screenSize),
              ),

              // Content categories
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    developer.log(
                      'Building category section: ${contentCategories[index].title}',
                      name: 'HomePage',
                    );
                    final category = contentCategories[index];
                    return buildCategorySection(category, screenSize);
                  },
                  childCount: contentCategories.length,
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),

          // Animated header that appears on scroll
          AnimatedOpacity(
            opacity: scrollOffset > 100 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 70 + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: const Color(0xFF0f172a).withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      developer.log(
                        'Hamburger menu tapped (header)',
                        name: 'HomePage',
                      );
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const Text(
                    'LAYA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      developer.log('Search icon tapped', name: 'HomePage');
                      // Handle search action
                    },
                  ),
                ],
              ),
            ),
          ),

          // Always visible hamburger menu (when scrollOffset <= 100)
          if (scrollOffset <= 100)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  developer.log(
                    'Hamburger menu tapped (floating)',
                    name: 'HomePage',
                  );
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),

          // Loading indicator
          if (isLoading)
            Container(
              color: const Color(0xFF0f172a),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFe50914),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
