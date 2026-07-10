// lib/core/utils/formatters.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

/// Formats raw file size in bytes to binary units (Bytes, KB, MB, GB) rounded to 1 decimal place.
String formatFileSize(int bytes) {
  if (bytes <= 0) return '0 Bytes';
  
  const suffixes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  var index = 0;
  var size = bytes.toDouble();
  
  while (size >= 1024 && index < suffixes.length - 1) {
    size /= 1024;
    index++;
  }
  
  if (index == 0) {
    return '${bytes.toStringAsFixed(0)} Bytes';
  }
  
  return '${size.toStringAsFixed(1)} ${suffixes[index]}';
}

/// Formats a [DateTime] into a friendly text representation ("Today", "Yesterday", or "08 Jul 2026").
String formatFriendlyDate(DateTime dateTime, BuildContext context) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

  final localizations = AppLocalizations.of(context);

  if (dateToCheck == today) {
    return localizations.dateToday;
  } else if (dateToCheck == yesterday) {
    return localizations.dateYesterday;
  } else {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMM yyyy', locale).format(dateTime);
  }
}
