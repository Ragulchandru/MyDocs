// lib/features/settings/presentation/providers/settings_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/storage_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final box = Hive.box(StorageConstants.settingsBox);
  return LocaleNotifier(box);
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final Box _box;

  LocaleNotifier(this._box) : super(null) {
    final languageCode = _box.get('language_code') as String?;
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    await _box.put('language_code', languageCode);
    state = Locale(languageCode);
  }

  Future<void> clearLocale() async {
    await _box.delete('language_code');
    state = null;
  }
}

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, String>((ref) {
  final box = Hive.box(StorageConstants.settingsBox);
  return ViewModeNotifier(box);
});

class ViewModeNotifier extends StateNotifier<String> {
  final Box _box;

  ViewModeNotifier(this._box) : super('grid') {
    final mode = _box.get('view_mode') as String?;
    if (mode != null) {
      state = mode;
    }
  }

  Future<void> setViewMode(String mode) async {
    await _box.put('view_mode', mode);
    state = mode;
  }

  Future<void> toggleViewMode() async {
    final nextMode = state == 'grid' ? 'list' : 'grid';
    await setViewMode(nextMode);
  }
}
