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

class CreateSeriesPage extends StatefulWidget {
  final User user;

  const CreateSeriesPage({super.key, required this.user});

  @override
  State<CreateSeriesPage> createState() => _CreateSeriesPageState();
}

class _CreateSeriesPageState extends State<CreateSeriesPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _seriesDescriptionController =
      TextEditingController();
  final TextEditingController _seriesTitleController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository();
  final SeriesRepository _seriesRepository = SeriesRepository();

  List<Category> categoryOptions = [];

  File? coverImage;
  File? thumbnail;

  bool isLoading = false;
  bool loadingCategories = false;

  String selectedCategoryId = '';

  // Load all the categories
  Future<void> _loadCategories() async {
    try {
      setState(() => loadingCategories = true);
      final categories = await _categoryRepository.getCategories();
      setState(() => categoryOptions = categories);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'An error occurred while loading categories. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
          ),
        );
        context.pop();
      }
    } finally {
      setState(() => loadingCategories = false);
    }
  }

  // Pick a thumbnail for the series
  Future<void> _pickThumbnail() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) {
        return;
      }

      setState(() => thumbnail = File(result.files.single.path!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred while picking a thumbnail. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    }
  }

  // Pick a cover image for the series
  Future<void> _pickCoverImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) {
        return;
      }

      setState(() => coverImage = File(result.files.single.path!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred while picking a cover image. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  bool checkSubmissionValidation() {
    if (thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Please upload a thumbnail for your series',
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),
        ),
      );
      return false;
    }

    if (coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Please upload a cover image for your series',
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),
        ),
      );
      return false;
    }

    if (selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Please select a category for your series',
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),
        ),
      );
      return false;
    }

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  Future<void> _createSeries() async {
    if (!checkSubmissionValidation()) {
      return;
    }

    final title = _seriesTitleController.text;
    final description = _seriesDescriptionController.text;

    try {
      setState(() => isLoading = true);

      final Series series = await _seriesRepository.createSeries(
        categoryId: selectedCategoryId,
        creatorId: widget.user.id,
        description: description,
        title: title,
        coverImageFile: coverImage!,
        thumbnailFile: thumbnail!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(
              'Series created successfully',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );

        context.go(
          '/series_details_page',
          extra: {
            'series': series,
            'user': widget.user,
          },
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              error.toString(),
              style: TextStyle(fontSize: screenHeight * 0.015),
            ),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Series',
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: _createSeries,
              icon: Icon(
                Icons.check,
                color: Theme.of(context).primaryColor,
                size: screenHeight * 0.03,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(screenHeight * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          controller: _seriesTitleController,
                          hint: 'Enter your series title',
                          label: 'Series Title',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a series title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        InputField(
                          controller: _seriesDescriptionController,
                          hint: 'Enter your series description',
                          label: 'Series Description',
                          maxLines: 4,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a series description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
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
                              setState(() => selectedCategoryId = category.id);
                            } else {
                              setState(() => selectedCategoryId = '');
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        MediaButton(
                          icon: LucideIcons.image,
                          label: 'Upload Thumbnail',
                          onTap: _pickThumbnail,
                          selectedFileName: thumbnail?.path.split('/').last,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        if (thumbnail != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(thumbnail!) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: screenHeight * 0.02),
                        MediaButton(
                          icon: LucideIcons.image,
                          label: 'Upload Cover Image',
                          onTap: _pickCoverImage,
                          selectedFileName: coverImage?.path.split('/').last,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        if (coverImage != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(coverImage!) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
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
