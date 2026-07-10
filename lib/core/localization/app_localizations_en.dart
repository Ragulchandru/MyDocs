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
  String get emptyStateText =>
      'No documents available\nTap the + button to add your first document.';

  @override
  String get navHome => 'Home';

  @override
  String get navFolders => 'Folders';

  @override
  String get navRecycleBin => 'Recycle Bin';

  @override
  String get navSettings => 'Settings';

  @override
  String get importSheetTitle => 'Add Document';

  @override
  String get importPdf => 'Import PDF';

  @override
  String get importImage => 'Import Image';

  @override
  String get importingLabel => 'Importing...';

  @override
  String get unsupportedFileTypeError => 'Unsupported file type selected.';

  @override
  String get mimeMismatchError =>
      'File format verification failed (MIME type mismatch).';

  @override
  String get fileImportSuccess => 'Document imported successfully.';

  @override
  String errorGeneric(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get errorUserCancelled => 'File selection cancelled.';

  @override
  String get errorPermission => 'Storage permission denied.';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get importScan => 'Scan Document';

  @override
  String get scanningLabel => 'Scanning...';

  @override
  String get generatingPdfLabel => 'Generating PDF...';

  @override
  String get savingLabel => 'Saving...';

  @override
  String get errorScanFailed => 'Scan operation failed or cancelled.';

  @override
  String get errorCameraPermission =>
      'Camera permission is required to scan documents.';

  @override
  String get saveDialogTitle => 'Save Document';

  @override
  String get saveDialogHint => 'Enter document name';

  @override
  String get saveDialogValidationError => 'Please enter a document name.';

  @override
  String get saveDialogHintExample => 'Example: Driving License';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get cancelButton => 'Cancel';
}
