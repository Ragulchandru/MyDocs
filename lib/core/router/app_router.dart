// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/folders/presentation/pages/folders_page.dart';
import '../../features/recycle_bin/presentation/pages/recycle_bin_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static const String homePath = '/';
  static const String foldersPath = '/folders';
  static const String recycleBinPath = '/recycle-bin';
  static const String settingsPath = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: [
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: foldersPath,
        builder: (context, state) => const FoldersPage(),
      ),
      GoRoute(
        path: recycleBinPath,
        builder: (context, state) => const RecycleBinPage(),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );

  // Private constructor to prevent instantiation
  AppRouter._();
}
