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

/// Exposes a stream of active (non-deleted) documents, automatically refreshed upon Hive updates.
final documentListProvider = StreamProvider<List<Document>>((ref) {
  final useCase = ref.watch(getDocumentsUseCaseProvider);
  return useCase.execute().map((list) {
    return list.where((doc) => !doc.isDeleted).toList();
  });
});

/// Exposes a stream of soft-deleted documents, sorted by deletedAt descending.
final deletedDocumentListProvider = StreamProvider<List<Document>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.watchDocuments().map((list) {
    final deleted = list.where((doc) => doc.isDeleted).toList();
    deleted.sort((a, b) {
      final aTime = a.deletedAt ?? a.updatedAt;
      final bTime = b.deletedAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });
    return deleted;
  });
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

/// Exposes the multi-select selection state notifier and provider.
final selectionProvider = StateNotifierProvider<SelectionNotifier, Set<String>>((ref) {
  return SelectionNotifier();
});

class SelectionNotifier extends StateNotifier<Set<String>> {
  SelectionNotifier() : super(const {});

  void select(String id) {
    state = {...state, id};
  }

  void deselect(String id) {
    state = {...state}..remove(id);
  }

  void toggle(String id) {
    if (state.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  void selectAll(Iterable<String> ids) {
    state = Set<String>.from(ids);
  }

  void clearSelection() {
    state = const {};
  }
}

/// Exposes the multi-select selection state for the Recycle Bin.
final recycleBinSelectionProvider = StateNotifierProvider<RecycleBinSelectionNotifier, Set<String>>((ref) {
  return RecycleBinSelectionNotifier();
});

class RecycleBinSelectionNotifier extends StateNotifier<Set<String>> {
  RecycleBinSelectionNotifier() : super(const {});

  void select(String id) {
    state = {...state, id};
  }

  void deselect(String id) {
    state = {...state}..remove(id);
  }

  void toggle(String id) {
    if (state.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  void selectAll(Iterable<String> ids) {
    state = Set<String>.from(ids);
  }

  void clearSelection() {
    state = const {};
  }
}
