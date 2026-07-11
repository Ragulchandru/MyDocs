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

  @override
  String get viewOpenDocument => 'Open Document';

  @override
  String get errorFileNotFound => 'File not found';

  @override
  String get errorUnableToOpen => 'Unable to open document';

  @override
  String get errorUnsupportedFormat => 'Unsupported file format.';

  @override
  String get loadingText => 'Loading...';

  @override
  String pageIndicatorText(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get btnFitScreen => 'Fit Screen';

  @override
  String get btnAddPage => 'Add Page';

  @override
  String get btnFinish => 'Finish PDF';

  @override
  String get labelScannedPages => 'Scanned Pages';

  @override
  String labelPage(int pageNumber) {
    return 'Page $pageNumber';
  }

  @override
  String get okButton => 'OK';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get moveToRecycleBin => 'Move to Recycle Bin';

  @override
  String get moveToRecycleBinTitle => 'Move to Recycle Bin?';

  @override
  String get moveToRecycleBinMessage => 'This document can be restored later.';

  @override
  String get moveToRecycleBinMessageMany =>
      'These documents can be restored later.';

  @override
  String get restore => 'Restore';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get deletePermanentlyTitle => 'Delete permanently?';

  @override
  String get deletePermanentlyMessage => 'This action cannot be undone.';

  @override
  String get preparingDocument => 'Preparing document...';

  @override
  String get preparingPages => 'Preparing pages...';

  @override
  String get savingDocument => 'Saving document...';

  @override
  String get pleaseWait => 'Please wait. This may take a moment.';

  @override
  String get processingScan => 'Processing scan...';

  @override
  String get share => 'Share';

  @override
  String get shareSelected => 'Share Selected';

  @override
  String get noValidFilesToShare => 'No valid files found to share.';

  @override
  String get preview => 'Preview';

  @override
  String get preparingPreview => 'Preparing preview...';

  @override
  String get importingDocuments => 'Importing documents';

  @override
  String importProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String importSuccessMany(int count) {
    return '$count documents imported successfully.';
  }

  @override
  String importPartial(int success, int total, int fail) {
    return '$success of $total documents imported. $fail failed.';
  }

  @override
  String get importAllFailed => 'Unable to import the selected documents.';

  @override
  String get cameraPermissionTitle => 'Camera Access Required';

  @override
  String get cameraPermissionMessage =>
      'MyDocs needs camera access to scan documents.';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required to scan documents.';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'Camera access is disabled. Enable it in App Settings to scan documents.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get scannerUnavailable =>
      'Document scanning is unavailable on this device.';

  @override
  String get scannerGooglePlayServicesError =>
      'Google Play Services is unavailable or outdated. Please update it to use the scanner.';

  @override
  String scannerUnexpectedError(String message) {
    return 'An unexpected scanner error occurred: $message';
  }
}
