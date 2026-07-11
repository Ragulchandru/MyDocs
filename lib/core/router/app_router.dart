// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/folders/presentation/pages/folders_page.dart';
import '../../features/recycle_bin/presentation/pages/recycle_bin_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/documents/presentation/pages/pdf_viewer_page.dart';
import '../../features/documents/presentation/pages/image_viewer_page.dart';
import '../../features/documents/presentation/pages/scan_session_page.dart';
import '../../features/documents/presentation/pages/pdf_pre_save_viewer_page.dart';

class AppRouter {
  static const String homePath = '/';
  static const String foldersPath = '/folders';
  static const String recycleBinPath = '/recycle-bin';
  static const String settingsPath = '/settings';
  static const String pdfViewerPath = '/pdf-viewer';
  static const String imageViewerPath = '/image-viewer';
  static const String scanSessionPath = '/scan-session';
  static const String pdfPreSaveViewerPath = '/pdf-pre-save-viewer';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: foldersPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final folderType = extra?['folderType'] as String?;
          return FoldersPage(initialFolderType: folderType);
        },
      ),
      GoRoute(
        path: recycleBinPath,
        builder: (context, state) => const RecycleBinPage(),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: pdfViewerPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PdfViewerPage(
            documentId: extra['documentId'] as String?,
            filePath: extra['filePath'] as String,
            title: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: imageViewerPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ImageViewerPage(
            documentId: extra['documentId'] as String,
            filePath: extra['filePath'] as String,
            title: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: scanSessionPath,
        builder: (context, state) {
          final initialPagePath = state.extra as String;
          return ScanSessionPage(initialPagePath: initialPagePath);
        },
      ),
      GoRoute(
        path: pdfPreSaveViewerPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PdfPreSaveViewerPage(
            tempPdfPath: extra['tempPdfPath'] as String,
            documentName: extra['documentName'] as String,
          );
        },
      ),
    ],
  );

  // Private constructor to prevent instantiation
  AppRouter._();
}
