// lib/core/widgets/document_error_widget.dart

import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// Reusable Material 3 error widget for display when files are missing,
/// corrupted, empty, or have unsupported extensions.
class DocumentErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onOk;

  const DocumentErrorWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: onOk,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 28),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: onOk,
                    child: Text(
                      localizations.okButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
