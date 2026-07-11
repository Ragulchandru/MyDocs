// lib/features/documents/data/services/thumbnail_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class ThumbnailService {
  /// Gets the absolute path where the thumbnail for a document is cached.
  static Future<String> getThumbnailPath(String docId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'thumbnails', '$docId.png');
  }

  /// Generates a PNG thumbnail for the first page of a PDF document at thumbnail resolution.
  static Future<File?> generatePdfThumbnail(String docId, String pdfPath) async {
    try {
      final targetPath = await getThumbnailPath(docId);
      final targetFile = File(targetPath);

      if (await targetFile.exists() && await targetFile.length() > 0) {
        return targetFile;
      }

      // Ensure target directory exists
      if (!await targetFile.parent.exists()) {
        await targetFile.parent.create(recursive: true);
      }

      // Open PDF document and render page 1 at thumbnail resolution
      final document = await PdfDocument.openFile(pdfPath);
      if (document.pagesCount == 0) {
        await document.close();
        return null;
      }

      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: 300,
        height: 400,
        format: PdfPageImageFormat.png,
      );

      if (pageImage != null) {
        await targetFile.writeAsBytes(pageImage.bytes, flush: true);
        await page.close();
        await document.close();
        return targetFile;
      }

      await page.close();
      await document.close();
      return null;
    } catch (e) {
      debugPrint('Error generating PDF thumbnail for $docId: $e');
      return null;
    }
  }

  /// Deletes the cached PNG thumbnail for a document from disk.
  static Future<void> deleteThumbnail(String docId) async {
    try {
      final targetPath = await getThumbnailPath(docId);
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting thumbnail for $docId: $e');
    }
  }
}
