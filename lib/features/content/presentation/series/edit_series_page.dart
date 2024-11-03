import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/category.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/content/data/category_repository.dart';
import 'package:laya/features/content/data/series_repository.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:laya/shared/widgets/editable_dropdown_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditSeriesPage extends StatefulWidget {
  final Series series;
  final User user;

  const EditSeriesPage({
    super.key,
    required this.series,
    required this.user,
  });

  @override
  State<EditSeriesPage> createState() => _EditSeriesPageState();
}

class _EditSeriesPageState extends State<EditSeriesPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository();
  final SeriesRepository _seriesRepository = SeriesRepository();

  List<Category> categoryOptions = [];

  File? _newCoverImage;
  File? _newThumbnail;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool loadingCategories = false;
  String selectedCategoryId = '';

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

      final categories = await _categoryRepository.getCategories();
      setState(() => categoryOptions = categories);

      final selectedCategory = categoryOptions.firstWhere(
        (category) => category.id == widget.series.categoryId,
        orElse: () => Category(
          id: '',
          name: 'name',
          createdAt: DateTime.now(),
        ),
      );

      setState(() {
        selectedCategoryId = selectedCategory.id;
        _categoryController.text = selectedCategory.name;
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
        _descriptionController.text != (widget.series.description) ||
        selectedCategoryId != widget.series.categoryId;

    final hasNewCoverImage = _newCoverImage != null;
    final hasNewThumbnail = _newThumbnail != null;

    setState(() {
      _hasChanges = hasTextChanges || hasNewThumbnail || hasNewCoverImage;
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

      final updatedSeries = await _seriesRepository.updateSeries(
        seriesId: widget.series.id,
        categoryId: selectedCategoryId,
        creatorId: widget.user.id,
        description: _descriptionController.text,
        title: _titleController.text,
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
        context.go('/series_details_page', extra: {
          'series': updatedSeries,
          'user': widget.user,
        });
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
                  if (widget.series.thumbnailUrl.isNotEmpty ||
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
                              : NetworkImage(widget.series.thumbnailUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  MediaButton(
                    label: 'Change Thumbnail',
                    icon: LucideIcons.image,
                    onTap: _pickThumbnail,
                    selectedFileName: _newThumbnail?.path.split('/').last,
                  ),
                  if (widget.series.coverImageUrl.isNotEmpty ||
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
                              : NetworkImage(widget.series.coverImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  MediaButton(
                    label: 'Change Cover Image',
                    icon: LucideIcons.image,
                    onTap: _pickCoverImage,
                    selectedFileName: _newCoverImage?.path.split('/').last,
                  ),
                  SizedBox(height: screenHeight * 0.01),
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
                  SizedBox(height: screenHeight * 0.01),
                  EditableDropdown(
                    label: 'Category',
                    hint: 'Select series category',
                    controller: _categoryController,
                    isLoading: loadingCategories,
                    items: categoryOptions
                        .map(
                          (category) => category.name,
                        )
                        .toList(),
                    onChanged: (selectedCategory) {
                      final category = categoryOptions.firstWhere(
                        (category) => category.name == selectedCategory,
                        orElse: () => Category(
                          id: '',
                          name: '',
                          description: '',
                          createdAt: DateTime.now(),
                        ),
                      );

                      if (category.id.isNotEmpty) {
                        setState(() {
                          selectedCategoryId = category.id;
                          _categoryController.text = category.name;
                        });
                        _checkForChanges();
                      }
                    },
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
