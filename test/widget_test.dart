// test/widget_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mydocs/core/storage/storage_constants.dart';
import 'package:mydocs/features/documents/data/models/document_adapter.dart';
import 'package:mydocs/features/documents/domain/models/document.dart';
import 'package:mydocs/main.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive locally in the project directory for the test duration
    Hive.init('.');
    
    // Register the manual document metadata adapter
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(DocumentAdapter());
    }

    // Open the boxes accessed by Riverpod providers during initialization
    await Hive.openBox<Document>(StorageConstants.documentsBox);
    await Hive.openBox(StorageConstants.foldersBox);
    await Hive.openBox(StorageConstants.settingsBox);
    await Hive.openBox(StorageConstants.recycleBinBox);
  });

  tearDownAll(() async {
    // Clear and close Hive boxes after tests complete
    await Hive.box<Document>(StorageConstants.documentsBox).clear();
    await Hive.close();
  });

  testWidgets('MyDocs App Smoke Test', (WidgetTester tester) async {
    // Pump MyDocsApp inside the Riverpod ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyDocsApp(),
      ),
    );

    // Verify the root widget is present
    expect(find.byType(MyDocsApp), findsOneWidget);
  });
}
