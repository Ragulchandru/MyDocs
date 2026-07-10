// lib/features/documents/presentation/providers/scan_session_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the state of the active multi-page document scanning session.
/// Keeps captured image references safely across device rotation and configuration changes.
class ScanSessionNotifier extends Notifier<List<File>> {
  @override
  List<File> build() => [];

  /// Appends a new scanned page to the session
  void addPage(File file) {
    state = [...state, file];
  }

  /// Replaces an existing page at index, deleting the old temporary image file
  void replacePage(int index, File file) {
    if (index < 0 || index >= state.length) return;
    
    final newState = [...state];
    final oldFile = newState[index];
    
    try {
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
      }
    } catch (_) {}

    newState[index] = file;
    state = newState;
  }

  /// Removes a scanned page from the session, deleting its temporary image file
  void removePage(int index) {
    if (index < 0 || index >= state.length) return;

    final file = state[index];
    try {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}

    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  /// Reorders pages in the active list (drag-and-drop support)
  void reorderPages(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex > state.length) return;

    final newState = [...state];
    
    // Adjust target index if dragging down
    var target = newIndex;
    if (oldIndex < target) {
      target -= 1;
    }

    final item = newState.removeAt(oldIndex);
    newState.insert(target, item);
    state = newState;
  }

  /// Clears the session entirely, deleting all temporary files on the device storage
  void clearSession() {
    for (final file in state) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    state = [];
  }
}

/// Provider exposing the list of scanned pages and modifiers
final scanSessionProvider = NotifierProvider<ScanSessionNotifier, List<File>>(ScanSessionNotifier.new);
