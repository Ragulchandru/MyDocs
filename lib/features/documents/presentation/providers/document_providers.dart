// lib/features/documents/presentation/providers/document_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../../../core/storage/storage_strategy.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../data/services/document_scanner_service_impl.dart';
import '../../domain/models/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/services/document_scanner_service.dart';
import '../../domain/usecases/get_documents_usecase.dart';
import '../../domain/usecases/import_document_usecase.dart';
import '../../domain/usecases/scan_document_usecase.dart';

/// Exposes the document database repository.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final box = Hive.box<Document>(StorageConstants.documentsBox);
  return DocumentRepositoryImpl(box);
});

/// Exposes the storage strategy.
final storageStrategyProvider = Provider<StorageStrategy>((ref) {
  return LocalStorageStrategy();
});

/// Exposes the use case for file importing.
final importDocumentUseCaseProvider = Provider<ImportDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final storage = ref.watch(storageStrategyProvider);
  return ImportDocumentUseCase(repository, storage);
});

/// Exposes the use case for fetching and sorting files.
final getDocumentsUseCaseProvider = Provider<GetDocumentsUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return GetDocumentsUseCase(repository);
});

/// Exposes a stream of documents, automatically refreshed upon Hive updates.
final documentListProvider = StreamProvider<List<Document>>((ref) {
  final useCase = ref.watch(getDocumentsUseCaseProvider);
  return useCase.execute();
});

/// Exposes the document scanner service.
final documentScannerServiceProvider = Provider<DocumentScannerService>((ref) {
  return DocumentScannerServiceImpl();
});

/// Exposes the scan document use case.
final scanDocumentUseCaseProvider = Provider<ScanDocumentUseCase>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final storageStrategy = ref.watch(storageStrategyProvider);
  return ScanDocumentUseCase(repository, storageStrategy);
});
