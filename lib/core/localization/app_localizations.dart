import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyDocs'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your important documents, always easy to find.'**
  String get appTagline;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MyDocs'**
  String get welcomeMessage;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily organize and access your important documents in one secure, offline place.'**
  String get welcomeDescription;

  /// No description provided for @emptyStateText.
  ///
  /// In en, this message translates to:
  /// **'No documents available\nTap the + button to add your first document.'**
  String get emptyStateText;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get navFolders;

  /// No description provided for @navRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get navRecycleBin;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @importSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get importSheetTitle;

  /// No description provided for @importPdf.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get importPdf;

  /// No description provided for @importImage.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get importImage;

  /// No description provided for @importingLabel.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importingLabel;

  /// No description provided for @unsupportedFileTypeError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type selected.'**
  String get unsupportedFileTypeError;

  /// No description provided for @mimeMismatchError.
  ///
  /// In en, this message translates to:
  /// **'File format verification failed (MIME type mismatch).'**
  String get mimeMismatchError;

  /// No description provided for @fileImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document imported successfully.'**
  String get fileImportSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @errorUserCancelled.
  ///
  /// In en, this message translates to:
  /// **'File selection cancelled.'**
  String get errorUserCancelled;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied.'**
  String get errorPermission;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @importScan.
  ///
  /// In en, this message translates to:
  /// **'Scan Document'**
  String get importScan;

  /// No description provided for @scanningLabel.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanningLabel;

  /// No description provided for @generatingPdfLabel.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdfLabel;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingLabel;

  /// No description provided for @errorScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan operation failed or cancelled.'**
  String get errorScanFailed;

  /// No description provided for @errorCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan documents.'**
  String get errorCameraPermission;

  /// No description provided for @saveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Document'**
  String get saveDialogTitle;

  /// No description provided for @saveDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter document name'**
  String get saveDialogHint;

  /// No description provided for @saveDialogValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a document name.'**
  String get saveDialogValidationError;

  /// No description provided for @saveDialogHintExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Driving License'**
  String get saveDialogHintExample;

  /// No description provided for @saveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @viewOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Open Document'**
  String get viewOpenDocument;

  /// No description provided for @errorFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get errorFileNotFound;

  /// No description provided for @errorUnableToOpen.
  ///
  /// In en, this message translates to:
  /// **'Unable to open document'**
  String get errorUnableToOpen;

  /// No description provided for @errorUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format.'**
  String get errorUnsupportedFormat;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @pageIndicatorText.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageIndicatorText(int current, int total);

  /// No description provided for @btnFitScreen.
  ///
  /// In en, this message translates to:
  /// **'Fit Screen'**
  String get btnFitScreen;

  /// No description provided for @btnAddPage.
  ///
  /// In en, this message translates to:
  /// **'Add Page'**
  String get btnAddPage;

  /// No description provided for @btnFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish PDF'**
  String get btnFinish;

  /// No description provided for @labelScannedPages.
  ///
  /// In en, this message translates to:
  /// **'Scanned Pages'**
  String get labelScannedPages;

  /// No description provided for @labelPage.
  ///
  /// In en, this message translates to:
  /// **'Page {pageNumber}'**
  String labelPage(int pageNumber);

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @moveToRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Move to Recycle Bin'**
  String get moveToRecycleBin;

  /// No description provided for @moveToRecycleBinTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to Recycle Bin?'**
  String get moveToRecycleBinTitle;

  /// No description provided for @moveToRecycleBinMessage.
  ///
  /// In en, this message translates to:
  /// **'This document can be restored later.'**
  String get moveToRecycleBinMessage;

  /// No description provided for @moveToRecycleBinMessageMany.
  ///
  /// In en, this message translates to:
  /// **'These documents can be restored later.'**
  String get moveToRecycleBinMessageMany;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @deletePermanentlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get deletePermanentlyTitle;

  /// No description provided for @deletePermanentlyMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deletePermanentlyMessage;

  /// No description provided for @preparingDocument.
  ///
  /// In en, this message translates to:
  /// **'Preparing document...'**
  String get preparingDocument;

  /// No description provided for @preparingPages.
  ///
  /// In en, this message translates to:
  /// **'Preparing pages...'**
  String get preparingPages;

  /// No description provided for @savingDocument.
  ///
  /// In en, this message translates to:
  /// **'Saving document...'**
  String get savingDocument;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait. This may take a moment.'**
  String get pleaseWait;

  /// No description provided for @processingScan.
  ///
  /// In en, this message translates to:
  /// **'Processing scan...'**
  String get processingScan;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareSelected.
  ///
  /// In en, this message translates to:
  /// **'Share Selected'**
  String get shareSelected;

  /// No description provided for @noValidFilesToShare.
  ///
  /// In en, this message translates to:
  /// **'No valid files found to share.'**
  String get noValidFilesToShare;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @preparingPreview.
  ///
  /// In en, this message translates to:
  /// **'Preparing preview...'**
  String get preparingPreview;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
