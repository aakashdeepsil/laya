import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/enums/media_type.dart';
import 'package:laya/features/content/data/content_repository.dart';
import 'package:laya/features/content/data/series_repository.dart';
import 'package:laya/shared/widgets/content/input_field_widget.dart';
import 'package:laya/shared/widgets/content/media_button_widget.dart';
import 'package:laya/shared/widgets/editable_dropdown_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateChapterPage extends StatefulWidget {
  final User user;
  final Series? selectedSeries;

  const CreateChapterPage({super.key, required this.user, this.selectedSeries});

  @override
  State<CreateChapterPage> createState() => _CreateChapterPageState();
}

class _CreateChapterPageState extends State<CreateChapterPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seriesController = TextEditingController();

  final SeriesRepository _seriesRepository = SeriesRepository();
  final ContentRepository _contentRepository = ContentRepository();

  List<Series> _seriesList = [];
  bool _isLoading = false;
  bool _loadingSeries = false;
  Series? _selectedSeries;
  File? _thumbnail;
  File? _mediaFile;
  MediaType _selectedMediaType = MediaType.none;

  @override
  void initState() {
    super.initState();
    _loadUserSeries();
    if (widget.selectedSeries != null) {
      _selectedSeries = widget.selectedSeries;
      _seriesController.text = widget.selectedSeries!.title;
    }
  }

  Future<void> _loadUserSeries() async {
    try {
      setState(() => _loadingSeries = true);
      final series = await _seriesRepository.getUserSeries(widget.user.id);
      setState(() => _seriesList = series);
    } catch (e) {
      _showError('Failed to load series');
    } finally {
      setState(() => _loadingSeries = false);
    }
  }

  Future<void> _pickMedia() async {
    final MediaType? type = await showDialog<MediaType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Media Type',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Document',
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              onTap: () => context.pop(MediaType.document),
            ),
            // ListTile(
            //   title: Text(
            //     'Video',
            //     style: TextStyle(fontSize: screenHeight * 0.02),
            //   ),
            //   onTap: () => context.pop(MediaType.video),
            // ),
          ],
        ),
      ),
    );

    if (type == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: type == MediaType.video
            ? ['mp4', 'mov', 'avi']
            : ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _mediaFile = File(result.files.single.path!);
          _selectedMediaType = type;
        });
      }
    } catch (e) {
      _showError('Error picking file');
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() => _thumbnail = File(result.files.single.path!));
      }
    } catch (e) {
      _showError('Error picking thumbnail');
    }
  }

  Future<void> _createChapter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSeries == null) {
      _showError('Please select a series');
      return;
    }
    if (_thumbnail == null) {
      _showError('Please select a thumbnail');
      return;
    }
    if (_mediaFile == null) {
      _showError('Please upload content');
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _contentRepository.createContent(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedSeries!.categoryId,
        creatorId: widget.user.id,
        seriesId: _selectedSeries!.id,
        thumbnail: _thumbnail!,
        mediaFile: _mediaFile!,
        mediaType: _selectedMediaType,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Chapter created successfully',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
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
        content: Text(message, style: TextStyle(fontSize: screenHeight * 0.02)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Chapter',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        actions: [
          _seriesList.isEmpty
              ? Container()
              : IconButton(
                  onPressed: _createChapter,
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenHeight * 0.025,
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: _seriesList.isEmpty
            ? Center(
                child: Text(
                  'You have not created any series yet',
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditableDropdown(
                          label: 'Series',
                          hint: 'Select series',
                          controller: _seriesController,
                          isLoading: _loadingSeries,
                          items: _seriesList.map((s) => s.title).toList(),
                          onChanged: (value) {
                            final series = _seriesList.firstWhere(
                              (s) =>
                                  s.title.toLowerCase() == value.toLowerCase(),
                              orElse: () => Series(
                                id: '',
                                creatorId: '',
                                categoryId: '',
                                description: '',
                                title: '',
                                coverImageUrl: '',
                                thumbnailUrl: '',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            );
                            setState(() => _selectedSeries = series);
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        InputField(
                          controller: _titleController,
                          label: 'Chapter Title',
                          hint: 'Enter chapter title',
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        InputField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Enter chapter description',
                          maxLines: 4,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        MediaButton(
                          label: 'Upload Thumbnail',
                          icon: LucideIcons.image,
                          onTap: _pickThumbnail,
                          selectedFileName: _thumbnail?.path.split('/').last,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        MediaButton(
                          label: 'Upload Content',
                          icon: Icons.upload_file,
                          onTap: _pickMedia,
                          selectedFileName: _mediaFile?.path.split('/').last,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _seriesController.dispose();
    super.dispose();
  }
}
