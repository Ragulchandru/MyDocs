// lib/features/documents/presentation/pages/pdf_viewer_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pdfx/pdfx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../../../core/widgets/document_error_widget.dart';
import '../../domain/models/document.dart';
import '../providers/document_providers.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final String? documentId;
  final String filePath;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.filePath,
    required this.title,
    this.documentId,
  });

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  late final PdfControllerPinch _pdfController;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    // Keep screen awake during document viewing
    try {
      WakelockPlus.enable();
    } catch (_) {}
    // Hide status/navigation bars for clean viewing
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    _initViewer();
  }

  void _initViewer() {
    final file = File(widget.filePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      setState(() {
        _errorMessage = 'File not found or empty';
        _isLoading = false;
      });
      return;
    }

    int initialPage = 1;
    if (widget.documentId != null) {
      try {
        final box = Hive.box<Document>(StorageConstants.documentsBox);
        final doc = box.get(widget.documentId);
        if (doc != null) {
          initialPage = doc.lastViewedPage;
        }
      } catch (_) {}
    }
    _currentPage = initialPage;
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
      initialPage: initialPage,
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveLastViewedPage(int page) async {
    if (widget.documentId == null) return;
    try {
      final repo = ref.read(documentRepositoryProvider);
      final documentMetadata = await repo.getDocumentById(widget.documentId!);
      if (documentMetadata != null && documentMetadata.lastViewedPage != page) {
        final updatedDoc = documentMetadata.copyWith(
          lastViewedPage: page,
          updatedAt: DateTime.now(),
        );
        await repo.saveDocument(updatedDoc);
      }
    } catch (_) {}
  }



  @override
  void dispose() {
    try {
      WakelockPlus.disable();
    } catch (_) {}
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } catch (_) {}

    if (!_isLoading && _errorMessage == null) {
      _pdfController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_errorMessage != null) {
      return DocumentErrorWidget(
        title: localizations.errorUnableToOpen,
        message: _errorMessage!,
        onOk: () => Navigator.of(context).pop(),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  localizations.pageIndicatorText(_currentPage, _totalPages),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: PdfViewPinch(
              controller: _pdfController,
              onPageChanged: (page) {
                if (!mounted) return;
                setState(() {
                  _currentPage = page;
                });
                _saveLastViewedPage(page);
              },
              onDocumentLoaded: (document) {
                if (!mounted) return;
                setState(() {
                  _totalPages = document.pagesCount;
                });
              },
              builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) {
                  return Center(child: Text(localizations.errorUnableToOpen));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
