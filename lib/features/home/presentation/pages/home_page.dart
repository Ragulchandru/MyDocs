// lib/features/home/presentation/pages/home_page.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../../../../features/documents/domain/models/document.dart';
import '../../../../features/documents/domain/usecases/import_document_usecase.dart';
import '../../../../features/documents/presentation/providers/document_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isImporting = false;
  String _loadingText = '';

  /// Shows an M3 outlined TextField dialog to input a sanitized document name.
  /// Enforces a 100-character limit and disables Save until non-empty input is typed.
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
                      counterText: '', // Hide length counter for simplified UI
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

  /// Triggers edge-detecting camera scan, prompts for name, converts to PDF, and saves.
  Future<void> _scanDocument() async {
    if (_isImporting) return;

    final localizations = AppLocalizations.of(context);

    try {
      final scannerService = ref.read(documentScannerServiceProvider);
      
      // 1. Scan image via edge detection and photo enhancement
      final scannedFile = await scannerService.scanDocument();

      if (scannedFile == null) {
        _showSnackBar(localizations.errorScanFailed);
        return;
      }

      // 2. Ask user for document title
      final docName = await _showSaveDocumentDialog();
      if (docName == null) {
        return; // User cancelled title input
      }

      // 3. Convert to PDF and save metadata
      setState(() {
        _isImporting = true;
        _loadingText = localizations.generatingPdfLabel;
      });

      // Quick delay for smoother overlay transition
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      setState(() {
        _loadingText = localizations.savingLabel;
      });

      await ref.read(scanDocumentUseCaseProvider).execute(scannedFile.path, docName);

      _showSnackBar(localizations.fileImportSuccess);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission') || errorStr.contains('camera')) {
        _showSnackBar(localizations.errorCameraPermission);
      } else {
        _showSnackBar(localizations.errorGeneric(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _loadingText = '';
        });
      }
    }
  }

  /// Handles picking and importing a file based on [DocumentType].
  Future<void> _importFile(DocumentType type) async {
    // Prevent overlapping imports
    if (_isImporting) return;

    final localizations = AppLocalizations.of(context);
    setState(() => _isImporting = true);

    try {
      FilePickerResult? result;

      if (type == DocumentType.pdf) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        );
      }

      if (result == null || result.files.isEmpty) {
        // User cancelled the file selection
        _showSnackBar(localizations.errorUserCancelled);
        return;
      }

      final file = result.files.first;
      final path = file.path;

      if (path == null) {
        throw Exception('File path is null');
      }

      // Execute use case to copy file and save metadata
      await ref.read(importDocumentUseCaseProvider).execute(path, file.name);

      _showSnackBar(localizations.fileImportSuccess);
    } on UnsupportedFileTypeException {
      _showSnackBar(localizations.unsupportedFileTypeError);
    } on MimeTypeMismatchException {
      _showSnackBar(localizations.mimeMismatchError);
    } catch (e) {
      // Check for generic permissions or file exceptions
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('permission')) {
        _showSnackBar(localizations.errorPermission);
      } else {
        _showSnackBar(localizations.errorGeneric(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Displays the Material 3 Bottom Sheet containing PDF and Image import actions.
  void _showImportBottomSheet() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    localizations.importSheetTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    localizations.importPdf,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importFile(DocumentType.pdf);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.image_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    localizations.importImage,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importFile(DocumentType.image);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    localizations.importScan,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _scanDocument();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final asyncDocuments = ref.watch(documentListProvider);

    return Stack(
      children: [
        ResponsiveScaffold(
          currentPath: AppRouter.homePath,
          title: Text(localizations.appTitle),
          floatingActionButton: FloatingActionButton.large(
            onPressed: _showImportBottomSheet,
            tooltip: localizations.importSheetTitle,
            child: const Icon(Icons.add_rounded, size: 36),
          ),
          body: asyncDocuments.when(
            data: (documents) {
              if (documents.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_rounded,
                          size: 80,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.emptyStateText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            doc.fileType == DocumentType.pdf
                                ? Icons.picture_as_pdf_rounded
                                : Icons.image_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          doc.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${formatFileSize(doc.fileSize)} • ${formatFriendlyDate(doc.createdAt, context)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          // View functionality will be implemented in later phases
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  localizations.errorGeneric(err.toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
        ),
        
        // Full screen loading overlay shown during document import
        if (_isImporting)
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        if (_isImporting)
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
                      _loadingText.isNotEmpty ? _loadingText : localizations.importingLabel,
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
