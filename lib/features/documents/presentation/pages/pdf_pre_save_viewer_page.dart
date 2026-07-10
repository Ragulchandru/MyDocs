// lib/features/documents/presentation/pages/pdf_pre_save_viewer_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/document_error_widget.dart';
import '../providers/document_providers.dart';
import '../providers/scan_session_provider.dart';

class PdfPreSaveViewerPage extends ConsumerStatefulWidget {
  final String tempPdfPath;
  final String documentName;

  const PdfPreSaveViewerPage({
    super.key,
    required this.tempPdfPath,
    required this.documentName,
  });

  @override
  ConsumerState<PdfPreSaveViewerPage> createState() => _PdfPreSaveViewerPageState();
}

class _PdfPreSaveViewerPageState extends ConsumerState<PdfPreSaveViewerPage> {
  late PdfControllerPinch _pdfController;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewer();
    });
  }

  Future<void> _initViewer() async {
    final localizations = AppLocalizations.of(context);

    // Keep screen awake
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // Immersive fullscreen mode
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    // File validation
    final file = File(widget.tempPdfPath);
    if (!await file.exists()) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorFileNotFound;
      });
      return;
    }

    try {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.tempPdfPath),
      );
      setState(() {
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

  Future<void> _saveDocument() async {
    setState(() {
      _isSaving = true;
    });

    final localizations = AppLocalizations.of(context);
    try {
      final scannedPages = ref.read(scanSessionProvider);
      final originalTempImagePaths = scannedPages.map((f) => f.path).toList();

      final useCase = ref.read(scanDocumentUseCaseProvider);
      
      // Move PDF from temp storage to final target, write metadata, and delete temp images
      await useCase.saveFinalDocument(
        widget.tempPdfPath,
        widget.documentName,
        originalTempImagePaths,
      );

      // Clear scan session state variables (empties file cache)
      ref.read(scanSessionProvider.notifier).clearSession();

      _showSnackBar(localizations.fileImportSuccess);

      if (mounted) {
        // Go straight back to Home and clear viewer stack
        context.go(AppRouter.homePath);
      }
    } catch (e) {
      _showSnackBar(e.toString());
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    // Disable screen awake
    try {
      WakelockPlus.disable();
    } catch (_) {}

    // Restore overlays
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } catch (_) {}

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
          title: Text(widget.documentName),
          centerTitle: true,
        ),
        body: _buildSkeleton(context),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.documentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              if (_totalPages > 0)
                Center(
                  child: Text(
                    localizations.pageIndicatorText(_currentPage, _totalPages),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Finalize document save action
              TextButton.icon(
                onPressed: _saveDocument,
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(localizations.saveButtonLabel),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: PdfViewPinch(
                  controller: _pdfController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
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
        ),
        if (_isSaving)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        if (_isSaving)
          Center(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      localizations.savingLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
