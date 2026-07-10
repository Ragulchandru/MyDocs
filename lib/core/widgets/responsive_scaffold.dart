// lib/core/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';
import 'app_navigation_drawer.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String currentPath;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    required this.body,
    required this.currentPath,
    this.title,
    this.floatingActionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    if (isTablet) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              AppNavigationDrawer(
                currentPath: currentPath,
                isPermanent: true,
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                child: Scaffold(
                  appBar: title != null
                      ? AppBar(
                          title: title,
                          automaticallyImplyLeading: false, // No hamburger menu needed on tablet
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
