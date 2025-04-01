import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/category_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/services/category_service.dart';
import 'package:laya/services/series_service.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditSeriesScreen extends StatefulWidget {
  final Series series;

  const EditSeriesScreen({super.key, required this.series});

  @override
  State<EditSeriesScreen> createState() => _EditSeriesScreenState();
}

class _EditSeriesScreenState extends State<EditSeriesScreen> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  final CategoryService _categoryService = CategoryService();
  final SeriesService _seriesService = SeriesService();

  List<Category> categoryOptions = [];
  Set<String> _selectedCategoryIds = {};

  File? _newCoverImage;
  File? _newThumbnail;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool loadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _titleController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        loadingCategories = true;
        _isLoading = true;
      });

      final categories = await _categoryService.getAllCategories();
      setState(() {
        categoryOptions = categories;
        _selectedCategoryIds = widget.series.categoryIds.toSet();
      });

      _titleController.text = widget.series.title;
      _descriptionController.text = widget.series.description;
    } catch (e) {
      _showError('Failed to load data');
    } finally {
      setState(() {
        loadingCategories = false;
        _isLoading = false;
      });
    }
  }

  void _checkForChanges() {
    final hasTextChanges = _titleController.text != widget.series.title ||
        _descriptionController.text != widget.series.description ||
        !_areCategoryIdsEqual(_selectedCategoryIds, widget.series.categoryIds);

    final hasNewCoverImage = _newCoverImage != null;
    final hasNewThumbnail = _newThumbnail != null;

    setState(() {
      _hasChanges = hasTextChanges || hasNewThumbnail || hasNewCoverImage;
    });
  }

  bool _areCategoryIdsEqual(Set<String> set1, List<String> list2) {
    if (set1.length != list2.length) return false;
    return set1.containsAll(list2) && list2.every((id) => set1.contains(id));
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
      _checkForChanges();
    });
  }

  Future<void> _pickCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _newCoverImage = File(result.files.single.path!);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showError('Failed to pick cover image. Please try again.');
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _newThumbnail = File(result.files.single.path!);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showError('Failed to pick thumbnail. Please try again.');
    }
  }

  Future<void> _updateSeries() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    try {
      setState(() => _isLoading = true);

      // First create an updated Series object using copyWith
      final updatedSeriesData = widget.series.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryIds: _selectedCategoryIds.toList(),
        updatedAt: DateTime.now(),
      );

      // Handle file uploads and get the updated series
      final updatedSeries = await _seriesService.updateSeries(
        series: updatedSeriesData,
        newCoverImage: _newCoverImage,
        newThumbnail: _newThumbnail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Series updated successfully',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
        context.go('/series_details', extra: {'series': updatedSeries});
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Discard changes?',
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: TextStyle(fontSize: screenHeight * 0.018),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: TextStyle(fontSize: screenHeight * 0.018),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Series',
            style: TextStyle(fontSize: screenHeight * 0.025),
          ),
          actions: [
            if (_hasChanges && !_isLoading)
              IconButton(
                color: Theme.of(context).colorScheme.primary,
                icon: Icon(Icons.check, size: screenHeight * 0.025),
                onPressed: _updateSeries,
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenHeight * 0.015),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter series title',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  InputField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter series description',
                    maxLines: 4,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryOptions.map((category) {
                      final isSelected = _selectedCategoryIds.contains(
                        category.id,
                      );
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) => _toggleCategory(category.id),
                        showCheckmark: true,
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (widget.series.thumbnailUrl!.isNotEmpty ||
                      _newThumbnail != null)
                    Container(
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: _newThumbnail != null
                              ? FileImage(_newThumbnail!) as ImageProvider
                              : CachedNetworkImageProvider(
                                  widget.series.thumbnailUrl!,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  MediaButton(
                    label: 'Change Thumbnail',
                    icon: LucideIcons.image,
                    onTap: _pickThumbnail,
                    selectedFileName: _newThumbnail?.path.split('/').last,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (widget.series.coverImageUrl!.isNotEmpty ||
                      _newCoverImage != null)
                    Container(
                      height: screenHeight * 0.25,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: _newCoverImage != null
                              ? FileImage(_newCoverImage!) as ImageProvider
                              : CachedNetworkImageProvider(
                                  widget.series.coverImageUrl!,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  MediaButton(
                    label: 'Change Cover Image',
                    icon: LucideIcons.image,
                    onTap: _pickCoverImage,
                    selectedFileName: _newCoverImage?.path.split('/').last,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
