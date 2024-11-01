import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/library/data/library_repository.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';

class LibraryPage extends StatefulWidget {
  final User user;

  const LibraryPage({super.key, required this.user});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final LibraryRepository _libraryRepository = LibraryRepository();

  bool _isLoading = false;
  List<Series> _librarySeries = [];

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      setState(() => _isLoading = true);
      final series = await _libraryRepository.getUserLibrary(widget.user.id);
      setState(() => _librarySeries = series);
    } catch (e) {
      _showError('Failed to load library');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(message, style: TextStyle(fontSize: screenHeight * 0.02)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Library',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _librarySeries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books,
                          size: screenHeight * 0.1,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Your library is empty',
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextButton(
                          onPressed: () => context.go(
                            '/explore',
                            extra: widget.user,
                          ),
                          child: Text(
                            'Explore Series',
                            style: TextStyle(fontSize: screenHeight * 0.02),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLibrary,
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _librarySeries.length,
                        itemBuilder: (context, index) {
                          final series = _librarySeries[index];
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
                                        image: NetworkImage(
                                          series.thumbnailUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 3,
        user: widget.user,
      ),
    );
  }
}
