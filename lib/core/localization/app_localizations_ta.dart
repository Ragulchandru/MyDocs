// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'MyDocs';

  @override
  String get appTagline =>
      'உங்கள் முக்கியமான ஆவணங்கள், எப்போதும் எளிதாகக் கண்டறியும் வகையில்.';

  @override
  String get welcomeMessage => 'MyDocs-க்கு உங்களை வரவேற்கிறோம்';

  @override
  String get welcomeDescription =>
      'உங்கள் முக்கியமான ஆவணங்களை ஒரே பாதுகாப்பான, ஆஃப்லைன் இடத்தில் எளிதாக ஒழுங்கமைத்து அணுகலாம்.';

  @override
  String get emptyStateText => 'ஆவணங்கள் எதுவும் இல்லை';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navFolders => 'கோப்புறைகள்';

  @override
  String get navRecycleBin => 'குப்பைத் தொட்டி';

  @override
  String get navSettings => 'அமைப்புகள்';
}
