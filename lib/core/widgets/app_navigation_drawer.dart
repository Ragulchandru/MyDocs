// lib/core/widgets/app_navigation_drawer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    final groupedBgColor = isDark ? const Color(0xFF111111) : const Color(0xFFF7F7F9);
    final primaryTextColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);
    final activeBgColor = isDark ? const Color(0x1F0A84FF) : const Color(0x1F007AFF); // 12% opacity
    final activeColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);

    Widget item(int index, IconData icon, String label) {
      final isSelected = _getSelectedIndex() == index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: InkWell(
          onTap: () => _onDestinationSelected(context, index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? activeBgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : secondaryTextColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? activeColor : primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: groupedBgColor,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apple-style Profile Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: activeColor,
                    child: const Text(
                      'MD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.appTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Local User',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Text(
                localizations.appTagline,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(),
            ),
            const SizedBox(height: 16),

            // Navigation menu entries
            item(0, Icons.home_rounded, localizations.navHome),
            item(1, Icons.folder_rounded, localizations.navFolders),
            item(2, Icons.delete_rounded, localizations.navRecycleBin),
            item(3, Icons.settings_rounded, localizations.navSettings),
          ],
        ),
      ),
    );
  }
}
