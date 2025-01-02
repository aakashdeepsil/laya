import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
      final fileInfo = await _cacheManager.downloadFile(url);
      return fileInfo.file;
    } catch (e) {
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
  final String mediaUrl;
  final int initialPageNumber;
  final Function(PdfDocumentLoadedDetails) onDocumentLoaded;
  final Function(PdfPageChangedDetails) onPageChanged;
  final bool canShowPaginationDialog;

  const CachedPdfViewer({
    super.key,
    required this.mediaUrl,
    required this.initialPageNumber,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    this.canShowPaginationDialog = false,
  });

  @override
  State<CachedPdfViewer> createState() => _CachedPdfViewerState();
}

class _CachedPdfViewerState extends State<CachedPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late Future<File> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture =
        DocumentCacheManager.instance.getDocument(widget.mediaUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _documentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading PDF: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          return SfPdfViewer.file(
            snapshot.data!,
            key: _pdfViewerKey,
            canShowPaginationDialog: widget.canShowPaginationDialog,
            initialPageNumber: widget.initialPageNumber,
            onDocumentLoaded: widget.onDocumentLoaded,
            onPageChanged: widget.onPageChanged,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
