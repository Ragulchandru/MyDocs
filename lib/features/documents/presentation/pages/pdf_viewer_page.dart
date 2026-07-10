// lib/features/documents/presentation/pages/pdf_viewer_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/document_error_widget.dart';
import '../providers/document_providers.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final String documentId;
  final String filePath;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.documentId,
    required this.filePath,
    required this.title,
  });

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  late PdfControllerPinch _pdfController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure context is available if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewer();
    });
  }

  Future<void> _initViewer() async {
    final localizations = AppLocalizations.of(context);

    // 1. Keep screen awake during active document reading
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // 2. Hide status and navigation bars for clean viewing
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    // 3. File validation
    final file = File(widget.filePath);
    if (!await file.exists()) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorFileNotFound;
      });
      return;
    }

    final size = await file.length();
    if (size <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnableToOpen;
      });
      return;
    }

    if (!widget.filePath.toLowerCase().endsWith('.pdf')) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnsupportedFormat;
      });
      return;
    }

    // 4. Fetch last viewed page metadata from Repository
    int initialPage = 1;
    try {
      final repo = ref.read(documentRepositoryProvider);
      final documentMetadata = await repo.getDocumentById(widget.documentId);
      if (documentMetadata != null) {
        initialPage = documentMetadata.lastViewedPage;
      }
    } catch (_) {}

    // 5. Initialize PDF Controller
    try {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.filePath),
        initialPage: initialPage,
      );
      setState(() {
        _currentPage = initialPage;
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnableToOpen;
      });
    }
  }

  Future<void> _saveLastViewedPage(int page) async {
    try {
      final repo = ref.read(documentRepositoryProvider);
      final documentMetadata = await repo.getDocumentById(widget.documentId);
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
    // 1. Disable screen awake override
    try {
      WakelockPlus.disable();
    } catch (_) {}

    // 2. Restore system UI overlays
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } catch (_) {}

    // 3. Clean up controller resources immediately
    if (_isInitialized) {
      _pdfController.dispose();
    }
    super.dispose();
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.08);
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 24,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 18,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_errorMessage != null) {
      return DocumentErrorWidget(
        title: localizations.errorUnableToOpen,
        message: _errorMessage!,
        onOk: () => Navigator.of(context).pop(),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: _buildSkeleton(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
            // Constraint maximum width to center PDF pages on tablets nicely
            constraints: const BoxConstraints(maxWidth: 800),
            child: PdfViewPinch(
              controller: _pdfController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                _saveLastViewedPage(page);
              },
              onDocumentLoaded: (document) {
                setState(() {
                  _totalPages = document.pagesCount;
                });
              },
              builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => _buildSkeleton(context),
                pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _errorMessage == null) {
                      setState(() {
                        _errorMessage = localizations.errorUnableToOpen;
                      });
                    }
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
