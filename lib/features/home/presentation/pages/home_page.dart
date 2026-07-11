import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../../../../features/documents/domain/models/document.dart';
import '../../../../features/documents/domain/usecases/import_document_usecase.dart';
import '../../../../features/documents/presentation/providers/document_providers.dart';
import '../../../../features/documents/presentation/widgets/rename_document_dialog.dart';
import '../../../../features/documents/presentation/widgets/document_info_bottom_sheet.dart';
import '../../../../features/documents/presentation/widgets/document_thumbnail.dart';
import '../../../../features/settings/presentation/providers/settings_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isImporting = false;
  bool _isScanning = false;
  String _searchQuery = '';
  late ScrollController _scrollController;
  bool _isFabExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    try {
      ref.read(selectionProvider.notifier).clearSelection();
    } catch (_) {}
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabExpanded) {
        setState(() => _isFabExpanded = false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabExpanded) {
        setState(() => _isFabExpanded = true);
      }
    }
  }

  String _getSearchHint(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ta') {
      return 'ஆவணங்களைத் தேடுங்கள்';
    }
    return 'Search documents';
  }

  /// Triggers camera document scan
  Future<void> _scanDocument() async {
    if (_isImporting || _isScanning) return;
    final localizations = AppLocalizations.of(context);

    setState(() => _isScanning = true);

    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      debugPrint('[ScanTiming] Before launching Google ML Kit scanner');
    }

    try {
      final scannerService = ref.read(documentScannerServiceProvider);
      if (kDebugMode) debugPrint('[ScanTiming] Scanner launch initiated');

      final scannedFile = await scannerService.scanDocument();

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] Google ML Kit native scanner result returned to Flutter: ${stopwatch.elapsedMilliseconds} ms');
      }

      if (scannedFile == null) {
        setState(() => _isScanning = false);
        _showSnackBar(localizations.errorScanFailed);
        return;
      }

      if (kDebugMode && stopwatch != null) {
        stopwatch.reset();
      }

      final fileExists = await scannedFile.exists();
      final fileLength = fileExists ? await scannedFile.length() : 0;

      if (kDebugMode && stopwatch != null) {
        debugPrint('[ScanTiming] File existence/readability validation: ${stopwatch.elapsedMilliseconds} ms (size: $fileLength bytes)');
      }

      if (!mounted) return;
      context.push(AppRouter.scanSessionPath, extra: scannedFile.path);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('permission') || errorStr.contains('camera')) {
        _showSnackBar(localizations.errorCameraPermission);
      } else {
        _showSnackBar(localizations.errorGeneric(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  /// Handles picking and importing files
  Future<void> _importFile(DocumentType type) async {
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
        _showSnackBar(localizations.errorUserCancelled);
        return;
      }

      final file = result.files.first;
      final path = file.path;
      if (path == null) throw Exception('File path is null');

      await ref.read(importDocumentUseCaseProvider).execute(path, file.name);
      _showSnackBar(localizations.fileImportSuccess);
    } on UnsupportedFileTypeException {
      _showSnackBar(localizations.unsupportedFileTypeError);
    } on MimeTypeMismatchException {
      _showSnackBar(localizations.mimeMismatchError);
    } catch (e) {
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

  /// Shows the Apple-style import actions bottom sheet
  void _showImportBottomSheet() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextCol = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final accentColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    localizations.importSheetTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextCol,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppListTile(
                  leading: Icon(Icons.picture_as_pdf_rounded, color: accentColor, size: 26),
                  title: localizations.importPdf,
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importFile(DocumentType.pdf);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.image_rounded, color: accentColor, size: 26),
                  title: localizations.importImage,
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importFile(DocumentType.image);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: accentColor, size: 26),
                  title: localizations.importScan,
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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

  /// Displays options sheet for a selected document (iOS actions style)
  void _showDocumentActions(Document doc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final deleteColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    doc.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppListTile(
                  leading: Icon(Icons.open_in_new_rounded, color: accentColor),
                  title: 'Open',
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDocument(doc);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.edit_outlined, color: accentColor),
                  title: 'Rename',
                  onTap: () {
                    Navigator.of(context).pop();
                    _renameDocumentDialog(doc);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.share_rounded, color: accentColor),
                  title: 'Share',
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareDocument(doc);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.info_outline_rounded, color: accentColor),
                  title: 'Document Info',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDocumentInfo(doc);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: deleteColor),
                  title: 'Delete',
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmMoveToRecycleBinDialog([doc.id]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDocument(Document doc) {
    final extra = {
      'documentId': doc.id,
      'filePath': doc.filePath,
      'title': doc.name,
    };
    if (doc.fileType == DocumentType.pdf) {
      context.push(AppRouter.pdfViewerPath, extra: extra);
    } else if (doc.fileType == DocumentType.image) {
      context.push(AppRouter.imageViewerPath, extra: extra);
    }
  }

  void _shareDocument(Document doc) async {
    try {
      await Share.shareXFiles([XFile(doc.filePath)], text: doc.name);
    } catch (e) {
      _showSnackBar('Unable to share document: $e');
    }
  }

  void _showDocumentInfo(Document doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return DocumentInfoBottomSheet(document: doc);
      },
    );
  }

  void _renameDocumentDialog(Document doc) {
    showDialog(
      context: context,
      builder: (context) {
        return RenameDocumentDialog(
          document: doc,
          onRename: (newName) async {
            final updatedDoc = doc.copyWith(name: newName, updatedAt: DateTime.now());
            await ref.read(documentRepositoryProvider).saveDocument(updatedDoc);
            _showSnackBar('Document renamed successfully.');
          },
        );
      },
    );
  }

  void _confirmMoveToRecycleBinDialog(List<String> ids) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deleteColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    String titleText;
    String messageText;
    if (ids.length == 1) {
      titleText = localizations.moveToRecycleBinTitle;
      messageText = localizations.moveToRecycleBinMessage;
    } else {
      final count = ids.length;
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ta') {
        titleText = '$count ஆவணங்களை குப்பைத் தொட்டிக்கு நகர்த்தவா?';
      } else {
        titleText = 'Move $count documents to Recycle Bin?';
      }
      messageText = localizations.moveToRecycleBinMessageMany;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(
            messageText,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancelButton,
                style: TextStyle(color: isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(documentRepositoryProvider).moveManyToRecycleBin(ids);
                ref.read(selectionProvider.notifier).clearSelection();
                _showSnackBar(ids.length == 1 ? 'Document moved to Recycle Bin.' : '${ids.length} documents moved to Recycle Bin.');
              },
              child: Text(
                'Move',
                style: TextStyle(color: deleteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncDocuments = ref.watch(documentListProvider);
    final viewMode = ref.watch(viewModeProvider);
    final selectedIds = ref.watch(selectionProvider);
    final isSelectionMode = selectedIds.isNotEmpty;
    final accentColor = theme.colorScheme.primary;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(selectionProvider.notifier).clearSelection();
      },
      child: Stack(
        children: [
          ResponsiveScaffold(
            currentPath: AppRouter.homePath,
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => ref.read(selectionProvider.notifier).clearSelection(),
                  )
                : null,
            title: isSelectionMode
                ? Text(
                    localizations.selectedCount(selectedIds.length),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  )
                : Text(
                    localizations.appTitle,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                    ),
                  ),
            actions: isSelectionMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all_rounded),
                      onPressed: () {
                        asyncDocuments.whenData((documents) {
                          final filteredDocs = documents
                              .where((doc) => doc.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                              .toList();
                          ref.read(selectionProvider.notifier).selectAll(filteredDocs.map((d) => d.id));
                        });
                      },
                      tooltip: localizations.selectAll,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      onPressed: () async {
                        final selectedDocs = <Document>[];
                        asyncDocuments.whenData((documents) {
                          for (final id in selectedIds) {
                            final doc = documents.firstWhere((d) => d.id == id);
                            selectedDocs.add(doc);
                          }
                        });

                        final filesToShare = <XFile>[];
                        for (final doc in selectedDocs) {
                          final file = File(doc.filePath);
                          if (await file.exists()) {
                            filesToShare.add(
                              XFile(
                                doc.filePath,
                                name: doc.name + doc.extension,
                                mimeType: doc.fileType == DocumentType.pdf ? 'application/pdf' : 'image/jpeg',
                              ),
                            );
                          }
                        }

                        if (filesToShare.isNotEmpty) {
                          try {
                            await Share.shareXFiles(filesToShare);
                          } catch (e) {
                            _showSnackBar('Sharing failed: $e');
                          }
                          ref.read(selectionProvider.notifier).clearSelection();
                        } else {
                          _showSnackBar(localizations.noValidFilesToShare);
                        }
                      },
                      tooltip: localizations.shareSelected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () {
                        _confirmMoveToRecycleBinDialog(selectedIds.toList());
                      },
                      tooltip: localizations.moveToRecycleBin,
                    ),
                  ]
                : [
                    IconButton(
                      icon: Icon(viewMode == 'grid' ? Icons.view_list_rounded : Icons.grid_view_rounded),
                      onPressed: () {
                        ref.read(viewModeProvider.notifier).toggleViewMode();
                      },
                      tooltip: viewMode == 'grid' ? 'List View' : 'Grid View',
                    ),
                  ],
            floatingActionButton: isSelectionMode
                ? null
                : FloatingActionButton.extended(
                    onPressed: _showImportBottomSheet,
                    isExtended: _isFabExpanded,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(localizations.importSheetTitle),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
            body: asyncDocuments.when(
              data: (documents) {
                // Safely filter selection state to valid documents post-frame if needed
                final activeIds = documents.map((d) => d.id).toSet();
                final validSelectedIds = selectedIds.intersection(activeIds);
                if (validSelectedIds.length != selectedIds.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectionProvider.notifier).selectAll(validSelectedIds);
                  });
                }

                final filteredDocs = documents
                    .where((doc) => doc.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(documentListProvider),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Search Bar
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        sliver: SliverToBoxAdapter(
                          child: AppSearchBar(
                            hintText: _getSearchHint(context),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                      ),

                      // Documents Header
                      SliverToBoxAdapter(
                        child: AppSectionHeader(
                          title: _searchQuery.isEmpty ? 'All Documents' : 'Search Results',
                        ),
                      ),

                      // Documents list or grid
                      if (filteredDocs.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyState(
                            icon: _searchQuery.isEmpty ? Icons.description_rounded : Icons.search_off_rounded,
                            message: _searchQuery.isEmpty
                                ? 'No documents yet\nTap + to import or scan your first document.'
                                : 'No documents match your search query.',
                            actionLabel: _searchQuery.isEmpty ? 'Add Document' : null,
                            onAction: _searchQuery.isEmpty ? _showImportBottomSheet : null,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          sliver: viewMode == 'grid'
                              ? SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 220,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.82,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final doc = filteredDocs[index];
                                      final isSelected = selectedIds.contains(doc.id);
                                      return GestureDetector(
                                        onTap: () {
                                          if (isSelectionMode) {
                                            ref.read(selectionProvider.notifier).toggle(doc.id);
                                          } else {
                                            _openDocument(doc);
                                          }
                                        },
                                        onLongPress: () {
                                          ref.read(selectionProvider.notifier).toggle(doc.id);
                                        },
                                        child: AppCard(
                                          key: ValueKey(doc.id),
                                          radius: 16,
                                          padding: EdgeInsets.zero,
                                          color: isSelected ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08) : null,
                                          borderColor: isSelected ? accentColor : null,
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(16),
                                                        topRight: Radius.circular(16),
                                                      ),
                                                      child: DocumentThumbnail(
                                                        document: doc,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                doc.name,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 2),
                                                              Text(
                                                                '${doc.fileType == DocumentType.pdf ? 'PDF' : doc.extension.replaceAll('.', '').toUpperCase()} • ${formatFileSize(doc.fileSize)}',
                                                                style: const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (!isSelectionMode)
                                                          IconButton(
                                                            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(),
                                                            onPressed: () => _showDocumentActions(doc),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (isSelectionMode)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.8),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected ? Colors.transparent : Colors.grey,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.all(2),
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      size: 14,
                                                      color: isSelected ? Colors.white : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: filteredDocs.length,
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final doc = filteredDocs[index];
                                      final isSelected = selectedIds.contains(doc.id);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (isSelectionMode) {
                                              ref.read(selectionProvider.notifier).toggle(doc.id);
                                            } else {
                                              _openDocument(doc);
                                            }
                                          },
                                          onLongPress: () {
                                            ref.read(selectionProvider.notifier).toggle(doc.id);
                                          },
                                          child: AppCard(
                                            key: ValueKey(doc.id),
                                            radius: 16,
                                            padding: EdgeInsets.zero,
                                            color: isSelected ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08) : null,
                                            borderColor: isSelected ? accentColor : null,
                                            child: AppListTile(
                                              leading: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: 44,
                                                  height: 44,
                                                  child: DocumentThumbnail(
                                                    document: doc,
                                                    height: 44,
                                                  ),
                                                ),
                                              ),
                                              title: doc.name,
                                              subtitle: '${doc.fileType == DocumentType.pdf ? 'PDF' : doc.extension.replaceAll('.', '').toUpperCase()} • ${formatFileSize(doc.fileSize)}',
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (isSelectionMode) ...[
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: isSelected ? accentColor : Colors.transparent,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: isSelected ? Colors.transparent : Colors.grey,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets.all(2),
                                                      child: Icon(
                                                        Icons.check_rounded,
                                                        size: 14,
                                                        color: isSelected ? Colors.white : Colors.transparent,
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    IconButton(
                                                      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                                                      onPressed: () => _showDocumentActions(doc),
                                                    ),
                                                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: filteredDocs.length,
                                  ),
                                ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  message: localizations.errorGeneric(err.toString()),
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
                        localizations.importingLabel,
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

          // Full screen loading overlay shown during document scan
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
        ],
      ),
    );
  }
}
