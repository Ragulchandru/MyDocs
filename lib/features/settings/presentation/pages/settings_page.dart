// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _getCurrentLanguageName(Locale? locale) {
    if (locale == null) return 'System Default';
    if (locale.languageCode == 'ta') return 'Tamil (தமிழ்)';
    return 'English';
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Select Language',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppListTile(
                  leading: Icon(Icons.language_rounded, color: accentColor),
                  title: 'English',
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale('en');
                    Navigator.of(context).pop();
                  },
                ),
                AppListTile(
                  leading: Icon(Icons.language_rounded, color: accentColor),
                  title: 'Tamil (தமிழ்)',
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale('ta');
                    Navigator.of(context).pop();
                  },
                ),
                AppListTile(
                  leading: const Icon(Icons.settings_suggest_rounded, color: Colors.grey),
                  title: 'System Default',
                  onTap: () {
                    ref.read(localeProvider.notifier).clearLocale();
                    Navigator.of(context).pop();
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
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);

    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC);

    return ResponsiveScaffold(
      currentPath: AppRouter.settingsPath,
      title: Text(
        localizations.navSettings,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const AppSectionHeader(title: 'Preferences'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: Icon(
                    Icons.language_rounded,
                    color: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
                  ),
                  title: 'App Language',
                  subtitle: _getCurrentLanguageName(currentLocale),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () => _showLanguageSelector(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppSectionHeader(title: 'System Info'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Colors.grey),
                  title: 'Version',
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(color: isDark ? Colors.grey : const Color(0xFF6D6D72), fontSize: 16),
                  ),
                ),
                Divider(color: dividerColor, indent: 56),
                AppListTile(
                  leading: const Icon(Icons.sd_storage_rounded, color: Colors.grey),
                  title: 'Storage Strategy',
                  trailing: Text(
                    'Local Hive & Cache',
                    style: TextStyle(color: isDark ? Colors.grey : const Color(0xFF6D6D72), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
