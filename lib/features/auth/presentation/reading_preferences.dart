import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Theme constants and ReaderTheme class remain the same...
class ReaderTheme {
  final Color background;
  final Color text;
  final Color accent;

  const ReaderTheme({
    required this.background,
    required this.text,
    required this.accent,
  });
}

class ReaderThemes {
  static const dark = ReaderTheme(
    background: Color(0xFF09090B),
    text: Colors.white,
    accent: Color(0xFF818CF8),
  );

  static const light = ReaderTheme(
    background: Colors.white,
    text: Color(0xFF09090B),
    accent: Color(0xFF818CF8),
  );

  static const sepia = ReaderTheme(
    background: Color(0xFFF8F4E9),
    text: Color(0xFF5C4B37),
    accent: Color(0xFF8B7355),
  );

  static const nightBlue = ReaderTheme(
    background: Color(0xFF0F172A),
    text: Color(0xFFE2E8F0),
    accent: Color(0xFF60A5FA),
  );
}

// Reader state class remains the same...
class ReaderState extends ChangeNotifier {
  String _readerMode = 'book';
  bool _showControls = true;
  double _fontSize = 18;
  double _lineHeight = 1.6;
  double _brightness = 0.8;
  int _currentPage = 1;
  int _totalPages = 324;
  String _selectedFont = 'System';
  ReaderTheme _currentTheme = ReaderThemes.dark;
  String _readingDirection = 'ltr';
  List<Bookmark> _bookmarks = [];
  double _marginSize = 20;

  // Sample book text
  final String sampleBookText = '''
Chapter 1: The Beginning

The ancient manuscript lay before her, its pages yellowed with age, corners frayed from countless hands that had turned them over the centuries. Sarah's fingers trembled as she traced the intricate symbols etched into the parchment. The library's dim lights cast dancing shadows across the text, making the strange characters seem almost alive.

In all her years of studying ancient languages, she had never encountered anything quite like this. The symbols appeared to be a hybrid of early Sumerian and something else—something older, perhaps. Much older.
''';

  // Getters
  String get readerMode => _readerMode;
  bool get showControls => _showControls;
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  double get brightness => _brightness;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get selectedFont => _selectedFont;
  ReaderTheme get currentTheme => _currentTheme;
  String get readingDirection => _readingDirection;
  List<Bookmark> get bookmarks => _bookmarks;
  double get marginSize => _marginSize;

  // Setters remain the same...
  void setReaderMode(String mode) {
    _readerMode = mode;
    notifyListeners();
  }

  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void setTheme(ReaderTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void addBookmark() {
    _bookmarks.add(Bookmark(
      page: _currentPage,
      timestamp: DateTime.now(),
      note: '',
    ));
    notifyListeners();
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }
}

class Bookmark {
  final int page;
  final DateTime timestamp;
  String note;

  Bookmark({
    required this.page,
    required this.timestamp,
    required this.note,
  });
}

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderState(),
      child: const ReaderContent(),
    );
  }
}

class ReaderContent extends StatelessWidget {
  const ReaderContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return Scaffold(
      backgroundColor: readerState.currentTheme.background,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => readerState.toggleControls(),
            child: _buildContent(context),
          ),
          if (readerState.showControls) _buildControls(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return readerState.readerMode == 'book'
        ? _buildBookContent(context)
        : _buildMangaContent(context);
  }

  Widget _buildBookContent(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(readerState.marginSize),
      child: Text(
        readerState.sampleBookText,
        style: TextStyle(
          fontSize: readerState.fontSize,
          height: readerState.lineHeight,
          fontFamily: readerState.selectedFont,
          color: readerState.currentTheme.text,
        ),
      ),
    );
  }

  Widget _buildMangaContent(BuildContext context) {
    return Container(); // Placeholder for manga content
  }

  Widget _buildControls(BuildContext context) {
    return const _ReaderControls();
  }
}

class _ReaderControls extends StatelessWidget {
  const _ReaderControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        const Spacer(),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: readerState.currentTheme.text,
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Ancient Manuscript',
                    style: TextStyle(
                      color: readerState.currentTheme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Chapter 1: The Beginning',
                    style: TextStyle(
                      color: readerState.currentTheme.text.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              color: readerState.currentTheme.text,
              onPressed: () => readerState.addBookmark(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: readerState.currentTheme.text,
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${readerState.currentPage}',
              style: TextStyle(color: readerState.currentTheme.text),
            ),
            Expanded(
              child: Slider(
                value: readerState.currentPage.toDouble(),
                min: 1,
                max: readerState.totalPages.toDouble(),
                activeColor: readerState.currentTheme.accent,
                inactiveColor: Colors.grey,
                onChanged: (value) => readerState.setCurrentPage(value.round()),
              ),
            ),
            Text(
              '${readerState.totalPages}',
              style: TextStyle(color: readerState.currentTheme.text),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _SettingsPanel(),
      backgroundColor: Colors.transparent,
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return Container(
      decoration: BoxDecoration(
        color: readerState.currentTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingSection(
              context,
              'Display',
              [
                _buildFontSizeControl(context),
                _buildThemeControl(context),
              ],
            ),
            _buildSettingSection(
              context,
              'Reading Mode',
              [
                _buildModeControl(context),
                if (readerState.readerMode == 'manga')
                  _buildDirectionControl(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(
      BuildContext context, String title, List<Widget> children) {
    final readerState = Provider.of<ReaderState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: readerState.currentTheme.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFontSizeControl(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return Row(
      children: [
        Icon(Icons.format_size, color: readerState.currentTheme.text),
        Expanded(
          child: Slider(
            value: readerState.fontSize,
            min: 14,
            max: 24,
            activeColor: readerState.currentTheme.accent,
            onChanged: (value) => readerState.setFontSize(value),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeControl(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        _buildThemeButton(context, ReaderThemes.light, 'Light'),
        _buildThemeButton(context, ReaderThemes.dark, 'Dark'),
        _buildThemeButton(context, ReaderThemes.sepia, 'Sepia'),
        _buildThemeButton(context, ReaderThemes.nightBlue, 'Night Blue'),
      ],
    );
  }

  Widget _buildThemeButton(
      BuildContext context, ReaderTheme theme, String label) {
    final readerState = Provider.of<ReaderState>(context);
    final isSelected = readerState.currentTheme == theme;

    return GestureDetector(
      onTap: () => readerState.setTheme(theme),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.background,
          border: Border.all(
            color: isSelected ? theme.accent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildModeControl(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'book', label: Text('Book Mode')),
        ButtonSegment(value: 'manga', label: Text('Manga Mode')),
      ],
      selected: {readerState.readerMode},
      onSelectionChanged: (Set<String> selection) {
        readerState.setReaderMode(selection.first);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return readerState.currentTheme.accent;
            }
            return readerState.currentTheme.background;
          },
        ),
      ),
    );
  }

  Widget _buildDirectionControl(BuildContext context) {
    final readerState = Provider.of<ReaderState>(context);

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'ltr',
          icon: Icon(Icons.format_textdirection_l_to_r),
        ),
        ButtonSegment(
          value: 'rtl',
          icon: Icon(Icons.format_textdirection_r_to_l),
        ),
      ],
      selected: {readerState.readingDirection},
      onSelectionChanged: (Set<String> selection) {
        // Implement direction change
      },
    );
  }
}
