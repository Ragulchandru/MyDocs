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

  @override
  String get viewOpenDocument => 'ஆவணத்தைத் திற';

  @override
  String get errorFileNotFound => 'கோப்பு கண்டறியப்படவில்லை';

  @override
  String get errorUnableToOpen => 'ஆவணத்தைத் திறக்க முடியவில்லை';

  @override
  String get errorUnsupportedFormat => 'ஆதரிக்கப்படாத கோப்பு வடிவம்.';

  @override
  String get loadingText => 'ஏற்றப்படுகிறது...';

  @override
  String pageIndicatorText(int current, int total) {
    return 'பக்கம் $total-இல் $current';
  }

  @override
  String get btnFitScreen => 'திரைக்குப் பொருத்து';

  @override
  String get btnAddPage => 'பக்கத்தைச் சேர்';

  @override
  String get btnFinish => 'PDF-ஐ முடி';

  @override
  String get labelScannedPages => 'ஸ்கேன் செய்த பக்கங்கள்';

  @override
  String labelPage(int pageNumber) {
    return 'பக்கம் $pageNumber';
  }

  @override
  String get okButton => 'சரி';

  @override
  String selectedCount(int count) {
    return '$count தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get selectAll => 'அனைத்தையும் தேர்ந்தெடு';

  @override
  String get moveToRecycleBin => 'குப்பைத் தொட்டிக்கு நகர்த்து';

  @override
  String get moveToRecycleBinTitle => 'குப்பைத் தொட்டிக்கு நகர்த்தவா?';

  @override
  String get moveToRecycleBinMessage => 'இந்த ஆவணத்தை பின்னர் மீட்டெடுக்கலாம்.';

  @override
  String get moveToRecycleBinMessageMany =>
      'இந்த ஆவணங்களை பின்னர் மீட்டெடுக்கலாம்.';

  @override
  String get restore => 'மீட்டெடு';

  @override
  String get deletePermanently => 'நிரந்தரமாக நீக்கு';

  @override
  String get deletePermanentlyTitle => 'நிரந்தரமாக நீக்கவா?';

  @override
  String get deletePermanentlyMessage => 'இந்தச் செயலை மாற்ற முடியாது.';

  @override
  String get preparingDocument => 'ஆவணம் தயாரிக்கப்படுகிறது...';

  @override
  String get preparingPages => 'பக்கங்கள் தயாரிக்கப்படுகின்றன...';

  @override
  String get savingDocument => 'ஆவணம் சேமிக்கப்படுகிறது...';

  @override
  String get pleaseWait =>
      'தயவுசெய்து காத்திருக்கவும். இதற்கு ஒரு நிமிடம் ஆகலாம்.';

  @override
  String get processingScan => 'ஸ்கேன் செயலாக்கப்படுகிறது...';

  @override
  String get share => 'பகிர்க';

  @override
  String get shareSelected => 'தேர்ந்தெடுக்கப்பட்டதை பகிர்க';

  @override
  String get noValidFilesToShare =>
      'பகிர்வதற்கு சரியான கோப்புகள் எதுவும் இல்லை.';

  @override
  String get preview => 'முன்னோட்டம்';

  @override
  String get preparingPreview => 'முன்னோட்டம் தயாரிக்கப்படுகிறது...';

  @override
  String get importingDocuments => 'ஆவணங்கள் இறக்குமதி செய்யப்படுகின்றன';

  @override
  String importProgress(int current, int total) {
    return '$total-இல் $current';
  }

  @override
  String importSuccessMany(int count) {
    return '$count ஆவணங்கள் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டன.';
  }

  @override
  String importPartial(int success, int total, int fail) {
    return '$total-இல் $success ஆவணங்கள் இறக்குமதி செய்யப்பட்டன. $fail தோல்வியடைந்தன.';
  }

  @override
  String get importAllFailed =>
      'தேர்ந்தெடுக்கப்பட்ட ஆவணங்களை இறக்குமதி செய்ய முடியவில்லை.';

  @override
  String get cameraPermissionTitle => 'கேமரா அணுகல் தேவை';

  @override
  String get cameraPermissionMessage =>
      'ஆவணங்களை ஸ்கேன் செய்ய MyDocs-க்கு கேமரா அணுகல் தேவை.';

  @override
  String get cameraPermissionDenied =>
      'ஆவணங்களை ஸ்கேன் செய்ய கேமரா அனுமதி தேவை.';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'கேமரா அணுகல் முடக்கப்பட்டுள்ளது. ஆவணங்களை ஸ்கேன் செய்ய பயன்பாட்டு அமைப்புகளில் அதை இயக்கவும்.';

  @override
  String get openSettings => 'அமைப்புகளைத் திறக்கவும்';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get scannerUnavailable =>
      'இந்த சாதனத்தில் ஆவண ஸ்கேனிங் கிடைக்கவில்லை.';

  @override
  String get scannerGooglePlayServicesError =>
      'கூகிள் பிளே சேவைகள் கிடைக்கவில்லை அல்லது காலாவதியானது. ஸ்கேனரைப் பயன்படுத்த அதைப் புதுப்பிக்கவும்.';

  @override
  String scannerUnexpectedError(String message) {
    return 'எதிர்பாராத ஸ்கேனர் பிழை ஏற்பட்டது: $message';
  }

  @override
  String get scannerUnavailableTitle => 'ஸ்கேனர் கிடைக்கவில்லை';

  @override
  String get scannerUnavailableMessage =>
      'இந்த சாதனத்தில் மேம்பட்ட ஆவண ஸ்கேனர் கிடைக்கவில்லை. அடிப்படை கேமரா ஸ்கேனரைப் பயன்படுத்தி நீங்கள் தொடரலாம்.';

  @override
  String get useCamera => 'கேமராவைப் பயன்படுத்துக';

  @override
  String get cameraCaptureFailed => 'ஆவண புகைப்படத்தை எடுக்க முடியவில்லை.';
}
