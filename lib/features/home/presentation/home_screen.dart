import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/home/presentation/components/category_section.dart';
import 'package:laya/features/home/presentation/components/hero_banner.dart';
import 'package:laya/features/home/presentation/components/navigation_drawer.dart';
import 'package:laya/providers/home_provider.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    developer.log('HomeScreen initialized', name: 'HomeScreen');
    _scrollController.addListener(_onScroll);

    // Simulate loading for demo purposes
    developer.log('Starting simulated loading delay', name: 'HomeScreen');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        developer.log(
          'Simulated loading complete, updating state',
          name: 'HomeScreen',
        );
        ref.read(loadingProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    developer.log('Disposing HomeScreen', name: 'HomeScreen');
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
        name: 'HomeScreen',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building HomeScreen UI', name: 'HomeScreen');
    final screenSize = MediaQuery.of(context).size;
    final featuredSeriesAsync = ref.watch(featuredSeriesProvider);
    final contentCategories = ref.watch(contentCategoriesProvider);
    final scrollOffset = ref.watch(scrollOffsetProvider);
    final isLoading = ref.watch(loadingProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    developer.log(
      'UI build with: scrollOffset=$scrollOffset, isLoading=$isLoading, user=${user?.id ?? "guest"}',
      name: 'HomeScreen',
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
                child: featuredSeriesAsync.when(
                  data: (series) => heroBanner(series, screenSize, context),
                  loading: () => Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[700]!,
                    child: Container(
                      height: screenSize.height * 0.7,
                      color: Colors.white,
                    ),
                  ),
                  error: (error, stackTrace) => Container(
                    height: screenSize.height * 0.7,
                    color: const Color(0xFF1e293b),
                    child: Center(
                      child: Text(
                        'Error loading featured content: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // Content categories
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    developer.log(
                      'Building category section: ${contentCategories[index].title}',
                      name: 'HomeScreen',
                    );
                    final category = contentCategories[index];
                    return buildCategorySection(category, screenSize, context);
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
                color: const Color(0xFF0f172a).withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                        name: 'HomeScreen',
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
                      developer.log('Search icon tapped', name: 'HomeScreen');
                      context.push('/search');
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
                    name: 'HomeScreen',
                  );
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ),

          // Loading indicator
          if (isLoading)
            Container(
              color: const Color(0xFF0f172a),
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  // Shimmer for hero banner
                  SliverToBoxAdapter(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        height: screenSize.width * 9 / 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Shimmer for categories
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category title shimmer
                              Shimmer.fromColors(
                                baseColor: Colors.grey[800]!,
                                highlightColor: Colors.grey[700]!,
                                child: Container(
                                  width: 150,
                                  height: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Category items shimmer
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  itemBuilder: (context, itemIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[800]!,
                                        highlightColor: Colors.grey[700]!,
                                        child: Container(
                                          width: 140,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: 3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
