// lib/features/documents/presentation/widgets/document_thumbnail.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/thumbnail_service.dart';
import '../../domain/models/document.dart';

class DocumentThumbnail extends StatefulWidget {
  final Document document;
  final double height;

  const DocumentThumbnail({
    super.key,
    required this.document,
    required this.height,
  });

  @override
  State<DocumentThumbnail> createState() => _DocumentThumbnailState();
}

class _DocumentThumbnailState extends State<DocumentThumbnail> {
  String? _thumbnailPath;
  bool _isGenerating = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _checkAndGenerate();
  }

  @override
  void didUpdateWidget(DocumentThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id || oldWidget.document.filePath != widget.document.filePath) {
      setState(() {
        _thumbnailPath = null;
        _failed = false;
      });
      _checkAndGenerate();
    }
  }

  Future<void> _checkAndGenerate() async {
    if (widget.document.fileType == DocumentType.image) {
      return;
    }

    final path = await ThumbnailService.getThumbnailPath(widget.document.id);
    final file = File(path);
    if (await file.exists() && await file.length() > 0) {
      if (mounted) {
        setState(() {
          _thumbnailPath = path;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isGenerating = true;
      });
    }

    final generatedFile = await ThumbnailService.generatePdfThumbnail(
      widget.document.id,
      widget.document.filePath,
    );

    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (generatedFile != null) {
          _thumbnailPath = generatedFile.path;
        } else {
          _failed = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final iconColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);

    if (widget.document.fileType == DocumentType.image) {
      return Image.file(
        File(widget.document.filePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.height,
        cacheWidth: 200, // Optimize image memory usage
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: placeholderBg,
            height: widget.height,
            child: Icon(Icons.image_rounded, color: iconColor, size: 36),
          );
        },
      );
    }

    // PDF document type
    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.height,
        cacheWidth: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: placeholderBg,
            height: widget.height,
            child: Icon(Icons.picture_as_pdf_rounded, color: iconColor, size: 36),
          );
        },
      );
    }

    if (_isGenerating) {
      return Container(
        color: placeholderBg,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      );
    }

    // Default placeholder / failure state
    return Container(
      color: placeholderBg,
      height: widget.height,
      child: Center(
        child: Icon(
          Icons.picture_as_pdf_rounded,
          color: _failed ? Colors.red.withValues(alpha: 0.6) : iconColor,
          size: 36,
        ),
      ),
    );
  }
}
