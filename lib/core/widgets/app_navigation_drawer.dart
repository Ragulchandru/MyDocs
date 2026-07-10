// lib/core/widgets/app_navigation_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class AppNavigationDrawer extends StatelessWidget {
  final String currentPath;
  final bool isPermanent;

  const AppNavigationDrawer({
    required this.currentPath,
    this.isPermanent = false,
    super.key,
  });

  int _getSelectedIndex() {
    switch (currentPath) {
      case AppRouter.homePath:
        return 0;
      case AppRouter.foldersPath:
        return 1;
      case AppRouter.recycleBinPath:
        return 2;
      case AppRouter.settingsPath:
        return 3;
      default:
        return 0;
    }
  }

  void _onDestinationSelected(BuildContext context, int index) {
    String targetPath;
    switch (index) {
      case 0:
        targetPath = AppRouter.homePath;
        break;
      case 1:
        targetPath = AppRouter.foldersPath;
        break;
      case 2:
        targetPath = AppRouter.recycleBinPath;
        break;
      case 3:
        targetPath = AppRouter.settingsPath;
        break;
      default:
        targetPath = AppRouter.homePath;
    }

    if (currentPath == targetPath) {
      if (!isPermanent) {
        Navigator.of(context).pop(); // Close drawer
      }
      return;
    }

    if (!isPermanent) {
      Navigator.of(context).pop(); // Close drawer before navigation
    }
    context.go(targetPath);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Padding helper to respect large touch targets (48dp height minimum for content)
    return NavigationDrawer(
      selectedIndex: _getSelectedIndex(),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                localizations.appTagline,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 28, endIndent: 28),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              localizations.navHome,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.folder_outlined),
          selectedIcon: const Icon(Icons.folder_rounded),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              localizations.navFolders,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.delete_outline_rounded),
          selectedIcon: const Icon(Icons.delete_rounded),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              localizations.navRecycleBin,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              localizations.navSettings,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
