// lib/core/widgets/app_widgets.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// 1. AppCard Widget
/// Combines 24dp border radius, soft shadows, thin divider-colored borders,
/// and a premium 0.98x scale-down animation on touch press.
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.radius = 24.0,
    this.borderColor,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = widget.color ?? (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF));
    final borderColor = widget.borderColor ?? (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6));
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.25 : 0.05);
    final double blurRadius = isDark ? 24.0 : 20.0;
    final Offset offset = isDark ? const Offset(0, 10) : const Offset(0, 8);

    Widget content = Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// 2. AppSearchBar Widget
/// Floats above layout, 20dp corners, Secondary Surface background,
/// search prefix icon, clear trailing button, and debouncing.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(text);
    });
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    widget.onChanged('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: secondaryTextColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 17,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _clear,
              child: Icon(
                Icons.clear_rounded,
                color: secondaryTextColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// 3. AppSectionHeader Widget
/// Typographical section title conforming to 22sp SemiBold specifications.
class AppSectionHeader extends StatelessWidget {
  final String title;

  const AppSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

/// 4. AppEmptyState Widget
/// Spacious and calm layout featuring friendly monochrome rounded icons
/// and actionable layout paths. No colorful illustrations.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);
    final textColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 5. AppListTile Widget
/// Minimum touch target 64dp height tile. Offers monochrome icons,
/// custom active cell highlights, and removes Material ripple spills.
class AppListTile extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final secondaryTextColor = isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72);
    final pressedColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    Widget content = Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isPressed ? pressedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 8),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// 6. AppPrimaryButton Widget
/// Fully rounded (24dp) action button complying with 56dp minimum touch heights.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final bg = onPressed == null
        ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA))
        : (backgroundColor ?? defaultBgColor);
    final textCol = onPressed == null
        ? (isDark ? const Color(0xFFAEAEB2) : const Color(0xFF6D6D72))
        : (textColor ?? const Color(0xFFFFFFFF));

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56, minWidth: 120),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
