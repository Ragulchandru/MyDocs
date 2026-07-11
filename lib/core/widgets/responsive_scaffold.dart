// lib/core/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'app_navigation_drawer.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String currentPath;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    required this.body,
    required this.currentPath,
    this.title,
    this.floatingActionButton,
    this.actions,
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

    if (isTablet) {
      return Scaffold(
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
      return Scaffold(
        appBar: AppBar(
          title: title,
          backgroundColor: appBarColor,
          elevation: 0,
          iconTheme: IconThemeData(color: iconColor),
          actions: actions,
        ),
        drawer: AppNavigationDrawer(
          currentPath: currentPath,
          isPermanent: false,
        ),
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
