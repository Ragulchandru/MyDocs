// lib/features/documents/presentation/pages/scan_session_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/usecases/scan_document_usecase.dart';
import '../providers/document_providers.dart';
import '../providers/scan_session_provider.dart';

class ScanSessionPage extends ConsumerStatefulWidget {
  final String initialPagePath;

  const ScanSessionPage({
    super.key,
    required this.initialPagePath,
  });

  @override
  ConsumerState<ScanSessionPage> createState() => _ScanSessionPageState();
}

class _ScanSessionPageState extends ConsumerState<ScanSessionPage> {
  bool _isGeneratingPdf = false;
  bool _isScanning = false;
  String? _previewPdfPath;
  bool _isPreparingPreview = false;

  @override
  void initState() {
    super.initState();
    // Safely populate initial scanned page inside microtask
    Future.microtask(() {
      ref.read(scanSessionProvider.notifier).clearSession();
      ref.read(scanSessionProvider.notifier).addPage(File(widget.initialPagePath));
    });
  }

  @override
  void dispose() {
    if (_previewPdfPath != null) {
      try {
        final f = File(_previewPdfPath!);
        if (f.existsSync()) {
          f.deleteSync();
        }
      } catch (_) {}
    }
    try {
      ref.read(scanSessionProvider.notifier).clearSession();
    } catch (_) {}
    super.dispose();
  }

  Future<bool> _showDiscardDialog() async {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.saveDialogTitle),
          content: Text(localizations.errorScanFailed), // Discard warning fallback
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancelButton),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.okButton),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleCancel() async {
    final scannedPages = ref.read(scanSessionProvider);
    if (scannedPages.isNotEmpty) {
      final shouldDiscard = await _showDiscardDialog();
      if (!shouldDiscard) return;
    }
    if (_previewPdfPath != null) {
      try {
        final f = File(_previewPdfPath!);
        if (f.existsSync()) {
          f.deleteSync();
        }
      } catch (_) {}
      _previewPdfPath = null;
    }
    ref.read(scanSessionProvider.notifier).clearSession();
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _addPage() async {
    if (_isScanning || _isGeneratingPdf || _isPreparingPreview) return;
    final localizations = AppLocalizations.of(context);
    setState(() => _isScanning = true);

    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      debugPrint('[ScanTiming] _addPage: Before launching Google ML Kit scanner');
    }

    try {
      final scannerService = ref.read(documentScannerServiceProvider);
      if (kDebugMode) debugPrint('[ScanTiming] _addPage: Scanner launch initiated');

      final File? scannedFile = await scannerService.scanDocument();

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] _addPage: Google ML Kit native scanner result returned to Flutter: ${stopwatch.elapsedMilliseconds} ms');
      }

      if (scannedFile != null) {
        if (kDebugMode && stopwatch != null) stopwatch.reset();
        final fileExists = await scannedFile.exists();
        final fileLength = fileExists ? await scannedFile.length() : 0;
        if (kDebugMode && stopwatch != null) {
          debugPrint('[ScanTiming] _addPage: File existence/readability validation: ${stopwatch.elapsedMilliseconds} ms (size: $fileLength bytes)');
        }
        ref.read(scanSessionProvider.notifier).addPage(scannedFile);
      }
    } catch (_) {
      _showSnackBar(localizations.errorCameraPermission);
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _replacePage(int index) async {
    if (_isScanning || _isGeneratingPdf || _isPreparingPreview) return;
    final localizations = AppLocalizations.of(context);
    setState(() => _isScanning = true);

    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      debugPrint('[ScanTiming] _replacePage: Before launching Google ML Kit scanner');
    }

    try {
      final scannerService = ref.read(documentScannerServiceProvider);
      if (kDebugMode) debugPrint('[ScanTiming] _replacePage: Scanner launch initiated');

      final File? scannedFile = await scannerService.scanDocument();

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] _replacePage: Google ML Kit native scanner result returned to Flutter: ${stopwatch.elapsedMilliseconds} ms');
      }

      if (scannedFile != null) {
        if (kDebugMode && stopwatch != null) stopwatch.reset();
        final fileExists = await scannedFile.exists();
        final fileLength = fileExists ? await scannedFile.length() : 0;
        if (kDebugMode && stopwatch != null) {
          debugPrint('[ScanTiming] _replacePage: File existence/readability validation: ${stopwatch.elapsedMilliseconds} ms (size: $fileLength bytes)');
        }
        ref.read(scanSessionProvider.notifier).replacePage(index, scannedFile);
      }
    } catch (_) {
      _showSnackBar(localizations.errorCameraPermission);
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<String?> _showSaveDocumentDialog() {
    final localizations = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isSaveEnabled = false;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.saveDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLength: 100,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: localizations.saveDialogHint,
                      helperText: localizations.saveDialogHintExample,
                      counterText: '',
                    ),
                    onChanged: (text) {
                      final isValid = text.trim().isNotEmpty;
                      if (isValid != isSaveEnabled) {
                        setDialogState(() {
                          isSaveEnabled = isValid;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancelButton),
                ),
                ElevatedButton(
                  onPressed: isSaveEnabled
                      ? () => Navigator.of(context).pop(controller.text)
                      : null,
                  child: Text(localizations.saveButtonLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPreview() async {
    if (_isPreparingPreview || _isGeneratingPdf || _isScanning) return;
    final scannedPages = ref.read(scanSessionProvider);
    if (scannedPages.isEmpty) return;

    final localizations = AppLocalizations.of(context);

    setState(() {
      _isPreparingPreview = true;
    });

    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      debugPrint('[ScanTiming] Preview PDF generation initiated');
    }

    try {
      if (_previewPdfPath != null) {
        try {
          final oldFile = File(_previewPdfPath!);
          if (oldFile.existsSync()) {
            oldFile.deleteSync();
          }
        } catch (_) {}
        _previewPdfPath = null;
      }

      final imagePaths = scannedPages.map((f) => f.path).toList();
      final useCase = ref.read(scanDocumentUseCaseProvider);
      
      final tempPreviewPath = await useCase.generateTempPdf(
        imagePaths,
        qualityProfile: DocumentQualityProfile.preview,
      );
      _previewPdfPath = tempPreviewPath;

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] Preview PDF generated successfully in: ${stopwatch.elapsedMilliseconds} ms');
      }

      if (!mounted) return;

      context.push(
        AppRouter.pdfViewerPath,
        extra: {
          'filePath': tempPreviewPath,
          'title': localizations.preview,
          'documentId': null,
        },
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingPreview = false;
        });
      }
    }
  }

  Future<void> _finishPdf() async {
    final scannedPages = ref.read(scanSessionProvider);
    if (scannedPages.isEmpty) return;

    final docName = await _showSaveDocumentDialog();
    if (docName == null) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      debugPrint('[ScanTiming] Final PDF generation initiated');
    }

    String? tempPdfPath;
    try {
      final imagePaths = scannedPages.map((f) => f.path).toList();
      final useCase = ref.read(scanDocumentUseCaseProvider);
      
      // 1. Generate the final PDF inside temporary file storage
      tempPdfPath = await useCase.generateTempPdf(
        imagePaths,
        qualityProfile: DocumentQualityProfile.finalSave,
      );

      // 2. Finalize/save the document directly
      await useCase.saveFinalDocument(
        tempPdfPath,
        docName,
        imagePaths,
      );

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] Final PDF generated and saved successfully in: ${stopwatch.elapsedMilliseconds} ms');
      }

      // Clear the scan session after successfully saving
      ref.read(scanSessionProvider.notifier).clearSession();

      // Clean up temporary preview PDF if exists
      if (_previewPdfPath != null) {
        try {
          final f = File(_previewPdfPath!);
          if (f.existsSync()) {
            f.deleteSync();
          }
        } catch (_) {}
        _previewPdfPath = null;
      }

      if (mounted) {
        context.go(AppRouter.homePath);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
      if (tempPdfPath != null) {
        try {
          final file = File(tempPdfPath);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (_) {}
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  Widget _buildGridCard(File file, int index, ThemeData theme, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Constrain width during decoding cache to save memory
          Positioned.fill(
            child: Image.file(
              file,
              fit: BoxFit.cover,
              cacheWidth: 150, 
            ),
          ),
          // Gradient protection for text labels
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.labelPage(index + 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Replace page action
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  onPressed: (!_isScanning && !_isGeneratingPdf && !_isPreparingPreview) ? () => _replacePage(index) : null,
                  tooltip: localizations.importScan,
                ),
                // Remove page action
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                  onPressed: (!_isScanning && !_isGeneratingPdf && !_isPreparingPreview) ? () => ref.read(scanSessionProvider.notifier).removePage(index) : null,
                  tooltip: localizations.cancelButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannedPages = ref.watch(scanSessionProvider);
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: scannedPages.isEmpty && !_isGeneratingPdf && !_isScanning && !_isPreparingPreview,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isGeneratingPdf || _isScanning || _isPreparingPreview) return;
        await _handleCancel();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: (!_isGeneratingPdf && !_isScanning && !_isPreparingPreview) ? _handleCancel : null,
                tooltip: localizations.cancelButton,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.labelScannedPages, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${scannedPages.length} Pages',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                if (scannedPages.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.visibility_rounded),
                    onPressed: (!_isGeneratingPdf && !_isScanning && !_isPreparingPreview) ? _showPreview : null,
                    tooltip: localizations.preview,
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: scannedPages.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: scannedPages.length,
                            itemBuilder: (context, index) {
                              final file = scannedPages[index];
                              
                              return DragTarget<int>(
                                builder: (context, candidateData, rejectedData) {
                                  return LongPressDraggable<int>(
                                    data: index,
                                    feedback: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 140,
                                        height: 180,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                            cacheWidth: 150,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: _buildGridCard(file, index, theme, localizations),
                                    ),
                                    child: _buildGridCard(file, index, theme, localizations),
                                  );
                                },
                                onWillAcceptWithDetails: (details) => !(_isGeneratingPdf || _isScanning || _isPreparingPreview) && details.data != index,
                                onAcceptWithDetails: (details) {
                                  ref.read(scanSessionProvider.notifier).reorderPages(details.data, index);
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: (!_isGeneratingPdf && !_isScanning && !_isPreparingPreview) ? _addPage : null,
                              icon: const Icon(Icons.add_photo_alternate_outlined),
                              label: Text(localizations.btnAddPage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: (scannedPages.isNotEmpty && !_isGeneratingPdf && !_isScanning && !_isPreparingPreview) ? _finishPdf : null,
                              icon: const Icon(Icons.check_circle_outline_rounded),
                              label: Text(localizations.btnFinish, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isGeneratingPdf)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          if (_isGeneratingPdf)
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        localizations.preparingDocument,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.pleaseWait,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isScanning)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          if (_isScanning)
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        localizations.processingScan,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isPreparingPreview)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          if (_isPreparingPreview)
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        localizations.preparingPreview,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
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
}
