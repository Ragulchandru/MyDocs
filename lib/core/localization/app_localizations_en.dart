// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyDocs';

  @override
  String get appTagline => 'Your important documents, always easy to find.';

  @override
  String get welcomeMessage => 'Welcome to MyDocs';

  @override
  String get welcomeDescription =>
      'Easily organize and access your important documents in one secure, offline place.';

  @override
  String get emptyStateText => 'No documents available';

  @override
  String get navHome => 'Home';

  @override
  String get navFolders => 'Folders';

  @override
  String get navRecycleBin => 'Recycle Bin';

  @override
  String get navSettings => 'Settings';
}
