// lib/features/folders/presentation/pages/folders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../../../../features/documents/domain/models/document.dart';
import '../../../../features/documents/presentation/providers/document_providers.dart';

class FoldersPage extends ConsumerStatefulWidget {
  final String? initialFolderType;

  const FoldersPage({
    super.key,
    this.initialFolderType,
  });

  @override
  ConsumerState<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends ConsumerState<FoldersPage> {
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _selectedFolder = widget.initialFolderType;
  }

  @override
  void didUpdateWidget(FoldersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFolderType != oldWidget.initialFolderType) {
      setState(() {
        _selectedFolder = widget.initialFolderType;
      });
    }
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

  String _getFolderName(String type, AppLocalizations localizations) {
    return type == 'pdf' ? 'PDF Documents' : 'Scanned Images';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final asyncDocuments = ref.watch(documentListProvider);

    final accentColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final primaryTextColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    return PopScope(
      canPop: _selectedFolder == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _selectedFolder = null);
      },
      child: ResponsiveScaffold(
        currentPath: AppRouter.foldersPath,
        title: _selectedFolder == null
            ? Text(
                localizations.navFolders,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              )
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => setState(() => _selectedFolder = null),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getFolderName(_selectedFolder!, localizations),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
        body: asyncDocuments.when(
          data: (documents) {
            // Folders Overview Mode
            if (_selectedFolder == null) {
              final pdfDocs = documents.where((d) => d.fileType == DocumentType.pdf).toList();
              final imageDocs = documents.where((d) => d.fileType == DocumentType.image).toList();

              String getLatestDateStr(List<Document> docs) {
                if (docs.isEmpty) return 'No documents';
                final latest = docs.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
                return 'Updated ${formatFriendlyDate(latest.updatedAt, context)}';
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AppCard(
                      onTap: () => setState(() => _selectedFolder = 'pdf'),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_rounded,
                            color: accentColor,
                            size: 64,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PDF Documents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pdfDocs.length} items • ${getLatestDateStr(pdfDocs)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppCard(
                    onTap: () => setState(() => _selectedFolder = 'image'),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_rounded,
                          color: accentColor,
                          size: 64,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scanned Images',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${imageDocs.length} items • ${getLatestDateStr(imageDocs)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Folder Detail Mode
            final filteredDocs = documents
                .where((d) => d.fileType == (_selectedFolder == 'pdf' ? DocumentType.pdf : DocumentType.image))
                .toList();

            if (filteredDocs.isEmpty) {
              return const AppEmptyState(
                icon: Icons.folder_open_rounded,
                message: 'This folder is empty.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = filteredDocs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    radius: 20,
                    onTap: () => _openDocument(doc),
                    padding: EdgeInsets.zero,
                    child: AppListTile(
                      leading: Hero(
                        tag: doc.id,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            doc.fileType == DocumentType.pdf
                                ? Icons.picture_as_pdf_rounded
                                : Icons.image_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                      ),
                      title: doc.name,
                      subtitle: '${formatFileSize(doc.fileSize)} • ${formatFriendlyDate(doc.createdAt, context)}',
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => AppEmptyState(
            icon: Icons.error_outline_rounded,
            message: localizations.errorGeneric(err.toString()),
          ),
        ),
      ),
    );
  }
}
