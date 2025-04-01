import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadingPreferencesScreen extends StatefulWidget {
  const ReadingPreferencesScreen({super.key});

  @override
  State<ReadingPreferencesScreen> createState() =>
      _ReadingPreferencesScreenState();
}

class _ReadingPreferencesScreenState extends State<ReadingPreferencesScreen>
    with SingleTickerProviderStateMixin {
  final List<int> _selectedGenres = [];
  String _readingStyle = 'both';
  String _primaryLanguage = 'en';
  final List<String> _secondaryLanguages = [];
  int _step = 1;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<Map<String, dynamic>> _genres = [
    {
      'id': 1,
      'name': 'Fantasy',
      'icon': '🐉',
      'image':
          'https://api.a0.dev/assets/image?text=magical%20fantasy%20world%20with%20dragons&aspect=1:1'
    },
    {
      'id': 2,
      'name': 'Sci-Fi',
      'icon': '🚀',
      'image':
          'https://api.a0.dev/assets/image?text=futuristic%20sci-fi%20space%20scene&aspect=1:1'
    },
    {
      'id': 3,
      'name': 'Romance',
      'icon': '💕',
      'image':
          'https://api.a0.dev/assets/image?text=romantic%20sunset%20scene&aspect=1:1'
    },
    {
      'id': 4,
      'name': 'Mystery',
      'icon': '🔍',
      'image':
          'https://api.a0.dev/assets/image?text=mysterious%20noir%20detective%20scene&aspect=1:1'
    },
    {
      'id': 5,
      'name': 'Horror',
      'icon': '👻',
      'image':
          'https://api.a0.dev/assets/image?text=dark%20spooky%20haunted%20house&aspect=1:1'
    },
    {
      'id': 6,
      'name': 'Action',
      'icon': '💥',
      'image':
          'https://api.a0.dev/assets/image?text=epic%20action%20scene%20with%20explosions&aspect=1:1'
    },
  ];

  final List<Map<String, dynamic>> _readingStyles = [
    {'id': 'books', 'name': 'Books', 'icon': Icons.menu_book_outlined},
    {'id': 'manga', 'name': 'Manga', 'icon': Icons.book_outlined},
    {'id': 'both', 'name': 'Both', 'icon': Icons.library_books_outlined},
  ];

  final List<Map<String, dynamic>> _languages = [
    {'id': 'en', 'name': 'English'},
    {'id': 'es', 'name': 'Spanish'},
    {'id': 'fr', 'name': 'French'},
    {'id': 'de', 'name': 'German'},
    {'id': 'ja', 'name': 'Japanese'},
    {'id': 'ko', 'name': 'Korean'},
  ];

  @override
  void initState() {
    super.initState();

    // Set up the status bar to be transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animation controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.25,
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _animateProgress(int newStep) {
    _progressController.animateTo(newStep * 0.25);
  }

  void _handleGenreSelect(int genreId) {
    setState(() {
      if (_selectedGenres.contains(genreId)) {
        _selectedGenres.remove(genreId);
      } else {
        _selectedGenres.add(genreId);
      }
    });
  }

  void _handleLanguageSelect(String langId) {
    if (langId == _primaryLanguage) return;

    setState(() {
      if (_secondaryLanguages.contains(langId)) {
        _secondaryLanguages.remove(langId);
      } else {
        _secondaryLanguages.add(langId);
      }
    });
  }

  void _handleNext() {
    if (_step < 4) {
      setState(() {
        _step += 1;
      });
      _animateProgress(_step);
    } else {
      // Handle completion
      debugPrint('Preferences saved');
    }
  }

  void _handleBack() {
    if (_step > 1) {
      setState(() {
        _step -= 1;
      });
      _animateProgress(_step);
    }
  }

  Widget _renderStep() {
    switch (_step) {
      case 1:
        return _buildGenresStep();
      case 2:
        return _buildReadingStyleStep();
      case 3:
        return _buildLanguageStep();
      case 4:
        return _buildSummaryStep();
      default:
        return Container();
    }
  }

  Widget _buildGenresStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pick your favorite genres',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select at least 3 genres to help us personalize your experience',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _genres.length,
          itemBuilder: (context, index) {
            final genre = _genres[index];
            final isSelected = _selectedGenres.contains(genre['id']);

            return GestureDetector(
              onTap: () => _handleGenreSelect(genre['id']),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF818CF8), width: 2)
                      : null,
                  color: const Color(0xFF27272A),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      genre['image'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF818CF8),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        '${genre['icon']} ${genre['name']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReadingStyleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How do you like to read?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your preferred reading style',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: _readingStyles.map((style) {
            final isSelected = _readingStyle == style['id'];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _readingStyle = style['id'];
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF818CF8), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            style['icon'],
                            size: 32,
                            color: isSelected
                                ? const Color(0xFF818CF8)
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            style['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF818CF8)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language preferences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select your primary reading language and any additional languages',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Primary Language',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _languages.map((lang) {
              final isSelected = _primaryLanguage == lang['id'];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _primaryLanguage = lang['id'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lang['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Additional Languages (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _languages
                .where((lang) => lang['id'] != _primaryLanguage)
                .map((lang) {
              final isSelected = _secondaryLanguages.contains(lang['id']);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _handleLanguageSelect(lang['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lang['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Almost there!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review your preferences and customize your reading experience',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Genres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedGenres.map((id) {
                  final genre = _genres.firstWhere((g) => g['id'] == id);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      genre['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reading Style',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _readingStyles
                    .firstWhere((s) => s['id'] == _readingStyle)['name'],
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF27272A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Languages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Primary: ${_languages.firstWhere((l) => l['id'] == _primaryLanguage)['name']}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
              ),
              if (_secondaryLanguages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Additional: ${_secondaryLanguages.map((id) => _languages.firstWhere((l) => l['id'] == id)['name']).join(', ')}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF09090B),
              Color(0xFF18181B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Stack(
                  children: [
                    // Progress bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF818CF8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_step > 1)
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _handleBack,
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                          splashRadius: 24,
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _renderStep(),
                ),
              ),

              // Footer with next button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _handleNext,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF818CF8),
                          Color(0xFF6366F1),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _step == 4 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
