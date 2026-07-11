// lib/features/documents/presentation/pages/image_viewer_page.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/document_error_widget.dart';

class ImageViewerPage extends StatefulWidget {
  final String documentId;
  final String filePath;
  final String title;

  const ImageViewerPage({
    super.key,
    required this.documentId,
    required this.filePath,
    required this.title,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;

  double _imageWidth = 0.0;
  double _imageHeight = 0.0;

  bool _isLoading = true;
  String? _errorMessage;

  // Viewport tracking variables
  double _lastViewportWidth = 0.0;
  double _lastViewportHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animationController.addListener(() {
      _transformationController.value = _zoomAnimation!.value;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initViewer();
    });
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _initViewer() async {
    final localizations = AppLocalizations.of(context);

    // 1. Keep screen awake during document viewing
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // 2. Hide status bar and system overlays for immersive view
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    // 3. File validation
    final file = File(widget.filePath);
    if (!await file.exists()) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorFileNotFound;
      });
      return;
    }

    final size = await file.length();
    if (size <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnableToOpen;
      });
      return;
    }

    // Supported extensions audit
    final ext = widget.filePath.toLowerCase();
    if (!ext.endsWith('.jpg') &&
        !ext.endsWith('.jpeg') &&
        !ext.endsWith('.png') &&
        !ext.endsWith('.webp')) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnsupportedFormat;
      });
      return;
    }

    // 4. Load dimensions to fit image to screen dynamically
    try {
      final image = await _loadImage(file);
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = localizations.errorUnableToOpen;
      });
      return;
    }

    if (mounted) {
      _transformationController.value = Matrix4.identity();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleDoubleTap() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.storage[0];

    Matrix4 endMatrix;
    // If already zoomed, double tap resets back to identity (Fit Screen)
    if (currentScale > 1.1) {
      endMatrix = Matrix4.identity();
    } else {
      const double targetScale = 2.5;
      final tapPos = _doubleTapDetails?.localPosition ?? Offset(_lastViewportWidth / 2, _lastViewportHeight / 2);

      // Formula for zooming into a focal point:
      // Translate to match the focal point in the viewport
      final double x = tapPos.dx - (tapPos.dx * targetScale);
      final double y = tapPos.dy - (tapPos.dy * targetScale);

      endMatrix = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 1.0)
        ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
    }

    _zoomAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: endMatrix,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward(from: 0.0);
  }

  void _resetToFit() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    final currentMatrix = _transformationController.value;
    _zoomAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    // 1. Disable screen awake override
    try {
      WakelockPlus.disable();
    } catch (_) {}

    // 2. Restore system UI overlays
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } catch (_) {}

    // 3. Dispose controllers
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_errorMessage != null) {
      return DocumentErrorWidget(
        title: localizations.errorUnableToOpen,
        message: _errorMessage!,
        onOk: () => Navigator.of(context).pop(),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetToFit,
            icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
            tooltip: localizations.btnFitScreen,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double viewportWidth = constraints.maxWidth;
            final double viewportHeight = constraints.maxHeight;

            // Trigger reset only on actual viewport dimensions change
            if (_lastViewportWidth != viewportWidth || _lastViewportHeight != viewportHeight) {
              _lastViewportWidth = viewportWidth;
              _lastViewportHeight = viewportHeight;

              // Schedule a one-time post-frame reset to identity matrix
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _transformationController.value = Matrix4.identity();
                }
              });
            }

            final double scaleX = viewportWidth / _imageWidth;
            final double scaleY = viewportHeight / _imageHeight;
            final double scale = scaleX < scaleY ? scaleX : scaleY;

            final double fittedWidth = _imageWidth * scale;
            final double fittedHeight = _imageHeight * scale;

            return GestureDetector(
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: Center(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 6.0,
                  boundaryMargin: EdgeInsets.zero,
                  child: SizedBox(
                    width: fittedWidth,
                    height: fittedHeight,
                    child: Hero(
                      tag: widget.documentId,
                      child: Image.file(
                        File(widget.filePath),
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return DocumentErrorWidget(
                            title: localizations.errorUnableToOpen,
                            message: localizations.errorUnableToOpen,
                            onOk: () => Navigator.of(context).pop(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
