// lib/core/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import 'app_navigation_drawer.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String currentPath;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  // Explicit back navigation parameters
  final bool hasInternalBackState;
  final VoidCallback? onInternalBack;

  const ResponsiveScaffold({
    required this.body,
    required this.currentPath,
    this.title,
    this.floatingActionButton,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.hasInternalBackState = false,
    this.onInternalBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const appBarColor = Colors.transparent;
    final iconColor = isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF);
    final dividerColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC);

    final Widget mainLayout;

    if (isTablet) {
      mainLayout = Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              AppNavigationDrawer(
                currentPath: currentPath,
                isPermanent: true,
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: dividerColor,
              ),
              Expanded(
                child: Scaffold(
                  appBar: title != null
                      ? AppBar(
                          title: title,
                          leading: leading,
                          automaticallyImplyLeading: false, // No hamburger menu needed on tablet
                          backgroundColor: appBarColor,
                          elevation: 0,
                          iconTheme: IconThemeData(color: iconColor),
                          actions: actions,
                        )
                      : null,
                  body: body,
                  floatingActionButton: floatingActionButton,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      mainLayout = Scaffold(
        appBar: AppBar(
          title: title,
          leading: leading,
          automaticallyImplyLeading: leading != null ? false : automaticallyImplyLeading,
          backgroundColor: appBarColor,
          elevation: 0,
          iconTheme: IconThemeData(color: iconColor),
          actions: actions,
        ),
        drawer: leading != null ? null : AppNavigationDrawer(
          currentPath: currentPath,
          isPermanent: false,
        ),
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
      );
    }

    // Centralized strict back gesture policy:
    // 1. If we are on Home, we only prevent pop if selection mode or other internal state is active.
    // 2. If we are on any other top-level screen, we intercept pop (canPop = false) to either dismiss internal state or route to Home.
    final bool isHome = currentPath == AppRouter.homePath;
    final bool effectiveCanPop = isHome && !hasInternalBackState;

    return PopScope(
      canPop: effectiveCanPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (hasInternalBackState && onInternalBack != null) {
          onInternalBack!();
        } else if (!isHome) {
          context.go(AppRouter.homePath);
        }
      },
      child: mainLayout,
    );
  }
}
