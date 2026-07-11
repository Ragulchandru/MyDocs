// lib/features/recycle_bin/presentation/pages/recycle_bin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../../../../features/documents/domain/models/document.dart';
import '../../../../features/documents/presentation/providers/document_providers.dart';
import '../../../../features/documents/presentation/widgets/document_thumbnail.dart';
import '../../../../features/settings/presentation/providers/settings_providers.dart';

class RecycleBinPage extends ConsumerStatefulWidget {
  const RecycleBinPage({super.key});

  @override
  ConsumerState<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends ConsumerState<RecycleBinPage> {
  @override
  void dispose() {
    try {
      ref.read(recycleBinSelectionProvider.notifier).clearSelection();
    } catch (_) {}
    super.dispose();
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

  void _confirmPermanentDeleteDialog(List<String> ids) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deleteColor = isDark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    String titleText;
    if (ids.length == 1) {
      titleText = localizations.deletePermanentlyTitle;
    } else {
      final count = ids.length;
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ta') {
        titleText = '$count ஆவணங்களை நிரந்தரமாக நீக்கவா?';
      } else {
        titleText = 'Delete $count documents permanently?';
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleText),
          content: Text(
            localizations.deletePermanentlyMessage,
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
                await ref.read(documentRepositoryProvider).permanentlyDeleteMany(ids);
                ref.read(recycleBinSelectionProvider.notifier).clearSelection();
                _showSnackBar(ids.length == 1 ? 'Document permanently deleted.' : '${ids.length} documents permanently deleted.');
              },
              child: Text(
                'Delete',
                style: TextStyle(color: deleteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreDocuments(List<String> ids) async {
    await ref.read(documentRepositoryProvider).restoreMany(ids);
    ref.read(recycleBinSelectionProvider.notifier).clearSelection();
    _showSnackBar(ids.length == 1 ? 'Document restored.' : '${ids.length} documents restored.');
  }

  void _showDeletedDocumentActions(Document doc) {
    final localizations = AppLocalizations.of(context);
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
                  leading: Icon(Icons.restore_rounded, color: accentColor),
                  title: localizations.restore,
                  onTap: () {
                    Navigator.of(context).pop();
                    _restoreDocuments([doc.id]);
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.delete_forever_rounded, color: deleteColor),
                  title: localizations.deletePermanently,
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmPermanentDeleteDialog([doc.id]);
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
    final isDark = theme.brightness == Brightness.dark;
    final asyncDocuments = ref.watch(deletedDocumentListProvider);
    final viewMode = ref.watch(viewModeProvider);
    final isSelectionMode = ref.watch(isRecycleBinSelectionModeProvider);
    final accentColor = theme.colorScheme.primary;

    return Stack(
      children: [
        ResponsiveScaffold(
          currentPath: AppRouter.recycleBinPath,
          hasInternalBackState: isSelectionMode,
          onInternalBack: () => ref.read(recycleBinSelectionProvider.notifier).clearSelection(),
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => ref.read(recycleBinSelectionProvider.notifier).clearSelection(),
                  )
                : null,
            title: isSelectionMode
                ? Consumer(
                    builder: (context, ref, child) {
                      final selectedIds = ref.watch(recycleBinSelectionProvider);
                      return Text(
                        localizations.selectedCount(selectedIds.length),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  )
                : Text(
                    localizations.navRecycleBin,
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
                          ref.read(recycleBinSelectionProvider.notifier).selectAll(documents.map((d) => d.id));
                        });
                      },
                      tooltip: localizations.selectAll,
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore_rounded),
                      onPressed: () {
                        final selectedIds = ref.read(recycleBinSelectionProvider);
                        _restoreDocuments(selectedIds.toList());
                      },
                      tooltip: localizations.restore,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                      onPressed: () {
                        final selectedIds = ref.read(recycleBinSelectionProvider);
                        _confirmPermanentDeleteDialog(selectedIds.toList());
                      },
                      tooltip: localizations.deletePermanently,
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
            body: asyncDocuments.when(
              data: (documents) {
                // Safely filter selection state to valid documents post-frame if needed
                final activeIds = documents.map((d) => d.id).toSet();
                final selectedIds = ref.read(recycleBinSelectionProvider);
                final validSelectedIds = selectedIds.intersection(activeIds);
                if (validSelectedIds.length != selectedIds.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(recycleBinSelectionProvider.notifier).selectAll(validSelectedIds);
                  });
                }

                if (documents.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.delete_outline_rounded,
                    message: 'Your Recycle Bin is empty.\nSoft-deleted documents are kept here for restoration.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(deletedDocumentListProvider),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
                                    final doc = documents[index];
                                    return _RecycleBinGridCard(
                                      doc: doc,
                                      isSelectionMode: isSelectionMode,
                                      theme: theme,
                                      localizations: localizations,
                                      accentColor: accentColor,
                                      isDark: isDark,
                                      onOpen: _showDeletedDocumentActions,
                                    );
                                  },
                                  childCount: documents.length,
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final doc = documents[index];
                                    return _RecycleBinListCard(
                                      doc: doc,
                                      isSelectionMode: isSelectionMode,
                                      theme: theme,
                                      localizations: localizations,
                                      accentColor: accentColor,
                                      isDark: isDark,
                                      onOpen: _showDeletedDocumentActions,
                                    );
                                  },
                                  childCount: documents.length,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => AppEmptyState(
                icon: Icons.error_outline_rounded,
                message: localizations.errorGeneric(err.toString()),
              ),
            ),
          ),
        ],
      );
    }
}

class _RecycleBinGridCard extends ConsumerWidget {
  final Document doc;
  final bool isSelectionMode;
  final ThemeData theme;
  final AppLocalizations localizations;
  final Color accentColor;
  final bool isDark;
  final void Function(Document) onOpen;

  const _RecycleBinGridCard({
    required this.doc,
    required this.isSelectionMode,
    required this.theme,
    required this.localizations,
    required this.accentColor,
    required this.isDark,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(recycleBinSelectionProvider.select((set) => set.contains(doc.id)));

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          ref.read(recycleBinSelectionProvider.notifier).toggle(doc.id);
        } else {
          onOpen(doc);
        }
      },
      onLongPress: () {
        ref.read(recycleBinSelectionProvider.notifier).toggle(doc.id);
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
                          onPressed: () => onOpen(doc),
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
  }
}

class _RecycleBinListCard extends ConsumerWidget {
  final Document doc;
  final bool isSelectionMode;
  final ThemeData theme;
  final AppLocalizations localizations;
  final Color accentColor;
  final bool isDark;
  final void Function(Document) onOpen;

  const _RecycleBinListCard({
    required this.doc,
    required this.isSelectionMode,
    required this.theme,
    required this.localizations,
    required this.accentColor,
    required this.isDark,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(recycleBinSelectionProvider.select((set) => set.contains(doc.id)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (isSelectionMode) {
            ref.read(recycleBinSelectionProvider.notifier).toggle(doc.id);
          } else {
            onOpen(doc);
          }
        },
        onLongPress: () {
          ref.read(recycleBinSelectionProvider.notifier).toggle(doc.id);
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
                    onPressed: () => onOpen(doc),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
