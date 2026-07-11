// lib/features/documents/presentation/widgets/document_info_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/document.dart';

class DocumentInfoBottomSheet extends StatelessWidget {
  final Document document;

  const DocumentInfoBottomSheet({
    super.key,
    required this.document,
  });

  Future<int> _getPdfPageCount() async {
    if (document.fileType != DocumentType.pdf) return 1;
    try {
      final doc = await PdfDocument.openFile(document.filePath);
      return doc.pagesCount;
    } catch (_) {
      return 1;
    }
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Widget _buildRow(String label, String value, Color textColor, Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Document Info',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildRow('Document Name', document.name, primaryTextColor, secondaryTextColor),
            Divider(color: dividerColor),
            _buildRow('Type', document.fileType == DocumentType.pdf ? 'PDF' : 'Image', primaryTextColor, secondaryTextColor),
            Divider(color: dividerColor),
            _buildRow('Size', formatFileSize(document.fileSize), primaryTextColor, secondaryTextColor),
            Divider(color: dividerColor),
            FutureBuilder<int>(
              future: _getPdfPageCount(),
              builder: (context, snapshot) {
                final pages = snapshot.data ?? 1;
                return _buildRow('Pages', '$pages', primaryTextColor, secondaryTextColor);
              },
            ),
            Divider(color: dividerColor),
            _buildRow('Created', _formatDateTime(document.createdAt), primaryTextColor, secondaryTextColor),
            Divider(color: dividerColor),
            _buildRow('Modified', _formatDateTime(document.updatedAt), primaryTextColor, secondaryTextColor),
            Divider(color: dividerColor),
            _buildRow('Location', 'Internal Storage', primaryTextColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }
}
