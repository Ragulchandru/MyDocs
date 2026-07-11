// lib/features/documents/presentation/widgets/rename_document_dialog.dart

import 'package:flutter/material.dart';
import '../../domain/models/document.dart';

class RenameDocumentDialog extends StatefulWidget {
  final Document document;
  final ValueChanged<String> onRename;

  const RenameDocumentDialog({
    super.key,
    required this.document,
    required this.onRename,
  });

  @override
  State<RenameDocumentDialog> createState() => _RenameDocumentDialogState();
}

class _RenameDocumentDialogState extends State<RenameDocumentDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final nameText = widget.document.name;
    final extension = widget.document.extension.replaceAll('.', '');
    final fullText = extension.isNotEmpty ? '$nameText.$extension' : nameText;

    _controller = TextEditingController(text: fullText);

    // Auto-select only the name part without the extension
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameText.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _cleanInput(String input) {
    // Remove invalid filename characters: \ / : * ? " < > |
    var cleaned = input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');

    // Automatically preserve/strip extension from the user typed input
    final extWithDot = '.${widget.document.extension.replaceAll('.', '').toLowerCase()}';
    if (cleaned.toLowerCase().endsWith(extWithDot) && cleaned.length > extWithDot.length) {
      cleaned = cleaned.substring(0, cleaned.length - extWithDot.length);
    }
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rename Document',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter a new name for this document. The extension will be preserved automatically.',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(color: primaryTextColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Document name',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  errorStyle: const TextStyle(fontSize: 13),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  final cleaned = _cleanInput(value);
                  if (cleaned.isEmpty) {
                    return 'Name contains only invalid characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final finalName = _cleanInput(_controller.text);
                        widget.onRename(finalName);
                        Navigator.of(context).pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
