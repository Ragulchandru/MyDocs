// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_initializer.dart';
import 'core/theme/app_theme.dart';

import 'features/settings/presentation/providers/settings_providers.dart';

void main() async {
  // Ensure Flutter engine is initialized before calling asynchronous plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local Hive storage and open boxes
  await HiveInitializer.init();

  runApp(
    // ProviderScope is required to initialize Riverpod state management
    const ProviderScope(
      child: MyDocsApp(),
    ),
  );
}

class MyDocsApp extends ConsumerWidget {
  const MyDocsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MyDocs',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically adapts to system preferences
      locale: currentLocale,

      // Localization configuration
      localizationsDelegates: const[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ta', ''), // Tamil
      ],

      // Go Router navigation configuration
      routerConfig: AppRouter.router,
    );
  }
}
