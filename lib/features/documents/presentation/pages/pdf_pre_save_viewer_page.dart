// lib/features/documents/presentation/pages/pdf_pre_save_viewer_page.dart

import 'package:flutter/material.dart';
import 'pdf_viewer_page.dart';

class PdfPreSaveViewerPage extends StatelessWidget {
  final String tempPdfPath;
  final String documentName;

  const PdfPreSaveViewerPage({
    super.key,
    required this.tempPdfPath,
    required this.documentName,
  });

  @override
  Widget build(BuildContext context) {
    return PdfViewerPage(
      filePath: tempPdfPath,
      title: documentName,
      isPreSave: true,
    );
  }
}
