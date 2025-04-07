import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Document Cache Manager
class DocumentCacheManager {
  static const String key = 'documentCacheKey';
  static DocumentCacheManager? _instance;
  late CacheManager _cacheManager;

  static DocumentCacheManager get instance {
    _instance ??= DocumentCacheManager._();
    return _instance!;
  }

  DocumentCacheManager._() {
    _cacheManager = CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 50,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
  }

  Future<File> getDocument(String url) async {
    try {
      developer.log(
        'Downloading document from URL: $url',
        name: 'CachedPdfViewer',
      );
      final fileInfo = await _cacheManager.downloadFile(url);
      developer.log(
        'Document downloaded successfully: ${fileInfo.file.path}',
        name: 'CachedPdfViewer',
      );
      return fileInfo.file;
    } catch (e) {
      developer.log(
        'Error downloading document: $e',
        name: 'CachedPdfViewer',
        error: e,
      );
      throw Exception('Error downloading document: $e');
    }
  }

  Future<bool> removeDocument(String url) async {
    try {
      await _cacheManager.removeFile(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}

// Cached PDF Viewer Widget
class CachedPdfViewer extends StatefulWidget {
  final String documentUrl;
  final Function(int) onDocumentLoaded;
  final Function(int) onPageChanged;
  final Function(String)? onTextExtracted;
  final Color? backgroundColor;
  final Color? loadingColor;
  final int? initialPage;

  const CachedPdfViewer({
    super.key,
    required this.documentUrl,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    this.onTextExtracted,
    this.backgroundColor,
    this.loadingColor,
    this.initialPage,
  });

  @override
  State<CachedPdfViewer> createState() => _CachedPdfViewerState();
}

class _CachedPdfViewerState extends State<CachedPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late Future<File> _documentFuture;
  PdfViewerController? _pdfViewerController;
  String? _error;
  bool _isLoading = true;
  int _totalPages = 0;
  Color? _currentBackgroundColor;
  bool _hasJumpedToInitialPage = false;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing CachedPdfViewer', name: 'CachedPdfViewer');
    _pdfViewerController = PdfViewerController();
    _documentFuture = _getDocument();
    _currentBackgroundColor = widget.backgroundColor;
  }

  @override
  void didUpdateWidget(CachedPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if theme colors changed
    if (widget.backgroundColor != _currentBackgroundColor) {
      developer.log(
          'Background color changed from $_currentBackgroundColor to ${widget.backgroundColor}',
          name: 'CachedPdfViewer');
      _currentBackgroundColor = widget.backgroundColor;
      // Force rebuild of the viewer with new theme
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<File> _getDocument() async {
    try {
      developer.log(
        'Starting PDF download from: ${widget.documentUrl}',
        name: 'CachedPdfViewer',
      );
      final file =
          await DefaultCacheManager().getSingleFile(widget.documentUrl);
      final fileSize = await file.length();
      developer.log(
        'PDF download completed, file size: $fileSize bytes',
        name: 'CachedPdfViewer',
      );

      // Verify the file exists and has content
      if (!await file.exists()) {
        throw Exception('Downloaded file does not exist');
      }
      if (fileSize == 0) {
        throw Exception('Downloaded file is empty');
      }

      return file;
    } catch (e) {
      developer.log(
        'Error downloading PDF: $e',
        name: 'CachedPdfViewer',
        error: e,
      );
      throw Exception('Error downloading PDF: $e');
    }
  }

  Future<void> _loadDocument(File file) async {
    if (!mounted) return;

    try {
      developer.log(
        'Loading PDF document from file: ${file.path}',
        name: 'CachedPdfViewer',
      );
      final bytes = await file.readAsBytes();
      developer.log(
        'File bytes loaded, size: ${bytes.length}',
        name: 'CachedPdfViewer',
      );

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      _totalPages = document.pages.count;
      developer.log(
        'PDF loaded successfully, total pages: $_totalPages',
        name: 'CachedPdfViewer',
      );

      // Extract text from all pages
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final StringBuilder textBuilder = StringBuilder();

      for (int i = 0; i < _totalPages; i++) {
        if (!mounted) {
          document.dispose();
          return;
        }

        developer.log(
          'Extracting text from page ${i + 1}/$_totalPages',
          name: 'CachedPdfViewer',
        );
        try {
          final String pageText = extractor.extractText(
            startPageIndex: i,
            endPageIndex: i,
          );
          developer.log(
            'Page ${i + 1} text length: ${pageText.length}',
            name: 'CachedPdfViewer',
          );
          textBuilder.write(pageText);
          textBuilder.write('\n\n'); // Add spacing between pages
        } catch (e) {
          developer.log(
            'Error extracting text from page ${i + 1}: $e',
            name: 'CachedPdfViewer',
            error: e,
          );
        }
      }

      final String fullText = textBuilder.toString();
      developer.log(
        'Text extraction complete, total length: ${fullText.length}',
        name: 'CachedPdfViewer',
      );

      // Pass the extracted text back to the parent
      if (mounted && widget.onTextExtracted != null && fullText.isNotEmpty) {
        developer.log(
          'Passing extracted text to parent',
          name: 'CachedPdfViewer',
        );
        widget.onTextExtracted!(fullText);
      }

      document.dispose();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log(
        'Error loading PDF document: $e',
        name: 'CachedPdfViewer',
        error: e,
      );
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'Building CachedPdfViewer, isLoading: $_isLoading, hasError: ${_error != null}, backgroundColor: $_currentBackgroundColor',
      name: 'CachedPdfViewer',
    );

    return FutureBuilder<File>(
      future: _documentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          developer.log(
            'Waiting for PDF file to load',
            name: 'CachedPdfViewer',
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: widget.loadingColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Downloading PDF...',
                  style: TextStyle(
                    color: widget.loadingColor?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || _error != null) {
          final error = _error ?? snapshot.error.toString();
          developer.log('Error in PDF viewer: $error', name: 'CachedPdfViewer');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading PDF: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                      _documentFuture = _getDocument();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          developer.log(
            'PDF file loaded, creating viewer with background color: $_currentBackgroundColor',
            name: 'CachedPdfViewer',
          );
          return SfPdfViewerTheme(
            data: SfPdfViewerThemeData(
              backgroundColor: _currentBackgroundColor ?? Colors.white,
              progressBarColor: widget.loadingColor,
              brightness: Theme.of(context).brightness,
            ),
            child: SfPdfViewer.file(
              snapshot.data!,
              controller: _pdfViewerController,
              key: _pdfViewerKey,
              canShowPaginationDialog: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              interactionMode: PdfInteractionMode.selection,
              scrollDirection: PdfScrollDirection.vertical,
              pageSpacing: 8,
              onDocumentLoaded: (details) {
                developer.log(
                  'PDF document loaded in viewer, pages: ${details.document.pages.count}',
                  name: 'CachedPdfViewer',
                );
                _loadDocument(snapshot.data!);
                widget.onDocumentLoaded(details.document.pages.count);

                // Jump to initial page if specified
                if (widget.initialPage != null && !_hasJumpedToInitialPage) {
                  _pdfViewerController?.jumpToPage(widget.initialPage!);
                  _hasJumpedToInitialPage = true;
                }
              },
              onDocumentLoadFailed: (details) {
                developer.log(
                  'PDF document load failed: ${details.error}',
                  name: 'CachedPdfViewer',
                  error: details.error,
                );
                setState(() {
                  _error = details.error.toString();
                  _isLoading = false;
                });
              },
              onPageChanged: (details) {
                developer.log(
                  'Page changed to: ${details.newPageNumber}',
                  name: 'CachedPdfViewer',
                );
                widget.onPageChanged(details.newPageNumber);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    developer.log('Disposing CachedPdfViewer', name: 'CachedPdfViewer');
    _pdfViewerController?.dispose();
    super.dispose();
  }
}

// Helper class for efficient string concatenation
class StringBuilder {
  final List<String> _parts = [];

  void write(String part) {
    _parts.add(part);
  }

  @override
  String toString() {
    return _parts.join();
  }
}
