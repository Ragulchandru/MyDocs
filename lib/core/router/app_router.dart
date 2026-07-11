import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/folders/presentation/pages/folders_page.dart';
import '../../features/recycle_bin/presentation/pages/recycle_bin_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/documents/presentation/pages/pdf_viewer_page.dart';
import '../../features/documents/presentation/pages/image_viewer_page.dart';
import '../../features/documents/presentation/pages/scan_session_page.dart';

class AppRouter {
  static const String homePath = '/';
  static const String foldersPath = '/folders';
  static const String recycleBinPath = '/recycle-bin';
  static const String settingsPath = '/settings';
  static const String pdfViewerPath = '/pdf-viewer';
  static const String imageViewerPath = '/image-viewer';
  static const String scanSessionPath = '/scan-session';

  /// Reusable transition builder that performs a lightweight fade + subtle horizontal slide
  static CustomTransitionPage<T> _buildSmoothTransitionPage<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.04, 0.0), // Very small horizontal slide
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        pageBuilder: (context, state) => _buildSmoothTransitionPage(
          state: state,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: foldersPath,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final folderType = extra?['folderType'] as String?;
          return _buildSmoothTransitionPage(
            state: state,
            child: FoldersPage(initialFolderType: folderType),
          );
        },
      ),
      GoRoute(
        path: recycleBinPath,
        pageBuilder: (context, state) => _buildSmoothTransitionPage(
          state: state,
          child: const RecycleBinPage(),
        ),
      ),
      GoRoute(
        path: settingsPath,
        pageBuilder: (context, state) => _buildSmoothTransitionPage(
          state: state,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: pdfViewerPath,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _buildSmoothTransitionPage(
            state: state,
            child: PdfViewerPage(
              documentId: extra['documentId'] as String?,
              filePath: extra['filePath'] as String,
              title: extra['title'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: imageViewerPath,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _buildSmoothTransitionPage(
            state: state,
            child: ImageViewerPage(
              documentId: extra['documentId'] as String,
              filePath: extra['filePath'] as String,
              title: extra['title'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: scanSessionPath,
        pageBuilder: (context, state) {
          final initialPagePath = state.extra as String;
          return _buildSmoothTransitionPage(
            state: state,
            child: ScanSessionPage(initialPagePath: initialPagePath),
          );
        },
      ),
    ],
  );

  // Private constructor to prevent instantiation
  AppRouter._();
}
