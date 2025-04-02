import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laya/features/reader/data/reader_state.dart';
import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReaderSettingsPanel extends StatefulWidget {
  final ReaderState readerState;
  final Function(ReaderState) updateReaderState;

  const ReaderSettingsPanel({
    super.key,
    required this.readerState,
    required this.updateReaderState,
  });

  @override
  State<ReaderSettingsPanel> createState() => _ReaderSettingsPanelState();
}

class _ReaderSettingsPanelState extends State<ReaderSettingsPanel> {
  // Local state to track values during sliding
  late double _fontSize;
  late double _lineHeight;
  late double _marginSize;
  late ReaderTheme _theme;
  late String _fontFamily;

  @override
  void initState() {
    super.initState();
    // Initialize local state from readerState
    _fontSize = widget.readerState.fontSize;
    _lineHeight = widget.readerState.lineHeight;
    _marginSize = widget.readerState.marginSize;
    _theme = widget.readerState.theme;
    _fontFamily = widget.readerState.fontFamily;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.readerState.theme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: theme.surfaceColor.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: theme.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.text.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.settings,
                      color: theme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reader Settings',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        LucideIcons.x,
                        color: theme.text.withOpacity(0.6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings content (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingSection(
                        'Display',
                        [
                          _buildFontSizeControl(),
                          _buildLineHeightControl(),
                          _buildThemeControl(),
                          _buildFontSelector(),
                        ],
                      ),
                      _buildSettingSection(
                        'Layout',
                        [
                          _buildMarginControl(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    final theme = widget.readerState.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFontSizeControl() {
    final theme = widget.readerState.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.text, size: 18, color: theme.text),
            const SizedBox(width: 12),
            Text(
              'Font Size',
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              _fontSize.toStringAsFixed(0),
              style: TextStyle(
                color: theme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              LucideIcons.minus,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
            Expanded(
              child: Slider(
                value: _fontSize,
                min: 12,
                max: 28,
                activeColor: theme.accent,
                inactiveColor: theme.borderColor,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                  widget.updateReaderState(
                    widget.readerState.copyWith(fontSize: value),
                  );
                },
              ),
            ),
            Icon(
              LucideIcons.plus,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineHeightControl() {
    final theme = widget.readerState.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.alignVerticalSpaceBetween,
              size: 18,
              color: theme.text,
            ),
            const SizedBox(width: 12),
            Text(
              'Line Spacing',
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              _lineHeight.toStringAsFixed(1),
              style: TextStyle(
                color: theme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              LucideIcons.alignVerticalJustifyStart,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
            Expanded(
              child: Slider(
                value: _lineHeight,
                min: 1.0,
                max: 2.0,
                activeColor: theme.accent,
                inactiveColor: theme.borderColor,
                onChanged: (value) {
                  setState(() {
                    _lineHeight = value;
                  });
                  widget.updateReaderState(
                    widget.readerState.copyWith(lineHeight: value),
                  );
                },
              ),
            ),
            Icon(
              LucideIcons.alignVerticalJustifyEnd,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarginControl() {
    final theme = widget.readerState.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.layoutTemplate, size: 18, color: theme.text),
            const SizedBox(width: 12),
            Text(
              'Margin Width',
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              _marginSize.toStringAsFixed(0),
              style: TextStyle(
                color: theme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              LucideIcons.layoutPanelLeft,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
            Expanded(
              child: Slider(
                value: _marginSize,
                min: 8,
                max: 40,
                activeColor: theme.accent,
                inactiveColor: theme.borderColor,
                onChanged: (value) {
                  setState(() {
                    _marginSize = value;
                  });
                  widget.updateReaderState(
                    widget.readerState.copyWith(marginSize: value),
                  );
                },
              ),
            ),
            Icon(
              LucideIcons.layoutPanelLeft,
              size: 16,
              color: theme.text.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeControl() {
    final currentTheme = widget.readerState.theme;
    final theme = widget.readerState.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.palette, size: 18, color: theme.text),
            const SizedBox(width: 12),
            Text(
              'Theme',
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildThemeButton(
              ReaderThemes.light,
              'Light',
              currentTheme == ReaderThemes.light,
            ),
            _buildThemeButton(
              ReaderThemes.dark,
              'Dark',
              currentTheme == ReaderThemes.dark,
            ),
            _buildThemeButton(
              ReaderThemes.sepia,
              'Sepia',
              currentTheme == ReaderThemes.sepia,
            ),
            _buildThemeButton(
              ReaderThemes.nightBlue,
              'Night',
              currentTheme == ReaderThemes.nightBlue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeButton(
    ReaderTheme theme,
    String label,
    bool isSelected,
  ) {
    final currentTheme = widget.readerState.theme;

    return GestureDetector(
      onTap: () =>
          widget.updateReaderState(widget.readerState.copyWith(theme: theme)),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: theme.background,
              border: Border.all(
                color: isSelected ? theme.accent : theme.borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      LucideIcons.check,
                      size: 16,
                      color: theme.accent,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? currentTheme.accent
                  : currentTheme.text.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFontSelector() {
    final theme = widget.readerState.theme;
    final selectedFont = widget.readerState.fontFamily;

    final fonts = [
      'System',
      'Times New Roman',
      'Georgia',
      'Arial',
      'Verdana',
      'Roboto',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.type, size: 18, color: theme.text),
            const SizedBox(width: 12),
            Text(
              'Font Family',
              style: TextStyle(
                color: theme.text,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fonts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final font = fonts[index];
              final isSelected = font == selectedFont;

              return GestureDetector(
                onTap: () {
                  widget.updateReaderState(
                      widget.readerState.copyWith(fontFamily: font));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.accent.withOpacity(0.1)
                        : theme.borderColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? theme.accent : theme.borderColor,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    font,
                    style: TextStyle(
                      fontFamily: font == 'System' ? null : font,
                      color: isSelected ? theme.accent : theme.text,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
