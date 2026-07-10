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
  String get emptyStateText =>
      'ஆவணங்கள் எதுவும் இல்லை\nஉங்கள் முதல் ஆவணத்தைச் சேர்க்க + பொத்தானைத் தட்டவும்.';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navFolders => 'கோப்புறைகள்';

  @override
  String get navRecycleBin => 'குப்பைத் தொட்டி';

  @override
  String get navSettings => 'அமைப்புகள்';

  @override
  String get importSheetTitle => 'ஆவணத்தைச் சேர்';

  @override
  String get importPdf => 'PDF-ஐ இறக்குமதி செய்';

  @override
  String get importImage => 'படத்தை இறக்குமதி செய்';

  @override
  String get importingLabel => 'இறக்குமதி செய்யப்படுகிறது...';

  @override
  String get unsupportedFileTypeError =>
      'ஆதரிக்கப்படாத கோப்பு வகை தேர்ந்தெடுக்கப்பட்டது.';

  @override
  String get mimeMismatchError =>
      'கோப்பு வடிவமைப்பு சரிபார்ப்பு தோல்வியுற்றது.';

  @override
  String get fileImportSuccess => 'ஆவணம் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டது.';

  @override
  String errorGeneric(Object error) {
    return 'பிழை ஏற்பட்டது: $error';
  }

  @override
  String get errorUserCancelled => 'கோப்பு தேர்வு ரத்து செய்யப்பட்டது.';

  @override
  String get errorPermission => 'அனுமதி மறுக்கப்பட்டது.';

  @override
  String get dateToday => 'இன்று';

  @override
  String get dateYesterday => 'நேற்று';

  @override
  String get importScan => 'ஆவணத்தை ஸ்கேன் செய்';

  @override
  String get scanningLabel => 'ஸ்கேன் செய்யப்படுகிறது...';

  @override
  String get generatingPdfLabel => 'PDF உருவாக்கப்படுகிறது...';

  @override
  String get savingLabel => 'சேமிக்கப்படுகிறது...';

  @override
  String get errorScanFailed =>
      'ஸ்கேன் செயல்பாடு தோல்வியடைந்தது அல்லது ரத்து செய்யப்பட்டது.';

  @override
  String get errorCameraPermission =>
      'ஆவணங்களை ஸ்கேன் செய்ய கேமரா அனுமதி தேவை.';

  @override
  String get saveDialogTitle => 'ஆவணத்தைச் சேமி';

  @override
  String get saveDialogHint => 'ஆவணத்தின் பெயரை உள்ளிடவும்';

  @override
  String get saveDialogValidationError => 'ஆவணத்தின் பெயரை உள்ளிடவும்.';

  @override
  String get saveDialogHintExample => 'உதாரணம்: ஓட்டுநர் உரிமம்';

  @override
  String get saveButtonLabel => 'சேமி';

  @override
  String get cancelButton => 'ரத்துசெய்';
}
